GHDL=ghdl
VERS="--std=08"
FLAG="--ieee=synopsys"

pipeadder: 
	@$(GHDL) -a $(VERS) fulladder.vhd add.vhd pipeadder.vhd pipeadder_tb.vhd
	@$(GHDL) -e $(VERS) pipeadder_tb
	@$(GHDL) -r $(VERS) pipeadder_tb --wave=pipeadder.ghw

clean:
	rm *_sim.out *.cf *.ghw