GHDL=ghdl
VERS="--std=08"
FLAG="--ieee=synopsys"

cpucontrol:
	@$(GHDL) -a $(VERS) cpucontrol.vhd cpucontrol_testbench.vhd
	@$(GHDL) -e $(VERS) cpucontrol_testbench
	@$(GHDL) -r $(VERS) cpucontrol_testbench --wave=cpucontrol.ghw