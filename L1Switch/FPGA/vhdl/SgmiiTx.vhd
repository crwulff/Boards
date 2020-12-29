library IEEE;
    use IEEE.std_logic_1164.all;
library UNISIM;
    use UNISIM.vcomponents.all;
library work;
    use work.all;

entity SgmiiTx is
  generic (
    C_DataWidth     : integer := 2;
    C_AppsMmcmLoc   : string := "MMCME2_ADV_X0Y1"
  );
  port (
    TxClkIn      : in  std_logic;
    TxRstIn      : in  std_logic;
    TxDIn        : in  std_logic_vector(C_DataWidth*10 - 1 downto 0);
    TxMmcmLocked : out std_logic;
    TxClk        : out std_logic;
    TxD          : out std_logic_vector(C_DataWidth-1 downto 0)
  );
end SgmiiTx;

architecture impl of SgmiiTx is

signal IntTxSerClk : std_logic;
signal IntTxClk    : std_logic;
signal IntTxRst    : std_logic;
signal IntTxEna    : std_logic;
signal IntClkFbOut : std_logic;
signal IntClkFbIn  : std_logic;

attribute KEEP_HIERARCHY : string;
attribute KEEP_HIERARCHY of impl : architecture is "YES";

begin

Gen_1 : for n in 0 to C_DataWidth-1 generate
  TxOut : block
    signal ExtData1, ExtData2 : std_logic;
  begin
    OSERDESE2_inst_m : OSERDESE2
      generic map (
        DATA_RATE_OQ => "DDR", -- DDR, SDR
        DATA_RATE_TQ => "DDR", -- DDR, BUF, SDR
        DATA_WIDTH => 10, -- Parallel data width (2-8,10,14)
        INIT_OQ => '0', -- Initial value of OQ output (1'b0,1'b1)
        INIT_TQ => '0', -- Initial value of TQ output (1'b0,1'b1)
        SERDES_MODE => "MASTER", -- MASTER, SLAVE
        SRVAL_OQ => '0', -- OQ output value when SR is used (1'b0,1'b1)
        SRVAL_TQ => '0', -- TQ output value when SR is used (1'b0,1'b1)
        TBYTE_CTL => "FALSE", -- Enable tristate byte operation (FALSE, TRUE)
        TBYTE_SRC => "FALSE", -- Tristate byte source (FALSE, TRUE)
        TRISTATE_WIDTH => 1 -- 3-state converter width (1,4)
      )
      port map (
        OFB       => open,   -- 1-bit output: Feedback path for data
        OQ        => TxD(n), -- 1-bit output: Data path output
        -- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
        SHIFTOUT1 => open,
        SHIFTOUT2 => open,
        TBYTEOUT  => open,   -- 1-bit output: Byte group tristate
        TFB       => open,   -- 1-bit output: 3-state control
        TQ        => open,   -- 1-bit output: 3-state control
        CLK       => IntTxSerClk, -- 1-bit input: High speed clock
        CLKDIV    => IntTxClk,    -- 1-bit input: Divided clock
        -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
        D1        => TxDIn(n*10 + 9),
        D2        => TxDIn(n*10 + 8),
        D3        => TxDIn(n*10 + 7),
        D4        => TxDIn(n*10 + 6),
        D5        => TxDIn(n*10 + 5),
        D6        => TxDIn(n*10 + 4),
        D7        => TxDIn(n*10 + 3),
        D8        => TxDIn(n*10 + 2),
        OCE       => IntTxEna, -- 1-bit input: Output data clock enable
        RST       => IntTxRst, -- 1-bit input: Reset
        -- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
        SHIFTIN1  => ExtData1,
        SHIFTIN2  => ExtData2,
        -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
        T1        => '0',
        T2        => '0',
        T3        => '0',
        T4        => '0',
        TBYTEIN   => '0', -- 1-bit input: Byte group tristate
        TCE       => '0' -- 1-bit input: 3-state clock enable
      );
    OSERDESE2_inst_s : OSERDESE2
      generic map (
        DATA_RATE_OQ => "DDR", -- DDR, SDR
        DATA_RATE_TQ => "DDR", -- DDR, BUF, SDR
        DATA_WIDTH => 10, -- Parallel data width (2-8,10,14)
        INIT_OQ => '0', -- Initial value of OQ output (1'b0,1'b1)
        INIT_TQ => '0', -- Initial value of TQ output (1'b0,1'b1)
        SERDES_MODE => "SLAVE", -- MASTER, SLAVE
        SRVAL_OQ => '0', -- OQ output value when SR is used (1'b0,1'b1)
        SRVAL_TQ => '0', -- TQ output value when SR is used (1'b0,1'b1)
        TBYTE_CTL => "FALSE", -- Enable tristate byte operation (FALSE, TRUE)
        TBYTE_SRC => "FALSE", -- Tristate byte source (FALSE, TRUE)
        TRISTATE_WIDTH => 1 -- 3-state converter width (1,4)
      )
      port map (
        OFB       => open,   -- 1-bit output: Feedback path for data
        OQ        => open,   -- 1-bit output: Data path output
        -- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
        SHIFTOUT1 => ExtData1,
        SHIFTOUT2 => ExtData2,
        TBYTEOUT  => open,   -- 1-bit output: Byte group tristate
        TFB       => open,   -- 1-bit output: 3-state control
        TQ        => open,   -- 1-bit output: 3-state control
        CLK       => IntTxSerClk, -- 1-bit input: High speed clock
        CLKDIV    => IntTxClk,    -- 1-bit input: Divided clock
        -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
        D1        => '0',
        D2        => '0',
        D3        => TxDIn(n*10 + 1),
        D4        => TxDIn(n*10 + 0),
        D5        => '0',
        D6        => '0',
        D7        => '0',
        D8        => '0',
        OCE       => IntTxEna, -- 1-bit input: Output data clock enable
        RST       => IntTxRst, -- 1-bit input: Reset
        -- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
        SHIFTIN1  => '0',
        SHIFTIN2  => '0',
        -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
        T1        => '0',
        T2        => '0',
        T3        => '0',
        T4        => '0',
        TBYTEIN   => '0', -- 1-bit input: Byte group tristate
        TCE       => '0' -- 1-bit input: 3-state clock enable
      );
  end block;
end generate;

TxClk <= IntTxClk;

IntClkFbIn <= IntClkFbOut;
TX_CLK : entity work.SgmiiTxClock
  generic map (
    C_AppsMmcmLoc   => C_AppsMmcmLoc
  )
  port map (
    Clk25In             => TxClkIn, -- in
    Mmcm_RstIn          => TxRstIn, -- in
    Clk625              => IntTxSerClk, -- out -- 625 MHz
    Clk125              => IntTxClk,    -- out -- 125 MHz
    Mmcm_Locked         => TxMmcmLocked, -- out
    Mmcm_RstOut         => IntTxRst, -- out
    Mmcm_EnaOut         => IntTxEna  -- out
  );

end impl;
