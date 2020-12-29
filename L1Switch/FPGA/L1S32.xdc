
set_property INTERNAL_VREF 0.6 [get_iobanks 14]
set_property INTERNAL_VREF 0.6 [get_iobanks 15]
set_property INTERNAL_VREF 0.6 [get_iobanks 35]

# SGMII 0
set_property PACKAGE_PIN B7 [get_ports {RxD_p_pin[0]}]
set_property PACKAGE_PIN B6 [get_ports {RxD_p_pin[1]}]
set_property PACKAGE_PIN A5 [get_ports {RxD_p_pin[2]}]
set_property PACKAGE_PIN B4 [get_ports {RxD_p_pin[3]}]
set_property PACKAGE_PIN B2 [get_ports {RxD_p_pin[4]}]
set_property PACKAGE_PIN C1 [get_ports {RxD_p_pin[5]}]
set_property PACKAGE_PIN C3 [get_ports {RxD_p_pin[6]}]
set_property PACKAGE_PIN E2 [get_ports {RxD_p_pin[7]}]

set_property PACKAGE_PIN C7 [get_ports {TxD_p_pin[0]}]
set_property PACKAGE_PIN D6 [get_ports {TxD_p_pin[1]}]
set_property PACKAGE_PIN D4 [get_ports {TxD_p_pin[2]}]
set_property PACKAGE_PIN E3 [get_ports {TxD_p_pin[3]}]
set_property PACKAGE_PIN F5 [get_ports {TxD_p_pin[4]}]
set_property PACKAGE_PIN F4 [get_ports {TxD_p_pin[5]}]
set_property PACKAGE_PIN G5 [get_ports {TxD_p_pin[6]}]
set_property PACKAGE_PIN H5 [get_ports {TxD_p_pin[7]}]

# SGMII 1
set_property PACKAGE_PIN F2 [get_ports {RxD_p_pin[8]}]
set_property PACKAGE_PIN G2 [get_ports {RxD_p_pin[9]}]
set_property PACKAGE_PIN H2 [get_ports {RxD_p_pin[10]}]
set_property PACKAGE_PIN K1 [get_ports {RxD_p_pin[11]}]
set_property PACKAGE_PIN R5 [get_ports {RxD_p_pin[12]}]
set_property PACKAGE_PIN T7 [get_ports {RxD_p_pin[13]}]
set_property PACKAGE_PIN T9 [get_ports {RxD_p_pin[14]}]
set_property PACKAGE_PIN R10 [get_ports {RxD_p_pin[15]}]

set_property PACKAGE_PIN J5 [get_ports {TxD_p_pin[8]}]
set_property PACKAGE_PIN J3 [get_ports {TxD_p_pin[9]}]
set_property PACKAGE_PIN K3 [get_ports {TxD_p_pin[10]}]
set_property PACKAGE_PIN L3 [get_ports {TxD_p_pin[11]}]
set_property PACKAGE_PIN R6 [get_ports {TxD_p_pin[12]}]
set_property PACKAGE_PIN M6 [get_ports {TxD_p_pin[13]}]
set_property PACKAGE_PIN P8 [get_ports {TxD_p_pin[14]}]
set_property PACKAGE_PIN N9 [get_ports {TxD_p_pin[15]}]

# SGMII 2
set_property PACKAGE_PIN R12 [get_ports {RxD_p_pin[16]}]
set_property PACKAGE_PIN R13 [get_ports {RxD_p_pin[17]}]
set_property PACKAGE_PIN T14 [get_ports {RxD_p_pin[18]}]
set_property PACKAGE_PIN R15 [get_ports {RxD_p_pin[19]}]
set_property PACKAGE_PIN P15 [get_ports {RxD_p_pin[20]}]
set_property PACKAGE_PIN M16 [get_ports {RxD_p_pin[21]}]
set_property PACKAGE_PIN J15 [get_ports {RxD_p_pin[22]}]
set_property PACKAGE_PIN H16 [get_ports {RxD_p_pin[23]}]

set_property PACKAGE_PIN P10 [get_ports {TxD_p_pin[16]}]
set_property PACKAGE_PIN N11 [get_ports {TxD_p_pin[17]}]
set_property PACKAGE_PIN N13 [get_ports {TxD_p_pin[18]}]
set_property PACKAGE_PIN N14 [get_ports {TxD_p_pin[19]}]
set_property PACKAGE_PIN K13 [get_ports {TxD_p_pin[20]}]
set_property PACKAGE_PIN L14 [get_ports {TxD_p_pin[21]}]
set_property PACKAGE_PIN H11 [get_ports {TxD_p_pin[22]}]
set_property PACKAGE_PIN H12 [get_ports {TxD_p_pin[23]}]

