library IEEE;
    use IEEE.std_logic_1164.all;
library UNISIM;
    use UNISIM.vcomponents.all;
library xpm;
    use xpm.vcomponents.all;

entity SgmiiRxClock is
  generic (
    C_AppsMmcmLoc   : string
  );
  port (
    Clk25In             : in std_logic;
    Mmcm_RstIn          : in std_Logic;
    Mmcm_EnaIn          : in std_Logic;
    Clk_Idelay          : out std_logic;
    Clk_625             : out std_logic;
    Clk_625_90          : out std_logic;
    Clk_312_5           : out std_logic;
    Mmcm_Locked         : out std_logic;
    Mmcm_PrimRstOut     : out std_Logic;
    Mmcm_RstOut         : out std_logic;
    Mmcm_EnaOut         : out std_logic
  );
end entity SgmiiRxClock;

architecture impl of SgmiiRxClock is

signal mmcm_Locked_int    : std_logic;
signal mmcm_Locked_int_n  : std_logic;
signal Mmcm_RstOut_int   : std_logic;
signal Mmcm_RstOut_int_n : std_logic;

signal clk_Fb               : std_logic;
signal clk_Idelay_int       : std_logic;
signal clk_Idelay_bufg      : std_logic;
signal clk_625_int          : std_logic;
signal clk_625_90_int       : std_logic;
signal clk_312_5_int        : std_logic;
signal clk_312_5_bufg       : std_logic;

attribute KEEP_HIERARCHY : string;
attribute KEEP_HIERARCHY of impl : architecture is "YES";

attribute LOC : string;
attribute LOC of MMCM : label is C_AppsMmcmLoc;

begin

MMCM : MMCME2_ADV
  generic map (
    BANDWIDTH               => "OPTIMIZED",
    CLKIN1_PERIOD           => 40.0,
    CLKIN2_PERIOD           => 0.0,
    REF_JITTER1             => 0.010,
    REF_JITTER2             => 0.0,
    DIVCLK_DIVIDE           => 1,
    CLKFBOUT_MULT_F         => 50.0,
    CLKFBOUT_PHASE          => 0.0,
    CLKFBOUT_USE_FINE_PS    => FALSE,
    CLKOUT0_DIVIDE_F        => 4.125,
    CLKOUT0_DUTY_CYCLE      => 0.5,
    CLKOUT0_PHASE           => 0.0,
    CLKOUT0_USE_FINE_PS     => FALSE,
    CLKOUT1_DIVIDE          => 2,
    CLKOUT1_DUTY_CYCLE      => 0.5,
    CLKOUT1_PHASE           => 0.0,
    CLKOUT1_USE_FINE_PS     => FALSE,
    CLKOUT2_DIVIDE          => 2,
    CLKOUT2_DUTY_CYCLE      => 0.5,
    CLKOUT2_PHASE           => 90.000,
    CLKOUT2_USE_FINE_PS     => FALSE,
    CLKOUT3_DIVIDE          => 4,
    CLKOUT3_DUTY_CYCLE      => 0.5,
    CLKOUT3_PHASE           => 0.0,
    CLKOUT3_USE_FINE_PS     => FALSE,
    CLKOUT4_CASCADE         => FALSE,
    CLKOUT4_DIVIDE          => 2,
    CLKOUT4_DUTY_CYCLE      => 0.5,
    CLKOUT4_PHASE           => 0.0,
    CLKOUT4_USE_FINE_PS     => FALSE,
    CLKOUT5_DIVIDE          => 4,
    CLKOUT5_DUTY_CYCLE      => 0.5,
    CLKOUT5_PHASE           => 0.0,
    CLKOUT5_USE_FINE_PS     => FALSE,
    CLKOUT6_DIVIDE          => 4,
    CLKOUT6_DUTY_CYCLE      => 0.5,
    CLKOUT6_PHASE           => 0.0,
    CLKOUT6_USE_FINE_PS     => FALSE,
    COMPENSATION            => "ZHOLD",
    STARTUP_WAIT            => FALSE
  )
  port map (
    CLKIN1          => Clk25In,
    CLKIN2          => '0',
    CLKINSEL        => '1',
    CLKFBIN         => clk_Fb,
    CLKOUT0         => clk_Idelay_int,
    CLKOUT0B        => open,
    CLKOUT1         => clk_625_int,
    CLKOUT1B        => open,
    CLKOUT2         => clk_625_90_int,
    CLKOUT2B        => open,
    CLKOUT3         => clk_312_5_int,
    CLKOUT3B        => open,
    CLKOUT4         => open,
    CLKOUT5         => open,
    CLKOUT6         => open,
    CLKFBOUT        => clk_Fb,
    CLKFBOUTB       => open,
    CLKINSTOPPED    => open,
    CLKFBSTOPPED    => open,
    LOCKED          => mmcm_Locked_int,
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

-- Clock buffers
BUFG_IDELAY:  BUFG  port map (I => clk_Idelay_int,       O => clk_Idelay_bufg);
BUFG_625:     BUFG  port map (I => clk_625_int,          O => Clk_625);
BUFG_625_90:  BUFG  port map (I => clk_625_90_int,       O => Clk_625_90);
BUFG_312_5:   BUFG  port map (I => clk_312_5_int,        O => clk_312_5_bufg);

Clk_Idelay <= clk_Idelay_bufg;
Clk_312_5  <= clk_312_5_bufg;

Mmcm_Locked      <= mmcm_Locked_int;
mmcm_Locked_int_n <= not mmcm_Locked_int;
Mmcm_PrimRstOut  <= mmcm_Locked_int_n;

-- Release reset two clocks after locked
rst : xpm_cdc_async_rst
  generic map (
    DEST_SYNC_FF => 2,
    INIT_SYNC_FF => 0,
    RST_ACTIVE_HIGH => 1
  )
  port map (
    src_arst  => mmcm_Locked_int_n,
    dest_clk  => clk_312_5_bufg,
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
    dest_clk  => clk_312_5_bufg,
    dest_arst => Mmcm_EnaOut
);

end impl;
