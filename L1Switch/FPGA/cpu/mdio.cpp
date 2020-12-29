
#include "xgpio.h"
#include "microblaze_sleep.h"

extern XGpio gpio;

#define MDIO_READ 2
#define MDIO_WRITE 1

#define MII_ADDR_C45 (1<<30)

#define MDIO_C45 (1<<15)
#define MDIO_C45_ADDR (MDIO_C45 | 0)
#define MDIO_C45_READ (MDIO_C45 | 3)
#define MDIO_C45_WRITE (MDIO_C45 | 1)

#define MDIO_SETUP_TIME 10
#define MDIO_HOLD_TIME 10

/* Minimum MDC period is 400 ns, plus some margin for error.  MDIO_DELAY
 * is done twice per period.
 */
#define MDIO_DELAY 250

/* The PHY may take up to 300 ns to produce data, plus some margin
 * for error.
 */
#define MDIO_READ_DELAY 350

/* MDIO must already be configured as output. */
static void mdiobb_send_bit(int gpioMdc, int gpioMdio, int val)
{
	if (val) {
		XGpio_DiscreteSet(&gpio, 1, 1<<gpioMdio);
	} else {
		XGpio_DiscreteClear(&gpio, 1, 1<<gpioMdio);
	}
	//ndelay(MDIO_DELAY);
	usleep_MB(2);
	XGpio_DiscreteSet(&gpio, 1, 1<<gpioMdc);
	//ndelay(MDIO_DELAY);
	usleep_MB(2);
	XGpio_DiscreteClear(&gpio, 1, 1<<gpioMdc);
}

/* MDIO must already be configured as input. */
static int mdiobb_get_bit(int gpioMdc, int gpioMdio)
{
	//ndelay(MDIO_DELAY);
	usleep_MB(2);
	XGpio_DiscreteSet(&gpio, 1, 1<<gpioMdc);
	//ndelay(MDIO_READ_DELAY);
	usleep_MB(2);
	XGpio_DiscreteClear(&gpio, 1, 1<<gpioMdc);

	return ((XGpio_DiscreteRead(&gpio, 1) & (1<<gpioMdio)) != 0) ? 1 : 0;
}

/* MDIO must already be configured as output. */
static void mdiobb_send_num(int gpioMdc, int gpioMdio, u16 val, int bits)
{
	int i;

	for (i = bits - 1; i >= 0; i--)
		mdiobb_send_bit(gpioMdc, gpioMdio, (val >> i) & 1);
}

/* MDIO must already be configured as input. */
static u16 mdiobb_get_num(int gpioMdc, int gpioMdio, int bits)
{
	int i;
	u16 ret = 0;

	for (i = bits - 1; i >= 0; i--) {
		ret <<= 1;
		ret |= mdiobb_get_bit(gpioMdc, gpioMdio);
	}

	return ret;
}

/* Utility to send the preamble, address, and
 * register (common to read and write).
 */
static void mdiobb_cmd(int gpioMdc, int gpioMdio, int op, u8 phy, u8 reg)
{
	int i;

	XGpio_SetDataDirection(&gpio, 1, (~(1 << gpioMdio)) & XGpio_GetDataDirection(&gpio, 1));

	/*
	 * Send a 32 bit preamble ('1's) with an extra '1' bit for good
	 * measure.  The IEEE spec says this is a PHY optional
	 * requirement.  The AMD 79C874 requires one after power up and
	 * one after a MII communications error.  This means that we are
	 * doing more preambles than we need, but it is safer and will be
	 * much more robust.
	 */

	for (i = 0; i < 32; i++)
		mdiobb_send_bit(gpioMdc, gpioMdio, 1);

	/* send the start bit (01) and the read opcode (10) or write (01).
	   Clause 45 operation uses 00 for the start and 11, 10 for
	   read/write */
	mdiobb_send_bit(gpioMdc, gpioMdio, 0);
	if (op & MDIO_C45)
		mdiobb_send_bit(gpioMdc, gpioMdio, 0);
	else
		mdiobb_send_bit(gpioMdc, gpioMdio, 1);
	mdiobb_send_bit(gpioMdc, gpioMdio, (op >> 1) & 1);
	mdiobb_send_bit(gpioMdc, gpioMdio, (op >> 0) & 1);

	mdiobb_send_num(gpioMdc, gpioMdio, phy, 5);
	mdiobb_send_num(gpioMdc, gpioMdio, reg, 5);
}