# SGMII 3
set_property PACKAGE_PIN F15 [get_ports {RxD_p_pin[24]}]
set_property PACKAGE_PIN E16 [get_ports {RxD_p_pin[25]}]
set_property PACKAGE_PIN C16 [get_ports {RxD_p_pin[26]}]
set_property PACKAGE_PIN B15 [get_ports {RxD_p_pin[27]}]
set_property PACKAGE_PIN A13 [get_ports {RxD_p_pin[28]}]
set_property PACKAGE_PIN B12 [get_ports {RxD_p_pin[29]}]
set_property PACKAGE_PIN B10 [get_ports {RxD_p_pin[30]}]
set_property PACKAGE_PIN A8 [get_ports {RxD_p_pin[31]}]

set_property PACKAGE_PIN H14 [get_ports {TxD_p_pin[24]}]
set_property PACKAGE_PIN G14 [get_ports {TxD_p_pin[25]}]
set_property PACKAGE_PIN F12 [get_ports {TxD_p_pin[26]}]
set_property PACKAGE_PIN D14 [get_ports {TxD_p_pin[27]}]
set_property PACKAGE_PIN E11 [get_ports {TxD_p_pin[28]}]
set_property PACKAGE_PIN D8 [get_ports {TxD_p_pin[29]}]
set_property PACKAGE_PIN C8 [get_ports {TxD_p_pin[30]}]
set_property PACKAGE_PIN B9 [get_ports {TxD_p_pin[31]}]

set_property PACKAGE_PIN D13 [get_ports Clk_25_pin]

# PHY control
set_property PACKAGE_PIN M1 [get_ports {Phy_refclk_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Phy_refclk_pin[0]}]
set_property SLEW FAST [get_ports {Phy_refclk_pin[0]}]

set_property PACKAGE_PIN N1 [get_ports {Phy_refclk_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Phy_refclk_pin[1]}]
set_property SLEW FAST [get_ports {Phy_refclk_pin[1]}]

set_property PACKAGE_PIN P3 [get_ports {Phy_refclk_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Phy_refclk_pin[2]}]
set_property SLEW FAST [get_ports {Phy_refclk_pin[2]}]

set_property PACKAGE_PIN R2 [get_ports {Phy_refclk_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Phy_refclk_pin[3]}]
set_property SLEW FAST [get_ports {Phy_refclk_pin[3]}]

set_property PACKAGE_PIN M2 [get_ports PHY_RESET_N]
set_property IOSTANDARD LVCMOS33 [get_ports PHY_RESET_N]

set_property PACKAGE_PIN M4 [get_ports PHY_MDINT_N]
set_property IOSTANDARD LVCMOS33 [get_ports PHY_MDINT_N]

set_property PACKAGE_PIN L5 [get_ports PHY0_MDC]
set_property IOSTANDARD LVCMOS33 [get_ports PHY0_MDC]

set_property PACKAGE_PIN L4 [get_ports PHY0_MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports PHY0_MDIO]

set_property PACKAGE_PIN N3 [get_ports PHY1_MDC]
set_property IOSTANDARD LVCMOS33 [get_ports PHY1_MDC]

set_property PACKAGE_PIN N2 [get_ports PHY1_MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports PHY1_MDIO]

set_property PACKAGE_PIN P1 [get_ports PHY2_MDC]
set_property IOSTANDARD LVCMOS33 [get_ports PHY2_MDC]

set_property PACKAGE_PIN P4 [get_ports PHY2_MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports PHY2_MDIO]

set_property PACKAGE_PIN M5 [get_ports PHY3_MDC]
set_property IOSTANDARD LVCMOS33 [get_ports PHY3_MDC]

set_property PACKAGE_PIN N4 [get_ports PHY3_MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports PHY3_MDIO]

# Serial
set_property PACKAGE_PIN T4 [get_ports FPGA_RXD]
set_property IOSTANDARD LVCMOS33 [get_ports FPGA_RXD]

set_property PACKAGE_PIN T3 [get_ports FPGA_TXD]
set_property IOSTANDARD LVCMOS33 [get_ports FPGA_TXD]

# SPI Flash
set_property PACKAGE_PIN L12 [get_ports SPI_FLASH_SS]
set_property PACKAGE_PIN J13 [get_ports SPI_FLASH_IO0]
set_property PACKAGE_PIN J14 [get_ports SPI_FLASH_IO1]
set_property PACKAGE_PIN K15 [get_ports SPI_FLASH_IO2]
set_property PACKAGE_PIN K16 [get_ports SPI_FLASH_IO3]
set_property IOSTANDARD LVCMOS25 [get_ports SPI_FLASH_SS]
set_property IOSTANDARD LVCMOS25 [get_ports SPI_FLASH_IO0]
set_property IOSTANDARD LVCMOS25 [get_ports SPI_FLASH_IO1]
set_property IOSTANDARD LVCMOS25 [get_ports SPI_FLASH_IO2]
set_property IOSTANDARD LVCMOS25 [get_ports SPI_FLASH_IO3]


