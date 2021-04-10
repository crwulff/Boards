library ieee;
use ieee.std_logic_1164.all;

entity ethernet_rx is
  port (
    clk125  : in  std_logic;
    rx_data : in  std_logic_vector(9 downto 0);
    tx_data : out std_logic_vector(9 downto 0)
  );
end ethernet_rx;

architecture impl of ethernet_rx is
  signal rxK : std_logic;
  signal rxD : std_logic_vector(7 downto 0);

  signal txK : std_logic;
  signal txD : std_logic_vector(7 downto 0);
begin
  dec : entity work.Decode8b10b
    port map (
      Clock => clk125,
      DI    => rx_data,
      KO    => rxK,
      DO    => rxD
    );

  sfd : block
    signal sfd_Detect : std_logic;
    signal sop        : std_logic := '0';
  begin

    process(clk125)
    begin
      if rising_edge(clk125) then
        if (rxK = '1' and rxD = x"fb") then
          sop <= '1';
        elsif (sfd_Detect = '1') then
          sop <= '0';
        end if;
      end if;
    end process;

    sfd_Detect <= '1' when (sop = '1' and rxD = x"d5") else '0';
  end block;

  txD <= rxD when rising_edge(clk125);
  txK <= rxK when rising_edge(clk125);

  enc : entity work.Encode8b10b
    port map (
      Clock => clk125,
      DI    => txD,
      KI    => txK,
      DO    => tx_data
    );

end architecture;
