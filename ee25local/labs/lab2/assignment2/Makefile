GHDL=ghdl
VERS="--std=08"
FLAG="--ieee=synopsys"

# IMPORTANT: do not change the names of the testbench files or entities here
# instead, ensure that YOUR testbench files and entity names match the ones here
# follow the TODO's

provide:
	provide ee25 lab2 fulladder.vhd add.vhd alu.vhd alucontrol.vhd registers.vhd dmem.vhd Makefile EE25_lab2.pdf

add:
	@$(GHDL) -a $(VERS) fulladder.vhd add.vhd add_testbench.vhd
	@$(GHDL) -e $(VERS) add_testbench
	@$(GHDL) -r $(VERS) add_testbench --wave=add.ghw

alu:
	@$(GHDL) -a $(VERS) alu.vhd alu_testbench.vhd	
	@$(GHDL) -e $(VERS) alu_testbench
	@$(GHDL) -r $(VERS) alu_testbench --wave=alu.ghw

alu-control:
	@$(GHDL) -a $(VERS) alucontrol.vhd alu_control_testbench.vhd	
	@$(GHDL) -e $(VERS) alu_control_testbench
	@$(GHDL) -r $(VERS) alu_control_testbench --wave=alu_control.ghw

registers:
	@$(GHDL) -a $(VERS) registers.vhd registers_testbench.vhd
	@$(GHDL) -e $(VERS) registers_testbench
	@$(GHDL) -r $(VERS) registers_testbench --wave=registers.ghw

dmem:
	@$(GHDL) -a $(VERS) dmem.vhd dmem_testbench.vhd
	@$(GHDL) -e $(VERS) dmem_testbench
	@$(GHDL) -r $(VERS) dmem_testbench --wave=dmem.ghw

clean:
	rm *_sim.out *.cf *.ghw