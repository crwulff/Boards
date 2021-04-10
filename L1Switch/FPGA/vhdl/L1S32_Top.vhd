library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
library UNISIM;
    use UNISIM.vcomponents.all;
library work;
    use work.all;

entity L1S32_Top is
  generic (C_DataWidth : integer := 32);
  port (
    TxD_p_pin     : out   std_logic_vector(C_DataWidth-1 downto 0);
    TxD_n_pin     : out   std_logic_vector(C_DataWidth-1 downto 0);
    RxD_p_pin     : in    std_logic_vector(C_DataWidth-1 downto 0);
    RxD_n_pin     : in    std_logic_vector(C_DataWidth-1 downto 0);
    Clk_25_pin    : in    std_logic;
    Phy_refclk_pin: out   std_logic_vector(3 downto 0);
    PHY_RESET_N   : inout std_logic;
    PHY_MDINT_N   : inout std_logic;
    PHY0_MDC      : inout std_logic;
    PHY0_MDIO     : inout std_logic;
    PHY1_MDC      : inout std_logic;
    PHY1_MDIO     : inout std_logic;
    PHY2_MDC      : inout std_logic;
    PHY2_MDIO     : inout std_logic;
    PHY3_MDC      : inout std_logic;
    PHY3_MDIO     : inout std_logic;
    FPGA_RXD      : in    std_logic;
    FPGA_TXD      : out   std_logic;

    -- QSPI
    SPI_FLASH_IO0 : inout std_logic;
    SPI_FLASH_IO1 : inout std_logic;
    SPI_FLASH_IO2 : inout std_logic;
    SPI_FLASH_IO3 : inout std_logic;
    SPI_FLASH_SS  : inout std_logic
  );
end L1S32_Top;

architecture impl of L1S32_Top is

constant C_Banks     : integer := 3;
constant C_CpuPorts  : integer := 1;
constant C_RouteWidth: integer := 13; -- 1 bit valid + 6 bits source + 6 bits dest

signal clk25         : std_logic;
signal clk125        : std_logic;
signal rxD_p         : std_logic_vector(C_DataWidth-1 downto 0);
signal rxD_n         : std_logic_vector(C_DataWidth-1 downto 0);
signal txD           : std_logic_vector(C_DataWidth-1 downto 0);
signal reset         : std_logic := '0';

signal txMmcmLocked  : std_logic;
signal rxClk         : std_logic_vector(C_Banks - 1 downto 0);
signal rxClkDiv      : std_logic_vector(C_Banks - 1 downto 0);
signal rxData10b     : std_logic_vector((C_DataWidth*10)-1 downto 0);
signal rxData10b_r   : std_logic_vector(((C_DataWidth+C_CpuPorts)*10)-1 downto 0);
signal routedData10b : std_logic_vector(((C_DataWidth+C_CpuPorts)*10)-1 downto 0);

signal bitslip       : std_logic_vector(C_DataWidth - 1 downto 0);

subtype src_t is integer range 0 to (C_DataWidth + C_CpuPorts - 1);
type route_t is array (0 to (C_DataWidth + C_CpuPorts) - 1) of src_t;
signal routes : route_t;
signal routeWrite    : std_logic_vector(C_RouteWidth-1 downto 0);
signal routeWrite_r  : std_logic_vector(C_RouteWidth-1 downto 0);
signal routeWrite_r2 : std_logic_vector(C_RouteWidth-1 downto 0);

signal GPIO_0_tri_io : std_logic_vector(9 downto 0);

signal cpuTxData : std_logic_vector(9 downto 0);

begin

---------------------------------------------------------------------------------------------
-- In- and outputs.
---------------------------------------------------------------------------------------------
CLK25_IBUF : IBUF
  generic map (IBUF_LOW_PWR => FALSE, IOSTANDARD => "LVCMOS25")
  port map (I => Clk_25_pin, O => clk25);

GenRefClk : for n in 0 to 3 generate
  RefClkOut : ODDR
    generic map (DDR_CLK_EDGE => "SAME_EDGE")
    port map (C => clk125, CE => '1', R => '0', S => '0',
              D1 => '1', D2 => '0', Q => Phy_refclk_pin(n));
end generate;

Gen_1 : for n in 0 to C_DataWidth-1 generate
  RX_IBUFDS : IBUFDS_DIFF_OUT
    generic map (IBUF_LOW_PWR => FALSE, DIFF_TERM => TRUE, IOSTANDARD => "LVDS_25")
    port map (I => RxD_p_pin(n), IB => RxD_n_pin(n), O => rxD_p(n), OB  => rxD_n(n));

  TX_OBUFDS : OBUFDS
    generic map (IOSTANDARD => "LVDS_25")
    port map (I => txD(n), O => TxD_p_pin(n), OB => TxD_n_pin(n));
end generate Gen_1;
--

