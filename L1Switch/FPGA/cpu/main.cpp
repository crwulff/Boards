#include "xparameters.h"
#include "xuartlite.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xspi.h"
#include "microblaze_sleep.h"


XUartLite uart;
XGpio gpio;
XSpi spi;

extern int mdiobb_read(int gpioMdc, int gpioMdio, int phy, int reg);
extern int mdiobb_write(int gpioMdc, int gpioMdio, int phy, int reg, u16 val);


void create_patch(int p1, int p2) {
	XGpio_DiscreteWrite(&gpio, 2, (1<<10) | ((p1 & 0x1F) << 5) | (p2 & 0x1F));
	XGpio_DiscreteWrite(&gpio, 2, 0);
}

char* read_num(char* str, int *num) {
	*num = 0;
	while (*str != ' ' && *str != '\0') {
		*num = (*num) * 10 + (int)((*str) - '0');
		str++;
	}
	while (*str == ' ') str++;
	return str;
}

static char cmd[100];

void read_command(void) {
	int index = 0;
	bool exit = false;
	do {
		uint8_t b = 0;
		while (0 == XUartLite_Recv(&uart, &b, 1));
		switch (b) {
			case '\r':
				exit = true;
				print("\r\n");
				break;
			case '\t':
				break;
			case '\b':
				index--;
				outbyte(b);
				break;
			default:
				cmd[index++] = b;
				outbyte(b);
				break;
		}
	} while(index < 100 && !exit);
	cmd[index] = '\0';

	bool validCommand = false;
	if (0 == strncmp(cmd, "configure ", 10)) {
		if (0 == strncmp(&cmd[10], "patch ", 6)) {
			int p1 = -1;
			int p2 = -1;
			read_num(read_num(&cmd[16], &p1), &p2);

			if (p1 >= 0 && p2 >= 0) {
				xil_printf("Patching %d <--> %d\r\n", p1, p2);
				create_patch(p1, p2);
				create_patch(p2, p1);
			}

			validCommand = true;
		}
	}

	if (!validCommand && cmd[0] != '\0') {
		xil_printf("Command Invalid: \"%s\"\r\n", cmd);
	}
}

int main(int argc, char **argv) {

	XUartLite_Initialize(&uart, XPAR_AXI_UARTLITE_0_DEVICE_ID);
	XSpi_Initialize(&spi, XPAR_AXI_QUAD_SPI_0_DEVICE_ID);
	XSpi_Start(&spi);
	XSpi_IntrGlobalDisable(&spi);
	XSpi_SetOptions(&spi, XSP_MASTER_OPTION);

    XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_DEVICE_ID);

	XGpio_SetDataDirection(&gpio, 1, (~((1 << 6) | (1 << 8))) & XGpio_GetDataDirection(&gpio, 1));

	xil_printf("Test %d\r\n", 123);

	// Reset the PHYs
	XGpio_DiscreteClear(&gpio, 1, 1);
	usleep_MB(20000);
	XGpio_DiscreteSet(&gpio, 1, 1);

	usleep_MB(20000);


	uint16_t ledVal = 0x0f0f;
	do {

		for (int i=0; i<8; i++) {
#if 0
			xil_printf("PHY[%d] REG 0 = %04X\r\n", i, mdiobb_read(2, 3, i, 0));
			xil_printf("PHY[%d] REG 1 = %04X\r\n", i, mdiobb_read(2, 3, i, 1));
			xil_printf("PHY[%d] REG 2 = %04X\r\n", i, mdiobb_read(2, 3, i, 2));
			xil_printf("PHY[%d] REG 3 = %04X\r\n", i, mdiobb_read(2, 3, i, 3));
			xil_printf("PHY[%d] REG 9 = %04X\r\n", i, mdiobb_read(2, 3, i, 9));
			xil_printf("PHY[%d] REG 10 = %04X\r\n", i, mdiobb_read(2, 3, i, 10));
			xil_printf("PHY[%d] REG 2 = %04X\r\n", i, mdiobb_read(4, 5, i, 2));
			xil_printf("PHY[%d] REG 3 = %04X\r\n", i, mdiobb_read(4, 5, i, 3));
			xil_printf("PHY[%d] REG 2 = %04X\r\n", i, mdiobb_read(6, 7, i, 2));
			xil_printf("PHY[%d] REG 3 = %04X\r\n", i, mdiobb_read(6, 7, i, 3));
			xil_printf("PHY[%d] REG 2 = %04X\r\n", i, mdiobb_read(8, 9, i, 2));
			xil_printf("PHY[%d] REG 3 = %04X\r\n", i, mdiobb_read(8, 9, i, 3));
#endif
			mdiobb_write(2, 3, i, 0x1D, ledVal);
			mdiobb_write(4, 5, i, 0x1D, ledVal);
			mdiobb_write(6, 7, i, 0x1D, ledVal);
			mdiobb_write(8, 9, i, 0x1D, ledVal);
		}

		read_command();

		ledVal = ~ledVal;

		xil_printf("PHY[0] REG 10 = %04X\r\n", mdiobb_read(2, 3, 0, 10));
		xil_printf("PHY[0] REG 17 = %04X\r\n", mdiobb_read(2, 3, 0, 17));
		xil_printf("PHY[1] REG 10 = %04X\r\n", mdiobb_read(2, 3, 1, 10));
		xil_printf("PHY[1] REG 17 = %04X\r\n", mdiobb_read(2, 3, 1, 17));

		XSpi_SetSlaveSelect(&spi, 1);
		uint8_t buf[6];
		buf[0] = 0x90;
		buf[1] = 0x00;
		buf[2] = 0x00;
		buf[3] = 0x00;
		buf[4] = 0x00;
		buf[5] = 0x00;
		XSpi_Transfer(&spi, buf, buf, 6);

		xil_printf("SPI ID %02X %02X\r\n", buf[4], buf[5]);
		xil_printf("BITSLIP %08X\r\n", Xil_In32(XPAR_SWITCH_REGS_0_S00_AXI_BASEADDR));

	} while(1);
}
