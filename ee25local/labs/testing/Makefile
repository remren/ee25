all: tutorial_nor.vhd tb_tutorial_nor.vhd
	GHDL=ghdl
	VERS="--std=08"
	FLAG="--ieee=synopsys"

	ghdl -a tutorial_nor.vhd tb_tutorial_nor.vhd
	ghdl -e tb_nor
	ghdl -r tb_nor --wave=wave=test.ghw

	--stop-time=1us