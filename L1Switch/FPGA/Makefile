project:
	vivado -mode batch -source L1S32.tcl

build:
	vivado -mode batch -source build.tcl

sim:
	vivado -mode batch -source RunSim.tcl

.PHONY: sim

L1S32.xpr: project

hwexport: L1S32.xpr
	rm -rf L1S32.sdk
	vivado -mode batch -source L1S32_export.tcl

L1S32_Top.xsa: hwexport

sdk: #L1S32_Top.xsa
	xsct L1S32_sdk.tcl


distclean:
	rm -rf L1S32.cache L1S32.srcs L1S32.runs L1S32.ioplanning L1S32.sdk L1S32.hw L1S32.sim L1S32.xpr L1S32.tmp *.jou *.log .Xil/ *.debug *.str *.dtsi hsi* L1S32.ip_user_files L1S32_Top.xsa L1S32.gen