# Clocks

create_clock -period 40.000 -name test -waveform {0.000 20.000} [get_ports Clk_25_pin]

set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets clk25]

# The Reset constraint to the different hierarchical blocks.
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ */ena/*/C}] -to [get_cells * -hierarchical -filter {NAME =~ */Gen_1*.RX_DATA/* && REF_NAME != GND && REF_NAME != VCC && REF_NAME != IDELAYCTRL}] 3.200
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ */rst/*/C}] -to [get_cells * -hierarchical -filter {NAME =~ */Gen_1*.RX_DATA/* && REF_NAME != GND && REF_NAME != VCC && REF_NAME != IDELAYCTRL}] 3.200

# ISERDESE2 enable timing (goes to registers clocked at 1250MHz but we don't care about the relationship as it is enabled and left enabled)
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ */SgmiiRxData_I_Fdce/C}] -to [get_pins * -hierarchical -filter {NAME =~ */RX_MASTER/CE1}] 3.200
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ */SgmiiRxData_I_Fdce/C}] -to [get_pins * -hierarchical -filter {NAME =~ */RX_SLAVE/CE1}] 3.200

# Set time delay instead of using automatic clock edges or the tools will attempt to align both fast clocks (which is not possible)
# These are all set to 1.2 ns to account for possible clock skew/pessimism between 312.5 and 625
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ *RX_DRU/T_reg/C}] -to [get_pins * -hierarchical -filter {NAME =~ *RX_DRU/T_r_reg/D}] 1.200
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ *RX_DRU/T_reg/C}] -to [get_pins * -hierarchical -filter {NAME =~ *RX_DRU/T_p_reg/D}] 1.200
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ *RX_DRU/DataFast2_CNT_reg[*]/C}] -to [get_pins * -hierarchical -filter {NAME =~ *RX_DRU/DataFastSlow_CNT_reg[*]/D}] 1.200
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ *RX_DRU/DataFast2_reg[*]/C}] -to [get_pins * -hierarchical -filter {NAME =~ *RX_DRU/DataFastSlow_reg[*]/D}] 1.200

# Rx bitslip indicators for CPU monitoring (from 312.5 to 125)
set_max_delay -from [get_pins */*.bitslipToggle_reg*/C] -to [get_pins */bitslipToggle_r_reg*/D] 8.000

# Transmitter enables
set_max_delay -datapath_only -from [get_pins * -hierarchical -filter {NAME =~ */ena/*/C}] -to [get_pins */*.TxOut.OSERDESE2_inst_*/OCE] 8.000

#
# Layout constraints
#

# Block design is constrained to its own region that has no SGMII Rx/Tx
create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list BD.blockdesign]]
resize_pblock [get_pblocks pblock_1] -add {CLOCKREGION_X1Y0:CLOCKREGION_X1Y0}

# SGMII Rx is constrained to be near the IO for that bank
create_pblock pblock_2
add_cells_to_pblock [get_pblocks pblock_2] [get_cells -quiet [list SgmiiRx_Bank_14]]
resize_pblock [get_pblocks pblock_2] -add {SLICE_X0Y0:SLICE_X15Y49}
resize_pblock [get_pblocks pblock_2] -add {DSP48_X0Y0:DSP48_X0Y19}
resize_pblock [get_pblocks pblock_2] -add {RAMB18_X0Y0:RAMB18_X0Y19}
resize_pblock [get_pblocks pblock_2] -add {RAMB36_X0Y0:RAMB36_X0Y9}
create_pblock pblock_3
add_cells_to_pblock [get_pblocks pblock_3] [get_cells -quiet [list SgmiiRx_Bank_15]]
resize_pblock [get_pblocks pblock_3] -add {SLICE_X0Y50:SLICE_X15Y99}
resize_pblock [get_pblocks pblock_3] -add {DSP48_X0Y20:DSP48_X0Y39}
resize_pblock [get_pblocks pblock_3] -add {RAMB18_X0Y20:RAMB18_X0Y39}
resize_pblock [get_pblocks pblock_3] -add {RAMB36_X0Y10:RAMB36_X0Y19}
create_pblock pblock_4
add_cells_to_pblock [get_pblocks pblock_4] [get_cells -quiet [list SgmiiRx_Bank_35]]
resize_pblock [get_pblocks pblock_4] -add {SLICE_X48Y50:SLICE_X65Y99}
resize_pblock [get_pblocks pblock_4] -add {DSP48_X1Y20:DSP48_X1Y39}
resize_pblock [get_pblocks pblock_4] -add {RAMB18_X1Y20:RAMB18_X2Y39}
resize_pblock [get_pblocks pblock_4] -add {RAMB36_X1Y10:RAMB36_X2Y19}