/* In clause 45 mode all commands are prefixed by MDIO_ADDR to specify the
   lower 16 bits of the 21 bit address. This transfer is done identically to a
   MDIO_WRITE except for a different code. To enable clause 45 mode or
   MII_ADDR_C45 into the address. Theoretically clause 45 and normal devices
   can exist on the same bus. Normal devices should ignore the MDIO_ADDR
   phase. */
static int mdiobb_cmd_addr(int gpioMdc, int gpioMdio, int phy, u32 addr)
{
	unsigned int dev_addr = (addr >> 16) & 0x1F;
	unsigned int reg = addr & 0xFFFF;
	mdiobb_cmd(gpioMdc, gpioMdio, MDIO_C45_ADDR, phy, dev_addr);

	/* send the turnaround (10) */
	mdiobb_send_bit(gpioMdc, gpioMdio, 1);
	mdiobb_send_bit(gpioMdc, gpioMdio, 0);

	mdiobb_send_num(gpioMdc, gpioMdio, reg, 16);

	XGpio_SetDataDirection(&gpio, 1, (1 << gpioMdio) | XGpio_GetDataDirection(&gpio, 1));

	mdiobb_get_bit(gpioMdc, gpioMdio);

	return dev_addr;
}

int mdiobb_read(int gpioMdc, int gpioMdio, int phy, int reg)
{
	int ret, i;

	if (reg & MII_ADDR_C45) {
		reg = mdiobb_cmd_addr(gpioMdc, gpioMdio, phy, reg);
		mdiobb_cmd(gpioMdc, gpioMdio, MDIO_C45_READ, phy, reg);
	} else
		mdiobb_cmd(gpioMdc, gpioMdio, MDIO_READ, phy, reg);

	XGpio_SetDataDirection(&gpio, 1, (1 << gpioMdio) | XGpio_GetDataDirection(&gpio, 1));

	/* check the turnaround bit: the PHY should be driving it to zero, if this
	 * PHY is listed in phy_ignore_ta_mask as having broken TA, skip that
	 */
	if (mdiobb_get_bit(gpioMdc, gpioMdio) != 0) {
		/* PHY didn't drive TA low -- flush any bits it
		 * may be trying to send.
		 */
		for (i = 0; i < 32; i++)
			mdiobb_get_bit(gpioMdc, gpioMdio);

		return 0xffff;
	}

	ret = mdiobb_get_num(gpioMdc, gpioMdio, 16);
	mdiobb_get_bit(gpioMdc, gpioMdio);
	return ret;
}

int mdiobb_write(int gpioMdc, int gpioMdio, int phy, int reg, u16 val)
{
	if (reg & MII_ADDR_C45) {
		reg = mdiobb_cmd_addr(gpioMdc, gpioMdio, phy, reg);
		mdiobb_cmd(gpioMdc, gpioMdio, MDIO_C45_WRITE, phy, reg);
	} else
		mdiobb_cmd(gpioMdc, gpioMdio, MDIO_WRITE, phy, reg);

	/* send the turnaround (10) */
	mdiobb_send_bit(gpioMdc, gpioMdio, 1);
	mdiobb_send_bit(gpioMdc, gpioMdio, 0);

	mdiobb_send_num(gpioMdc, gpioMdio, val, 16);

	XGpio_SetDataDirection(&gpio, 1, (1 << gpioMdio) | XGpio_GetDataDirection(&gpio, 1));

	mdiobb_get_bit(gpioMdc, gpioMdio);
	return 0;
}
