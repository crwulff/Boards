set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
  if { [llength [get_objects]] > 0} {
    add_wave /
    set_property needs_save false [current_wave_config]
  } else {
     send_msg_id Add_Wave-1 WARNING "No top level signals found. Simulator will start without a wave window. If you want to open a wave window go to 'File->New Waveform Configuration' or type 'create_wave_config' in the TCL console."
  }
}

run 13us
# Simulation requires an edge on the ps clock for those MMCM clocks to start, but the phase adjust clock is used as the PsClk...
add_force {/Tb_Sgmii/dut/SgmiiLvds_Toplevel_I_Receiver_Bank_14/Receiver_I_RxGenClockMod/Mmcm_PsClk} -radix hex {1 0ns} -cancel_after 10ns
add_force {/Tb_Sgmii/dut/SgmiiLvds_Toplevel_I_Receiver_Bank_15/Receiver_I_RxGenClockMod/Mmcm_PsClk} -radix hex {1 0ns} -cancel_after 10ns
add_force {/Tb_Sgmii/dut/SgmiiLvds_Toplevel_I_Receiver_Bank_35/Receiver_I_RxGenClockMod/Mmcm_PsClk} -radix hex {1 0ns} -cancel_after 10ns
run 10us

