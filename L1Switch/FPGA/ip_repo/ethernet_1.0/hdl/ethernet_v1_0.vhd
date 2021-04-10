library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
    use work.all;

entity ethernet_v1_0 is
  generic (
    C_S_AXI_DATA_WIDTH  : integer  := 32;
    C_S_AXI_ADDR_WIDTH  : integer  := 4
  );
  port (
    rx_data : in std_logic_vector(9 downto 0);
    tx_data : out std_logic_vector(9 downto 0);

      -- AXI bus
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awprot  : in  std_logic_vector(2 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wstrb   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;
    s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arprot  : in  std_logic_vector(2 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic
  );
end ethernet_v1_0;

architecture arch_imp of ethernet_v1_0 is

signal rxD : std_logic_vector(7 downto 0);
signal rxK : std_logic;

begin

-- Instantiation of Axi Bus Interface S_AXI
ethernet_v1_0_S_AXI_inst : entity work.ethernet_v1_0_S_AXI
  generic map (
    C_S_AXI_DATA_WIDTH  => C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH  => C_S_AXI_ADDR_WIDTH
  )
  port map (
    S_AXI_ACLK    => s_axi_aclk,
    S_AXI_ARESETN => s_axi_aresetn,
    S_AXI_AWADDR  => s_axi_awaddr,
    S_AXI_AWPROT  => s_axi_awprot,
    S_AXI_AWVALID => s_axi_awvalid,
    S_AXI_AWREADY => s_axi_awready,
    S_AXI_WDATA   => s_axi_wdata,
    S_AXI_WSTRB   => s_axi_wstrb,
    S_AXI_WVALID  => s_axi_wvalid,
    S_AXI_WREADY  => s_axi_wready,
    S_AXI_BRESP   => s_axi_bresp,
    S_AXI_BVALID  => s_axi_bvalid,
    S_AXI_BREADY  => s_axi_bready,
    S_AXI_ARADDR  => s_axi_araddr,
    S_AXI_ARPROT  => s_axi_arprot,
    S_AXI_ARVALID => s_axi_arvalid,
    S_AXI_ARREADY => s_axi_arready,
    S_AXI_RDATA   => s_axi_rdata,
    S_AXI_RRESP   => s_axi_rresp,
    S_AXI_RVALID  => s_axi_rvalid,
    S_AXI_RREADY  => s_axi_rready
  );

  rx : entity work.ethernet_rx
    port map (
      clk125  => s_axi_aclk,
      rx_data => rx_data,
      tx_data => tx_data
    );

end arch_imp;
