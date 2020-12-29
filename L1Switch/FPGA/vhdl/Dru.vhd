library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
library UNISIM;
    use UNISIM.vcomponents.all;

entity Dru is
    port (
        Clk_Half    : in  std_logic;                                       -- 625MHz clock
        RxData4X    : in  std_logic_vector(7 downto 0);                    -- Data from serdes (even bits are inverted, 4x oversampled)

        Clk_Quarter : in  std_logic;                                       -- 312.5 MHz clock
        BITSLIP     : in  std_logic;                                       -- Bitslip
        RxData      : out std_logic_vector(9 downto 0) := (others => '0'); -- 10-bit deserialized data out
        RxValid     : out std_logic                    := '0'              -- valid data out
    );
end Dru;

architecture rtl of Dru is

signal RxData4X_r         : std_logic_vector(7 downto 0) := (others => '0');
signal DataIn, cDataIn    : std_logic_vector(7 downto 0) := (others => '0');
signal DataIn7_r          : std_logic                    := '0';
signal Edge, cEdge        : std_logic_vector(3 downto 0) := (others => '0');
signal DataFast           : std_logic_vector(2 downto 0) := "000";   -- Data for a single fast clock cycle
signal DataFast2          : std_logic_vector(4 downto 0) := "00000"; -- Data for two fast clock cycles
signal DataFast_CNT       : unsigned(1 downto 0)         := "00";
signal EdgeState          : integer range 0 to 3         := 0;
signal DataFast_Edge_CNT  : std_logic_vector(1 downto 0) := "00";
signal cDataFast_Edge_CNT : std_logic_vector(DataFast_Edge_CNT'RANGE);
signal cDataFast_CNT      : unsigned(DataFast_CNT'RANGE);
signal DataFast2_CNT      : unsigned(2 downto 0)         := "000";

signal DataFast2_CNT_txdelay : unsigned(2 downto 0);
signal DataFast2_txdelay     : std_logic_vector(4 downto 0);

signal DataFastSlow       : std_logic_vector(4 downto 0) := "00000";
signal DataFastSlow_CNT   : unsigned(2 downto 0)         := "000";

signal DataSlow           : std_logic_vector(4 downto 0) := "00000";
signal DataSlow_CNT       : unsigned(2 downto 0)         := "000";
signal RxShift            : std_logic_vector(8 downto 0) := (others => '0');
signal Rx_CNT             : integer range 0 to 9         := 0;
signal T, T_r, T_p        : std_logic                    := '0';
signal BITSLIP_r          : std_logic                    := '0';

attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of rtl : architecture is "YES";
attribute USE_CLOCK_ENABLE : STRING;
attribute USE_CLOCK_ENABLE of DataFast2     : signal is "no";
attribute USE_CLOCK_ENABLE of DataFast2_CNT : signal is "no";

begin

--
-- Part 1: Edge detection
--
-- Note: LUT6_2 used to force combining of commented equations

-- cEdge(0)   <= (RxData4X_r(0) xnor RxData4X_r(1)) or (RxData4X_r(4) xnor RxData4X_r(5));
-- cDataIn(0) <= not RxData4X_r(0);
cEdge0_cDataIn0 : LUT6_2 generic map ( INIT => x"000055550000F99F" ) port map (I0 => RxData4X_r(0), I1 => RxData4X_r(1), I2 => RxData4X_r(4), I3 => RxData4X_r(5), I4 => '0', I5 => '1', O5 => cEdge(0), O6 => cDataIn(0));

-- cEdge(1)   <= (RxData4X_r(1) xnor RxData4X_r(2)) or (RxData4X_r(5) xnor RxData4X_r(6));
-- cDataIn(2) <= not RxData4X_r(2);
cEdge1_cDataIn2 : LUT6_2 generic map ( INIT => x"000033330000F99F" ) port map (I0 => RxData4X_r(1), I1 => RxData4X_r(2), I2 => RxData4X_r(5), I3 => RxData4X_r(6), I4 => '0', I5 => '1', O5 => cEdge(1), O6 => cDataIn(2));

-- cEdge(2)   <= (RxData4X_r(2) xnor RxData4X_r(3)) or (RxData4X_r(6) xnor RxData4X_r(7));
-- cDataIn(6) <= not RxData4X_r(6);
cEdge2_cDataIn6 : LUT6_2 generic map ( INIT => x"00000F0F0000F99F" ) port map (I0 => RxData4X_r(2), I1 => RxData4X_r(3), I2 => RxData4X_r(6), I3 => RxData4X_r(7), I4 => '0', I5 => '1', O5 => cEdge(2), O6 => cDataIn(6));

-- cEdge(3)   <= (RxData4X_r(3) xnor RxData4X_r(4)) or (DataIn(7) xnor RxData4X_r(0));
-- cDataIn(4) <= not RxData4X_r(4);
cEdge3_cDataIn4 : LUT6_2 generic map ( INIT => x"000033330000F99F" ) port map (I0 => RxData4X_r(3), I1 => RxData4X_r(4), I2 => DataIn(7),     I3 => RxData4X_r(0), I4 => '0', I5 => '1', O5 => cEdge(3), O6 => cDataIn(4));

-- Odd bits aren't inverted
cDataIn(1) <= RxData4X_r(1);
cDataIn(3) <= RxData4X_r(3);
cDataIn(5) <= RxData4X_r(5);
cDataIn(7) <= RxData4X_r(7);

process(Clk_Half)
begin
  if rising_edge(Clk_Half) then
    -- Register inputs/combinatorials
    RxData4X_r <= RxData4X;
    Edge       <= cEdge;
    DataIn     <= cDataIn;

    -- Last data bit may be needed one cycle later (for bit-slip extra bit)
    DataIn7_r  <= DataIn(7);
  end if;
end process;

--
-- Part 2: Data bit selection and edge tracking
--

cDataFast_Edge_CNT(0) <= '1' when EdgeState = 3 and Edge(3)='0' and Edge(2)='1' else '0';
cDataFast_Edge_CNT(1) <= '1' when EdgeState = 0 and Edge(3)='0' and Edge(0)='1' else '0';
cDataFast_CNT(0)      <= DataFast_Edge_CNT(0) or DataFast_Edge_CNT(1);
cDataFast_CNT(1)      <= not DataFast_Edge_CNT(0) or DataFast_Edge_CNT(1);

process (Clk_Half)
begin
  if rising_edge(Clk_Half) then
    DataFast_Edge_CNT <= cDataFast_Edge_CNT;
    DataFast_CNT      <= cDataFast_CNT;

    for N in 0 to 3 loop
      if EdgeState = N then
        if (Edge(N) = '1') then
          EdgeState <= (N + 3) mod 4;
        elsif Edge( (N + 3) mod 4 ) = '1' then
          EdgeState <= (N + 1) mod 4;
        end if;

        DataFast <= DataIn7_r & DataIn(N) & DataIn(N + 4);
      end if;
    end loop;

  end if;
end process;

--
-- Part 3: Accumulate two cycles of bits to move to the slower clock domain
--

-- Toggle a signal in the slower clock, used to align the two cycles of data acquired in the faster clock
T <= not T when rising_edge(Clk_Quarter);

process(Clk_Half)
begin
  if rising_edge(Clk_Half) then
    T_r <= T;
    T_p <= T_r xor T;
    if T_p = '1' then
      DataFast2_CNT <= RESIZE(DataFast_CNT, DataFast2_CNT'LENGTH);
      DataFast2     <= "00" & DataFast;
    else
      DataFast2_CNT <= DataFast2_CNT + RESIZE(DataFast_CNT, DataFast2_CNT'LENGTH);
      case DataFast_CNT is
        when "01"=>
          DataFast2 <= DataFast2(DataFast2'HIGH-1 downto DataFast2'LOW) & DataFast(0);

        when "11"=>
          DataFast2 <= DataFast2(DataFast2'HIGH-3 downto DataFast2'LOW) & DataFast(2 downto 0);

        when others =>
          DataFast2 <= DataFast2(DataFast2'HIGH-2 downto DataFast2'LOW) & DataFast(1 downto 0); -- Treat other cases as two bits (it really should always be 1, 2, or 3)
      end case;
    end if;
  end if;
end process;

-- Transport delays for simulation. Clocks are aligned, but the simulation may execute them in the wrong order otherwise
DataFast2_CNT_txdelay <= transport DataFast2_CNT after 1 ps;
DataFast2_txdelay     <= transport DataFast2 after 1 ps;

-- Move to slow clock domain. This is always expected to be the data from the second fast clock which contains two cycles worth of data
DataFastSlow_CNT <= DataFast2_CNT_txdelay when rising_edge(Clk_Quarter);
DataFastSlow     <= DataFast2_txdelay when rising_edge(Clk_Quarter);

--
-- Part 4: Accumulate 10-bit words
--

process(Clk_Quarter)
begin
  if rising_edge(Clk_Quarter) then
    -- Either 3, 4, or 5 bits should be available at this point (up to a single bitslip, as two should never happen back-to-back if our rates are close)
    -- Reduce this to two bits for the next state machine, taking the incoming BITSLIP to indicate we should drop a bit to synchronize the parallel data
    BITSLIP_r <= BITSLIP;

    if (BITSLIP_r = '1') then
      if (DataFastSlow_CNT < 4) then
        DataSlow_CNT <= "000";
      else
        DataSlow_CNT <= DataFastSlow_CNT - 3;
      end if;
    else
      if (DataFastSlow_CNT < 3) then
        DataSlow_CNT <= "000";
      else
        DataSlow_CNT <= DataFastSlow_CNT - 2;
      end if;
    end if;

    DataSlow <= DataFastSlow;

    RxValid  <= '0';
    for N in 1 to 3 loop
      if (DataSlow_CNT(1 downto 0) = N) then
        RxShift <= RxShift(RxShift'HIGH-(2+N) downto RxShift'LOW) & DataSlow(1+N downto 0);
        Rx_CNT   <= Rx_CNT + 2 + N;
        for X in 0 to 1+N loop
          if (Rx_CNT = X + (8-N)) then
            RxValid <= '1';
            RxData  <= RxShift(RxShift'HIGH-(1+N-X) downto RxShift'LOW) & DataSlow(1+N downto X);
            Rx_CNT  <= X;
          end if;
        end loop;
      end if;
    end loop;

  end if;
end process;

end rtl;
