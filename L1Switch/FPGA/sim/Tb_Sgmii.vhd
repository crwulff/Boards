library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library work;
    use work.L1S32_Top;

entity Tb_Sgmii is
end Tb_Sgmii;

architecture Behavioral of Tb_Sgmii is

  constant C_DataWidth : integer := 32;
  constant I2 : std_logic_vector(0 to 19) := "00111110100110110101"; -- K28.5 D16.2
  constant S  : std_logic_vector(0 to 9) := "1101101000"; -- K27.7
  constant T  : std_logic_vector(0 to 9) := "1011101000"; -- K29.7
  constant D0_0 : std_logic_vector(0 to 9) := "1001110100";

  constant PACKET_DATA : std_logic_vector(0 to 59) := I2 & I2 & I2; --& S & D0_0 & D0_0 & T;

  -- TB signals
  signal bitnum : integer := 0;

  -- DUT signals

  signal TxD_p_pin     : std_logic_vector(C_DataWidth-1 downto 0);
  signal TxD_n_pin     : std_logic_vector(C_DataWidth-1 downto 0);
  signal RxD_p_pin     : std_logic_vector(C_DataWidth-1 downto 0) := (others => '0');
  signal RxD_n_pin     : std_logic_vector(C_DataWidth-1 downto 0) := (others => '1');
  signal Clk_25_pin    : std_logic := '0';
  signal Phy_refclk_pin: std_logic_vector(3 downto 0);
  signal PHY_RESET_N   : std_logic;
  signal PHY_MDINT_N   : std_logic;
  signal PHY0_MDC      : std_logic;
  signal PHY0_MDIO     : std_logic;
  signal PHY1_MDC      : std_logic;
  signal PHY1_MDIO     : std_logic;
  signal PHY2_MDC      : std_logic;
  signal PHY2_MDIO     : std_logic;
  signal PHY3_MDC      : std_logic;
  signal PHY3_MDIO     : std_logic;
  signal FPGA_RXD      : std_logic;
  signal FPGA_TXD      : std_logic;

begin

Clk_25_pin <= not Clk_25_pin after 20 ns;

rx_bits : process
begin
  wait for 801 ps;
  RxD_p_pin <= (others => PACKET_DATA(bitnum));
  RxD_n_pin <= (others => not PACKET_DATA(bitnum));
  if (bitnum = PACKET_DATA'HIGH) then
    bitnum <= 0;
  else
    bitnum <= bitnum + 1;
  end if;
end process;

dut : entity work.L1S32_Top
    generic map (
      C_DataWidth => C_DataWidth
    )
  port map (
      TxD_p_pin      => TxD_p_pin,
      TxD_n_pin      => TxD_n_pin,
      RxD_p_pin      => RxD_p_pin,
      RxD_n_pin      => RxD_n_pin,
      Clk_25_pin     => Clk_25_pin,
      Phy_refclk_pin => Phy_refclk_pin,
      PHY_RESET_N    => PHY_RESET_N,
      PHY_MDINT_N    => PHY_MDINT_N,
      PHY0_MDC       => PHY0_MDC,
      PHY0_MDIO      => PHY0_MDIO,
      PHY1_MDC       => PHY1_MDC,
      PHY1_MDIO      => PHY1_MDIO,
      PHY2_MDC       => PHY2_MDC,
      PHY2_MDIO      => PHY2_MDIO,
      PHY3_MDC       => PHY3_MDC,
      PHY3_MDIO      => PHY3_MDIO,
      FPGA_RXD       => FPGA_RXD,
      FPGA_TXD       => FPGA_TXD
  );

end Behavioral;
