if {![catch {open "/proc/cpuinfo"} f]} {
  set cores [expr [regexp -all -line {^processor\s} [read $f]] * 3 / 4]
  close $f
  if {$cores < 6} {
    set cores 6
  }
}

puts "Running with $cores."

open_project L1S32.xpr
update_compile_order -fileset sources_1
reset_run impl_1
reset_run synth_1
set_param general.maxThreads 8
launch_runs impl_1 -to_step write_bitstream -jobs $cores
wait_on_run synth_1
wait_on_run impl_1

