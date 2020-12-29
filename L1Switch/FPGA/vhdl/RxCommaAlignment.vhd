library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

library unisim;
    use unisim.vcomponents.all;

entity Rx_Comma_Alignment is
port (
    Clock         : in  std_logic;
    Reset         : in  std_logic;
    Data_In_Valid : in  std_logic;
    Data_In       : in  std_logic_vector(9 downto 0);

    Comma         : out std_logic;
    Bitslip       : out std_logic
);
end Rx_Comma_Alignment;

architecture imp of Rx_Comma_Alignment is

 signal    comma_Position   : std_logic_vector(9 downto 0);
 signal    comma_Misaligned : boolean;
 signal    data_r           : std_logic_vector(9 downto 0);
 signal    data             : std_logic_vector(19 downto 0);
 signal    timer            : unsigned(4 downto 0);
 signal    timer_Expired    : boolean;
 signal    bitslip_Now      : std_logic;
 signal    bitslip_Now_r    : std_logic;
 signal    data_In_Valid_r  : std_logic;

begin

-- register the input data
process (Clock)
begin
   if rising_edge(Clock) then
    if (Reset = '1') then
      data_r <= (others => '0');
    elsif (Data_In_Valid = '1') then
      data_r <= Data_In;
    end if;
  end if;
end process;

-- detect comma position
data <= data_r & Data_In;
Commaect : for i in 0 to 9 generate
  comma_Position(i) <= '1' when (data(i+9 downto i+3) = "0011111" or data(i+9 downto i+3) = "1100000") else '0';
end generate;
comma_Misaligned <= (comma_Position(9 downto 1) /= "000000000") when rising_edge(Clock);

data_In_Valid_r <= Data_In_Valid when rising_edge(Clock);

-- Single pulse bit-slip when misaligned and the timer has expired
bitslip_Now   <= '1' when (Reset = '0' and data_In_Valid_r = '1' and comma_Misaligned and timer_Expired) else '0';
bitslip_Now_r <= bitslip_Now when rising_edge(Clock);
Bitslip       <= bitslip_Now and not bitslip_Now_r;

-- Timer to limit how fast we slip bits
process (Clock)
begin
  if rising_edge(Clock) then
    if (Reset = '1' or bitslip_Now = '1') then
      timer         <= (others => '0');
      timer_Expired <= false;
    else
      if timer = "11111" then
        timer_Expired <= true;
      else
        timer <= timer + 1;
      end if;
    end if;
  end if;
end process;

Comma <= comma_Position(0) when rising_edge(Clock);

end imp;
