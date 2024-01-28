and2: and2.vhd and2_tb.vhd
	GHDL=ghdl
	VERS="--std=08"
	FLAG="--ieee=synopsys"

#	SIM_TOOL = ghdl and $(SIM_TOOL)

	ghdl -a and2.vhd and2_tb.vhd
	ghdl -e and2_tb
	ghdl -r and2_tb --wave=wave=and2_tb.ghw