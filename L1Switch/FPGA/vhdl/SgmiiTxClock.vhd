library IEEE;
    use IEEE.std_logic_1164.all;
library UNISIM;
    use UNISIM.vcomponents.all;
library xpm;
    use xpm.vcomponents.all;

entity SgmiiTxClock is
  generic (
    C_AppsMmcmLoc   : string
  );
  port (
    Clk25In     : in  std_logic;
    Mmcm_RstIn  : in  std_Logic;
    Clk625      : out std_logic;
    Clk125      : out std_logic;
    Mmcm_Locked : out std_logic;
    Mmcm_RstOut : out std_logic;
    Mmcm_EnaOut : out std_logic
  );
end entity SgmiiTxClock;

architecture impl of SgmiiTxClock is

signal IntMmcm_Locked    : std_logic;
signal IntMmcm_Locked_n  : std_logic;
signal Mmcm_RstOut_int   : std_logic;
signal Mmcm_RstOut_int_n : std_logic;

signal clk625_int  : std_logic;
signal clk625_bufg : std_logic;
signal clk125_int  : std_logic;
signal clk125_bufg : std_logic;
signal clkFb       : std_logic;

attribute KEEP_HIERARCHY : string;
attribute KEEP_HIERARCHY of impl : architecture is "YES";

attribute LOC : string;
attribute LOC of TxGenClockMod_I_Mmcm_Adv : label is C_AppsMmcmLoc;

begin

TxGenClockMod_I_Mmcm_Adv : MMCME2_ADV
    generic map (
        BANDWIDTH               => "OPTIMIZED", -- string
        CLKIN1_PERIOD           => 40.0,        -- real --
        CLKIN2_PERIOD           => 0.0,         -- real
        REF_JITTER1             => 0.010,       -- real --
        REF_JITTER2             => 0.0,         -- real
        DIVCLK_DIVIDE           => 1,           -- integer  --
        CLKFBOUT_MULT_F         => 50.0,        -- real  --
        CLKFBOUT_PHASE          => 0.0,         -- real
        CLKFBOUT_USE_FINE_PS    => FALSE,       -- boolean
        CLKOUT0_DIVIDE_F        => 2.0,         -- real  --
        CLKOUT0_DUTY_CYCLE      => 0.5,         -- real
        CLKOUT0_PHASE           => 0.0,         -- real
        CLKOUT0_USE_FINE_PS     => FALSE,       -- boolean
        CLKOUT1_DIVIDE          => 10,          -- integer  --
        CLKOUT1_DUTY_CYCLE      => 0.5,         -- real
        CLKOUT1_PHASE           => 0.0,         -- real
        CLKOUT1_USE_FINE_PS     => FALSE,       -- boolean
        CLKOUT2_DIVIDE          => 4,           -- integer  --
        CLKOUT2_DUTY_CYCLE      => 0.5,         -- real
        CLKOUT2_PHASE           => 0.0,         -- real  --
        CLKOUT2_USE_FINE_PS     => FALSE,       -- boolean
        CLKOUT3_DIVIDE          => 4,           -- integer
        CLKOUT3_DUTY_CYCLE      => 0.5,         -- real
        CLKOUT3_PHASE           => 0.0,         -- real
        CLKOUT3_USE_FINE_PS     => FALSE,       -- boolean  --
        CLKOUT4_CASCADE         => FALSE,       -- boolean
        CLKOUT4_DIVIDE          => 4,           -- integer --
        CLKOUT4_DUTY_CYCLE      => 0.5,         -- real
        CLKOUT4_PHASE           => 0.0,         -- real
        CLKOUT4_USE_FINE_PS     => FALSE,       -- boolean  --
        CLKOUT5_DIVIDE          => 4,           -- integer
        CLKOUT5_DUTY_CYCLE      => 0.5,         -- real
        CLKOUT5_PHASE           => 0.0,         -- real
        CLKOUT5_USE_FINE_PS     => FALSE,       -- boolean
        CLKOUT6_DIVIDE          => 4,           -- integer
        CLKOUT6_DUTY_CYCLE      => 0.5,         -- real
        CLKOUT6_PHASE           => 0.0,         -- real
        CLKOUT6_USE_FINE_PS     => FALSE,       -- boolean
        COMPENSATION            => "ZHOLD",     -- string
        STARTUP_WAIT            => FALSE        -- boolean
    )
    port map (
        CLKIN1          => Clk25In,
        CLKIN2          => '0',
        CLKINSEL        => '1',
        CLKFBIN         => clkFb,
        CLKOUT0         => clk625_int,
        CLKOUT0B        => open,
        CLKOUT1         => clk125_int,
        CLKOUT1B        => open,
        CLKOUT2         => open,
        CLKOUT2B        => open,
        CLKOUT3         => open,
        CLKOUT3B        => open,
        CLKOUT4         => open,
        CLKOUT5         => open,
        CLKOUT6         => open,
        CLKFBOUT        => clkFb,
        CLKFBOUTB       => open,
        CLKINSTOPPED    => open,
        CLKFBSTOPPED    => open,
        LOCKED          => IntMmcm_Locked,
        PWRDWN          => '0',
        RST             => Mmcm_RstIn,
        DI              => x"0000",
        DADDR           => "0000000",
        DCLK            => '0',
        DEN             => '0',
        DWE             => '0',
        DO              => open,
        DRDY            => open,
        PSINCDEC        => '0',
        PSEN            => '0',
        PSCLK           => '0',
        PSDONE          => open
    );

BUFG625: BUFG port map (I => clk625_int, O => clk625_bufg);
BUFG125: BUFG port map (I => clk125_int, O => clk125_bufg);
--
Clk625 <= clk625_bufg;
Clk125 <= clk125_bufg;

Mmcm_Locked <= IntMmcm_Locked;
IntMmcm_Locked_n <= not IntMmcm_Locked;

-- Release reset two clocks after locked
rst : xpm_cdc_async_rst
  generic map (
    DEST_SYNC_FF => 2,
    INIT_SYNC_FF => 0,
    RST_ACTIVE_HIGH => 1
  )
  port map (
    src_arst  => IntMmcm_Locked_n,
    dest_clk  => clk125_bufg,
    dest_arst => Mmcm_RstOut_int
);
Mmcm_RstOut <= Mmcm_RstOut_int;

-- Use a reset macro to also enable two clocks after reset
Mmcm_RstOut_int_n <= not Mmcm_RstOut_int;
ena : xpm_cdc_async_rst
  generic map (
    DEST_SYNC_FF => 2,
    INIT_SYNC_FF => 0,
    RST_ACTIVE_HIGH => 0
  )
  port map (
    src_arst  => Mmcm_RstOut_int_n,
    dest_clk  => clk125_bufg,
    dest_arst => Mmcm_EnaOut
);

end impl;