BD : if true generate -- disable to speed up simulation
blockdesign : entity work.design_1_wrapper
  port map (
    GPIO_0_tri_io        => GPIO_0_tri_io,
    SPI_0_0_io0_io       => SPI_FLASH_IO0,
    SPI_0_0_io1_io       => SPI_FLASH_IO1,
    SPI_0_0_io2_io       => SPI_FLASH_IO2,
    SPI_0_0_io3_io       => SPI_FLASH_IO3,
    SPI_0_0_ss_io(0)     => SPI_FLASH_SS,
    STARTUP_IO_0_cfgclk  => open,
    STARTUP_IO_0_cfgmclk => open,
    STARTUP_IO_0_eos     => open,
    STARTUP_IO_0_preq    => open,
    UART_0_rxd           => FPGA_RXD,
    UART_0_txd           => FPGA_TXD,
    clk_25               => clk25,
    clk_125              => clk125,
    clk_125_good         => txMmcmLocked,
    GPIO2_0_tri_o        => routeWrite,
    Bitslip              => bitslip,
    tx_data_0            => cpuTxData,
    rx_data_0            => routedData10b(C_DataWidth*10+9 downto C_DataWidth*10)
  );
end generate;

PHY_RESET_N <= GPIO_0_tri_io(0);
GPIO_0_tri_io(1) <= PHY_MDINT_N;
PHY0_MDC <= GPIO_0_tri_io(2);
PHY0_MDIO <= GPIO_0_tri_io(3);
PHY1_MDC  <= GPIO_0_tri_io(4);
PHY1_MDIO <= GPIO_0_tri_io(5);
PHY2_MDC  <= GPIO_0_tri_io(6);
PHY2_MDIO <= GPIO_0_tri_io(7);
PHY3_MDC  <= GPIO_0_tri_io(8);
PHY3_MDIO <= GPIO_0_tri_io(9);

---------------------------------------------------------------------------------------------
-- SGMII Transmitter
---------------------------------------------------------------------------------------------
SgmiiTx : entity work.SgmiiTx
  generic map (
    C_DataWidth     => C_DataWidth,
    C_AppsMmcmLoc   => "MMCME2_ADV_X1Y0"
  )
  port map (
    TxClkIn         => clk25,
    TxRstIn         => reset,
    TxDIn           => routedData10b(C_DataWidth*10-1 downto 0),
    TxMmcmLocked    => txMmcmLocked,
    TxClk           => clk125,
    TxD             => txD
  );

rxData10b_r   <= cpuTxData & rxData10b when rising_edge(clk125);
routeWrite_r  <= routeWrite when rising_edge(clk125);
routeWrite_r2 <= routeWrite_r when rising_edge(clk125);

Gen_Routes : for n in 0 to (C_DataWidth+C_CpuPorts)-1 generate

  route : process(clk125)
  begin
    if rising_edge(clk125) then
      routedData10b(n*10 + 9 downto n*10) <= rxData10b_r(routes(n)*10 + 9 downto routes(n)*10);

      if (routeWrite_r2(10) = '1' and to_integer(unsigned(routeWrite_r2(9 downto 5))) = n) then
        routes(n) <= to_integer(unsigned(routeWrite_r2(4 downto 0)));
      end if;
    end if;
  end process;

end generate;

---------------------------------------------------------------------------------------------
-- SGMII-LVDS Receiver
---------------------------------------------------------------------------------------------
SgmiiRx_Bank_35 : entity work.SgmiiRx
  generic map (
    C_MmcmLoc           => "MMCME2_ADV_X1Y1",
    C_DataWidth         => 12,
    C_IdlyCtrlLoc       => "IDELAYCTRL_X1Y1",
    C_IdlyCntVal_M      => "00000",
    C_IdlyCntVal_S      => "00011",
    C_RefClkFreq        => 303.00
  )
  port map (
    RxD_p       => rxD_p(11 downto 0),
    RxD_n       => rxD_n(11 downto 0),
    RxClkIn     => clk25,
    TxClkIn     => clk125,
    RxRst       => reset,
    RxClk       => rxClk(0),
    RxClkDiv    => rxClkDiv(0),
    RxData      => rxData10b(12*10-1 downto 0),
    RxBitslip   => bitslip(11 downto 0)
  );
SgmiiRx_Bank_14 : entity work.SgmiiRx
  generic map (
    C_MmcmLoc           => "MMCME2_ADV_X0Y0",
    C_DataWidth         => 10,
    C_IdlyCtrlLoc       => "IDELAYCTRL_X0Y0",
    C_IdlyCntVal_M      => "00000",
    C_IdlyCntVal_S      => "00011",
    C_RefClkFreq        => 303.00
  )
  port map (
    RxD_p       => rxD_p(21 downto 12),
    RxD_n       => rxD_n(21 downto 12),
    RxClkIn     => clk25,
    TxClkIn     => clk125,
    RxRst       => reset,
    RxClk       => rxClk(1),
    RxClkDiv    => rxClkDiv(1),
    RxData      => rxData10b(22*10-1 downto 12*10),
    RxBitslip   => bitslip(21 downto 12)
  );
SgmiiRx_Bank_15 : entity work.SgmiiRx
  generic map (
    C_MmcmLoc           => "MMCME2_ADV_X0Y1",
    C_DataWidth         => 10,
    C_IdlyCtrlLoc       => "IDELAYCTRL_X0Y1",
    C_IdlyCntVal_M      => "00000",
    C_IdlyCntVal_S      => "00011",
    C_RefClkFreq        => 303.00
  )
  port map (
    RxD_p       => rxD_p(31 downto 22),
    RxD_n       => rxD_n(31 downto 22),
    RxClkIn     => clk25,
    TxClkIn     => clk125,
    RxRst       => reset,
    RxClk       => rxClk(2),
    RxClkDiv    => rxClkDiv(2),
    RxData      => rxData10b(32*10-1 downto 22*10),
    RxBitslip   => bitslip(31 downto 22)
  );

end impl;
