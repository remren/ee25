library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PipeCPU_testbench is
    -- empty, testbench.
end PipeCPU_testbench;

-- when your testbench is complete you should report error with severity failure.
-- this will end the simulation. Do not add stop times to the Makefile

architecture structural of PipeCPU_testbench is
    component PipelinedCPU0 is
        port(clk :in STD_LOGIC;
            rst :in STD_LOGIC;
            --Probe ports used for testing
            --The current address (AddressOut from the PC)
            DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
            --The current instruction (Instruction output of IMEM)
            DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
            --DEBUG ports from other components
            DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
            DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
            DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
        );
    end component;
    
        -- Signals for PipelinedCPU0
        signal clk, rst     : std_logic := '1';
        signal debug_pc     : std_logic_vector(63 downto 0);
        signal debug_inst   : std_logic_vector(31 downto 0);
        signal debug_tmpr   : std_logic_vector(64*4 - 1 downto 0);
        signal debug_savr   : std_logic_vector(64*4 - 1 downto 0);
        signal debug_dmem   : std_logic_vector(64*4 - 1 downto 0);

        constant cycle_time : time := 50 ns;
    
    begin
    
        pipelined_cpu_uut : PipelinedCPU0 port map(
            clk                 => clk,
            rst                 => rst,
            DEBUG_PC            => debug_pc,
            DEBUG_INSTRUCTION   => debug_inst,
            DEBUG_TMP_REGS      => debug_tmpr,
            DEBUG_SAVED_REGS    => debug_savr,
            DEBUG_MEM_CONTENTS  => debug_dmem
        );
    
    test_case : process
    begin
        -- *** [SANITY CHECKS]: General Tests *** --
            -- -- Check resetting for PC
            --     assert false report "pc_debug=" & to_hex_string(debug_pc) severity note;
            --     rst <= '1';
            --     wait for 1 ns;
            --     assert false report "pc_debug=" & to_hex_string(debug_pc) severity note;
    
            -- -- Check debug signals temp reg and saved reg for registers, should be all initial values.
            --     assert false report "reg_debugtemp=" & to_hex_string(debug_tmpr) severity note; 
            --     assert false report "reg_debugsave=" & to_hex_string(debug_savr) severity note; 
    
            -- -- Check initial IMEM state. IMEM's sensitivity only has PC Address.
            --     assert false report "imem_debug=" & to_hex_string(debug_inst) severity note;
            -- -- Check initial DMEM state. DMEM's sensitivity: Clock, MemRead, MemWrite, WriteData, Address
            --     assert false report "dmem_debug=" & to_hex_string(debug_dmem) severity note;
    
            -- -- Allow normal PC operation.
                clk <= '1';
                rst <= '1';
                wait for cycle_time;
                rst <= '0';
                wait for cycle_time;
    
        -- *** [PROGRAM TESTS] *** --
        
            report "// ... Beginning Program Tests ... ///" severity note;
            report "// ... Testing: [file] ... //" severity note;
            for i in 0 to 31 loop
                if (i mod 2 = 1) then
                    clk <= '0';
                    wait for cycle_time;
                    report "clock: High, " & to_string(i) severity note;
                else
                    clk <= '1';
                    wait for cycle_time;
                    report "clock: Low, " & to_string(i) severity note;
                end if;
            end loop;

            report "End of all cycles." severity failure;

            end process;
    end structural;