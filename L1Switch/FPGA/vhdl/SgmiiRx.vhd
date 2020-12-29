library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
library UNISIM;
    use UNISIM.vcomponents.all;
library work;
    use work.all;

entity SgmiiRx is
  generic (
    C_MmcmLoc           : string := "MMCME2_ADV_X0Y0";
    C_DataWidth         : integer := 2;
    C_IdlyCtrlLoc       : string := "IDELAYCTRL_X0Y0";
    C_IdlyCntVal_M      : std_logic_vector(4 downto 0) := "00000";
    C_IdlyCntVal_S      : std_logic_vector(4 downto 0) := "00011";
    C_RefClkFreq        : real := 310.00
  );
  port (
    RxD_p       : in  std_logic_vector(C_DataWidth-1 downto 0);
    RxD_n       : in  std_logic_vector(C_DataWidth-1 downto 0);
    RxClkIn     : in  std_logic;
    TxClkIn     : in  std_logic;
    RxRst       : in  std_logic;
    RxClk       : out std_logic;
    RxClkDiv    : out std_logic;
    RxData      : out std_logic_vector((C_DataWidth*10)-1 downto 0);
    RxBitslip   : out std_logic_vector(C_DataWidth - 1 downto 0)
  );
end SgmiiRx;

architecture impl of SgmiiRx is

component rx_data_fifo
  port (
    wr_clk        : in  std_logic;
    rd_clk        : in  std_logic;
    din           : in  std_logic_vector(19 downto 0);
    wr_en         : in  std_logic;
    rd_en         : in  std_logic;
    dout          : out std_logic_vector(19 downto 0);
    full          : out std_logic;
    empty         : out std_logic;
    wr_data_count : out std_logic_vector(4 downto 0)
  );
end component;

-- Signals
signal idelayRefClk       : std_logic; -- ~303MHz.
signal clk_Half           : std_logic; -- 625Mhz
signal clk_Half_90        : std_logic; -- 625Mhz 90 degrees phase shift
signal clk_Quarter        : std_logic; -- 312.5MHz
signal idelayCtrlRst      : std_logic;
signal mmcmReset          : std_logic;
signal mmcmEnable         : std_logic;
signal rxFIFORdEn         : std_logic := '0';
type EightBitArray is array (integer range <>) of std_logic_vector(7 downto 0);
signal dataToDRU          : EightBitArray(C_DataWidth-1 downto 0);
signal dataFromDRUValid   : std_logic_vector(C_DataWidth-1 downto 0);
signal dataFromDRUValid_r : std_logic_vector(C_DataWidth-1 downto 0);
signal rxComma            : std_logic_vector(C_DataWidth-1 downto 0);
signal I2                 : std_logic_vector(C_DataWidth-1 downto 0);
signal rxEven             : std_logic_vector(C_DataWidth-1 downto 0) := (others => '1');
type TenBitArray is array (integer range <>) of std_logic_vector(9 downto 0);
type TwentyBitArray is array (integer range <>) of std_logic_vector(19 downto 0);
signal dataFromDRU        : TenBitArray(C_DataWidth-1 downto 0);
signal dataFromDRU_r      : TenBitArray(C_DataWidth-1 downto 0);
signal dataFromDRU_r2     : TenBitArray(C_DataWidth-1 downto 0);
signal bitslip            : std_logic_vector(C_DataWidth-1 downto 0);
signal bitslipToggle      : std_logic_vector(C_DataWidth-1 downto 0);

signal bitslipToggle_r : std_logic_vector(C_DataWidth-1 downto 0);
signal bitslipToggle_r2 : std_logic_vector(C_DataWidth-1 downto 0);
type WriteDataCount_t is array (integer range <>) of std_logic_vector(4 downto 0);
signal writeDataCount : WriteDataCount_t(0 to C_DataWidth-1);

signal RxRawData_r   : std_logic_vector((C_DataWidth*8)-1 downto 0);

-- Attributes
attribute KEEP_HIERARCHY : string;
attribute KEEP_HIERARCHY of impl : architecture is "YES";
attribute MAXDELAY : string;
attribute MAXDELAY of dataToDRU : signal is "600ps";

begin

