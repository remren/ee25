library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity PipeCPU_testbench is
    -- empty, testbench.
end PipeCPU_testbench;

-- when your testbench is complete you should report error with severity failure.
-- this will end the simulation. Do not add stop times to the Makefile

architecture structural of PipeCPU_testbench is
    component PipelinedCPU1 is
        port(
            clk : in std_logic;
            rst : in std_logic;
            --Probe ports used for testing
            -- Forwarding control signals
            DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
            DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
            --The current address (AddressOut from the PC)
            DEBUG_PC : out std_logic_vector(63 downto 0);
            --Value of PC.write_enable
            DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
            --The current instruction (Instruction output of IMEM)
            DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
            --DEBUG ports from other components
            DEBUG_TMP_REGS : out std_logic_vector(64*4-1 downto 0);
            DEBUG_SAVED_REGS : out std_logic_vector(64*4-1 downto 0);
            DEBUG_MEM_CONTENTS : out std_logic_vector(64*4-1 downto 0)
        );
    end component;
    
        -- Signals for PipelinedCPU1
        signal clk, rst              : std_logic := '1';
        signal debug_forward_a       : std_logic_vector(1 downto 0);
        signal debug_forward_b       : std_logic_vector(1 downto 0);
        signal debug_pc              : std_logic_vector(63 downto 0);
        signal debug_pc_write_enable : std_logic := '1';
        signal debug_inst            : std_logic_vector(31 downto 0);
        signal debug_tmpr            : std_logic_vector(64*4 - 1 downto 0);
        signal debug_savr            : std_logic_vector(64*4 - 1 downto 0);
        signal debug_dmem            : std_logic_vector(64*4 - 1 downto 0);

        constant cycle_time : time := 50 ns;
    
    begin
    
        pipelined_cpu_uut : PipelinedCPU1 port map(
            clk                     => clk,
            rst                     => rst,
            DEBUG_FORWARDA          => debug_forward_a,
            DEBUG_FORWARDB          => debug_forward_b,
            DEBUG_PC                => debug_pc,
            DEBUG_PC_WRITE_ENABLE   => debug_pc_write_enable,
            DEBUG_INSTRUCTION       => debug_inst,
            DEBUG_TMP_REGS          => debug_tmpr,
            DEBUG_SAVED_REGS        => debug_savr,
            DEBUG_MEM_CONTENTS      => debug_dmem
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