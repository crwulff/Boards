open_project L1S32.xpr

open_bd_design {./L1S32.srcs/sources_1/bd/design_1/design_1.bd}

generate_target synthesis [get_files {./L1S32.srcs/sources_1/bd/design_1/design_1.bd}]

update_compile_order -fileset sources_1

write_hw_platform -fixed -force -file ./L1S32_Top.xsa

close_bd_design [get_bd_designs design_1]