---------------------------------------------------------------------------------------------
-- Data reception and recovery
---------------------------------------------------------------------------------------------
Gen_1 : for n in 1 to C_DataWidth generate
  RX_DATA : entity work.SgmiiRxData
    generic map (
      C_IdlyCtrlLoc   => C_IdlyCtrlLoc,
      C_RefClkFreq    => C_RefClkFreq,
      C_IdlyCntVal_M  => C_IdlyCntVal_M,
      C_IdlyCntVal_S  => C_IdlyCntVal_S,
      C_NmbrOfInst    => (n)
    )
    port map (
      RxD_p       => RxD_p(n-1),
      RxD_n       => RxD_n(n-1),
      Clk0        => clk_Half,
      Clk90       => clk_Half_90,
      ClkDiv      => clk_Quarter,
      Rst         => mmcmReset,
      Ena         => mmcmEnable,
      RefClk      => idelayRefClk,
      IdlyCtrlRst => idelayCtrlRst,
      IsrdsRxData => dataToDRU(n-1)
    );

  RX_DRU : entity work.Dru
    port map (
      Clk_Half    => clk_Half,
      Clk_Quarter => clk_Quarter,
      BITSLIP     => bitslip(n-1),
      RxData4X    => dataToDRU(n-1),
      RxData      => dataFromDRU(n-1),
      RxValid     => dataFromDRUValid(n-1)
    );

  RX_ALIGN : entity work.Rx_Comma_Alignment
    port map (
      Clock         => clk_Quarter,
      Reset         => mmcmReset,
      Data_In_Valid => dataFromDRUValid(n-1),
      Data_In       => dataFromDRU(n-1),
      Comma         => rxComma(n-1),
      Bitslip       => bitslip(n-1)
    );

  Reg_Dru_Data : process(clk_Quarter)
  begin
    if rising_edge(clk_Quarter) then
      if (dataFromDRUValid(n-1) = '1') then
        dataFromDRU_r(n-1)  <= dataFromDRU(n-1);
        dataFromDRU_r2(n-1) <= dataFromDRU_r(n-1);

        -- Detect I2
        if (rxComma(n-1) = '1' and (dataFromDRU_r(n-1)(2 downto 0) = "010" or dataFromDRU_r(n-1)(2 downto 0) = "101") and
            (dataFromDRU(n-1) = "0110110101" or dataFromDRU(n-1) = "1001000101")) then
          I2(n-1) <= '1';
        else
          I2(n-1) <= '0';
        end if;

        -- Look for even word
        if (rxComma(n-1) = '1') then
          rxEven(n-1) <= '1';
        else
          rxEven(n-1) <= not rxEven(n-1);
        end if;
      end if;

      if (bitslip(n-1) = '1') then
        bitslipToggle(n-1) <= not bitslipToggle(n-1);
      end if;
    end if;
  end process;

  fifo : block
    signal dropIdle           : std_logic_vector(C_DataWidth-1 downto 0);
    signal insertIdle         : std_logic_vector(C_DataWidth-1 downto 0);
    signal rxDataToFIFO       : TwentyBitArray(C_DataWidth-1 downto 0);
    signal rxDataToFIFO_r     : TwentyBitArray(C_DataWidth-1 downto 0);
    signal rxDataFromFIFO     : TwentyBitArray(C_DataWidth-1 downto 0);
    signal rxFIFOWrEn         : std_logic_vector(C_DataWidth-1 downto 0);
    signal rxFIFOWrEn_r       : std_logic_vector(C_DataWidth-1 downto 0);
  begin
    insertIdle(n-1) <= '1' when I2(n-1) = '1' and unsigned(writeDataCount(n-1)) < 15 else '0';
    dropIdle(n-1)   <= '1' when I2(n-1) = '1' and unsigned(writeDataCount(n-1)) > 17 else '0';

    rxDataToFIFO(n-1) <= dataFromDRU_r2(n-1) & dataFromDRU_r(n-1);
    rxFIFOWrEn(n-1)   <= (dataFromDRUValid_r(n - 1) and rxEven(n-1) and not dropIdle(n-1)) or insertIdle(n-1);

    dataFromDRUValid_r(n-1) <= dataFromDRUValid(n-1) when rising_edge(clk_Quarter);
    rxDataToFIFO_r(n-1)     <= rxDataToFIFO(n-1) when rising_edge(clk_Quarter);
    rxFIFOWrEn_r(n-1)       <= rxFIFOWrEn(n-1) when rising_edge(clk_Quarter);

    rx_fifo : rx_data_fifo
      port map (
        wr_clk        => clk_Quarter,
        rd_clk        => TxClkIn,
        din           => rxDataToFIFO_r(n-1),
        wr_en         => rxFIFOWrEn_r(n - 1),
        rd_en         => rxFIFORdEn,
        dout          => rxDataFromFIFO(n-1),
        full          => open,
        empty         => open,
        wr_data_count => writeDataCount(n-1)
      );

    RxData(n*10 - 1 downto n*10 - 10) <= rxDataFromFIFO(n-1)(19 downto 10) when rxFIFORdEn = '0' else rxDataFromFIFO(n-1)(9 downto 0);
  end block;

end generate Gen_1;

Reg_Dru_Data : process(TxClkIn)
begin
  if rising_edge(TxClkIn) then
    rxFIFORdEn <= not rxFIFORdEn;

    bitslipToggle_r  <= bitslipToggle;
    bitslipToggle_r2 <= bitslipToggle_r;

    RxBitslip <= bitslipToggle_r xor bitslipToggle_r2;
  end if;
end process;

RxClk    <= clk_Half;
RxClkDiv <= clk_Quarter;

RX_CLK: entity work.SgmiiRxClock
  generic map (
    C_AppsMmcmLoc   => C_MmcmLoc
  )
  port map (
    Clk25In             => RxClkIn,
    Mmcm_RstIn          => RxRst,
    Mmcm_EnaIn          => '1',
    Clk_Idelay          => idelayRefClk, -- 310 MHz for IDELAYCTRL, BUFG
    Clk_625             => clk_Half,     -- 625 MHz, 00 phase, BUFG
    Clk_625_90          => clk_Half_90,  -- 625 MHz, 90 phase, BUFG
    Clk_312_5           => clk_Quarter,  -- 312.5 MHz, adjustable, BUFG
    Mmcm_Locked         => open,
    Mmcm_PrimRstOut     => idelayCtrlRst,
    Mmcm_RstOut         => mmcmReset,
    Mmcm_EnaOut         => mmcmEnable
  );

end impl;
