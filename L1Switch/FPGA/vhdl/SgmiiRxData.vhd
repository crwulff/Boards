library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
library UNISIM;
    use UNISIM.vcomponents.all;

entity SgmiiRxData is
  generic (
    C_IdlyCtrlLoc   : string := "IDELAYCTRL_X0Y0";
    C_RefClkFreq    : real := 310.00;
    C_IdlyCntVal_M  : std_logic_vector(4 downto 0) := "00000";
    C_IdlyCntVal_S  : std_logic_vector(4 downto 0) := "00011";
    C_NmbrOfInst    : integer
  );
  port (
    RxD_p         : in  std_logic;
    RxD_n         : in  std_logic;
    Clk0          : in  std_logic;
    Clk90         : in  std_logic;
    ClkDiv        : in  std_logic;
    Rst           : in  std_Logic;
    Ena           : in  std_logic;
    RefClk        : in  std_logic;
    IdlyCtrlRst   : in  std_logic;
    IsrdsRxData   : out std_logic_vector(7 downto 0)
  );
end SgmiiRxData;

architecture impl of SgmiiRxData is

signal IntClk0_n    : std_logic;
signal IntClk90_n   : std_logic;
signal IntDataIdlyToIsrds_M : std_logic;
signal IntDataIdlyToIsrds_S : std_logic;
signal IntEna       : std_logic;

attribute KEEP_HIERARCHY : string;
attribute KEEP_HIERARCHY of impl : architecture is "YES";

attribute LOC : string;

begin
-- Register the enable signal, synchronize with CLKDIV.
SgmiiRxData_I_Fdce : FDSE
  generic map (INIT => '0')
  port map (D => '0', CE => '1', C => ClkDiv, S => Ena, Q => IntEna);

IntClk0_n  <= not Clk0;
IntClk90_n <= not Clk90;

Gen_IdlyCtrl : if C_NmbrOfInst = 1 generate
  attribute LOC of SgmiiRxData_I_IdlyCtrl : label is C_IdlyCtrlLoc;
begin
  SgmiiRxData_I_IdlyCtrl : IDELAYCTRL
    port map (
      RST     => IdlyCtrlRst,
      REFCLK  => RefClk,
      RDY     => open
    );
end generate Gen_IdlyCtrl;

DELAY_MASTER : IDELAYE2
  generic map (
    IDELAY_TYPE             => "FIXED",
    IDELAY_VALUE            => to_integer(unsigned(C_IdlyCntVal_M)),
    HIGH_PERFORMANCE_MODE   => "TRUE",
    REFCLK_FREQUENCY        => C_RefClkFreq
  )
  port map (
    C           => '0',
    LD          => '0',
    LDPIPEEN    => '0',
    REGRST      => '0',
    CE          => '0',
    INC         => '0',
    CINVCTRL    => '0',
    CNTVALUEIN  => C_IdlyCntVal_M,
    IDATAIN     => RxD_p,
    DATAIN      => '0',
    DATAOUT     => IntDataIdlyToIsrds_M,
    CNTVALUEOUT => open
  );

DELAY_SLAVE : IDELAYE2
  generic map (
    IDELAY_TYPE             => "FIXED",
    IDELAY_VALUE            => to_integer(unsigned(C_IdlyCntVal_S)),
    HIGH_PERFORMANCE_MODE   => "TRUE",
    REFCLK_FREQUENCY        => C_RefClkFreq
  )
  port map (
    C           => '0',
    LD          => '0',
    LDPIPEEN    => '0',
    REGRST      => '0',
    CE          => '0',
    INC         => '0',
    CINVCTRL    => '0',
    CNTVALUEIN  => C_IdlyCntVal_S,
    IDATAIN     => RxD_n,
    DATAIN      => '0',
    DATAOUT     => IntDataIdlyToIsrds_S,
    CNTVALUEOUT => open
  );

RX_MASTER : ISERDESE2
  generic map (
    INTERFACE_TYPE      => "OVERSAMPLE",
    DATA_RATE           => "DDR",
    DATA_WIDTH          => 4,
    OFB_USED            => "FALSE",
    NUM_CE              => 1,
    SERDES_MODE         => "MASTER",
    IOBDELAY            => "IFD",
    DYN_CLKDIV_INV_EN   => "FALSE",
    DYN_CLK_INV_EN      => "FALSE",
    INIT_Q1             => '0',
    INIT_Q2             => '0',
    INIT_Q3             => '0',
    INIT_Q4             => '0',
    SRVAL_Q1            => '0',
    SRVAL_Q2            => '0',
    SRVAL_Q3            => '0',
    SRVAL_Q4            => '0'
  )
  port map (
    CLK             => Clk0,
    CLKB            => IntClk0_n,
    OCLK            => Clk90,
    OCLKB           => IntClk90_n,
    D               => '0',
    BITSLIP         => '0',
    CE1             => IntEna,
    CE2             => '1',
    CLKDIV          => '0',
    CLKDIVP         => '0',
    DDLY            => IntDataIdlyToIsrds_M,
    DYNCLKDIVSEL    => '0',
    DYNCLKSEL       => '0',
    OFB             => '0',
    RST             => Rst,
    SHIFTIN1        => '0',
    SHIFTIN2        => '0',
    O               => open,
    Q1              => IsrdsRxData(1),
    Q2              => IsrdsRxData(5),
    Q3              => IsrdsRxData(3),
    Q4              => IsrdsRxData(7),
    Q5              => open,
    Q6              => open,
    Q7              => open,
    Q8              => open,
    SHIFTOUT1       => open,
    SHIFTOUT2       => open
  );

RX_SLAVE : ISERDESE2
  generic map (
    INTERFACE_TYPE      => "OVERSAMPLE",
    DATA_RATE           => "DDR",
    DATA_WIDTH          => 4,
    OFB_USED            => "FALSE",
    NUM_CE              => 1,
    SERDES_MODE         => "MASTER",
    IOBDELAY            => "IFD",
    DYN_CLKDIV_INV_EN   => "FALSE",
    DYN_CLK_INV_EN      => "FALSE",
    INIT_Q1             => '0',
    INIT_Q2             => '0',
    INIT_Q3             => '0',
    INIT_Q4             => '0',
    SRVAL_Q1            => '0',
    SRVAL_Q2            => '0',
    SRVAL_Q3            => '0',
    SRVAL_Q4            => '0'
  )
  port map (
    CLK             => Clk0,
    CLKB            => IntClk0_n,
    OCLK            => Clk90,
    OCLKB           => IntClk90_n,
    D               => '0',
    BITSLIP         => '0',
    CE1             => IntEna,
    CE2             => '1',
    CLKDIV          => '0',
    CLKDIVP         => '0',
    DDLY            => IntDataIdlyToIsrds_S,
    DYNCLKDIVSEL    => '0',
    DYNCLKSEL       => '0',
    OFB             => '0',
    RST             => Rst,
    SHIFTIN1        => '0',
    SHIFTIN2        => '0',
    O               => open,
    Q1              => IsrdsRxData(0),
    Q2              => IsrdsRxData(4),
    Q3              => IsrdsRxData(2),
    Q4              => IsrdsRxData(6),
    Q5              => open,
    Q6              => open,
    Q7              => open,
    Q8              => open,
    SHIFTOUT1       => open,
    SHIFTOUT2       => open
  );

end impl;
