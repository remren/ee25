SIM_TOOL = ghdl
VERS="--std=08"
FLAG="--ieee=synopsys"

MUX5_FILES = mux5.vhd mux5_tb.vhd
MUX64_FILES = mux64.vhd mux64_tb.vhd
SHIFTLEFT2_FILES = shiftleft2.vhd shiftleft2_tb.vhd
SIGNEXTEND_FILES = signextend.vhd signextend_tb.vhd

MUX5:
	$(SIM_TOOL) -a $(VERS) $(FLAG) $(MUX5_FILES)
	$(SIM_TOOL) -e mux5_tb
	$(SIM_TOOL) -r mux5_tb --wave=wave=mux5_tb.ghw

MUX64:
	$(SIM_TOOL) -a $(VERS) $(FLAG) $(MUX64_FILES)
	$(SIM_TOOL) -e mux64_tb
	$(SIM_TOOL) -r mux64_tb --wave=wave=mux64_tb.ghw

SHIFTLEFT2:
	$(SIM_TOOL) -a $(VERS) $(FLAG) $(SHIFTLEFT2_FILES)
	$(SIM_TOOL) -e shiftleft2_tb
	$(SIM_TOOL) -r shiftleft2_tb --wave=wave=shiftleft2_tb.ghw
	
SIGNEXTEND:
	$(SIM_TOOL) -a $(VERS) $(FLAG) $(SIGNEXTEND_FILES)
	$(SIM_TOOL) -e signextend_tb
	$(SIM_TOOL) -r signextend_tb --wave=wave=signextend_tb.ghw