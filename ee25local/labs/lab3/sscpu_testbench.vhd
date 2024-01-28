library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sscpu_testbench is
    -- empty, testbench.
end sscpu_testbench;

architecture structural of sscpu_testbench is
component SingleCycleCPU is
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

    -- Signals for SSCPU
    signal clk, rst     : std_logic;
    signal debug_pc     : std_logic_vector(63 downto 0);
    signal debug_inst   : std_logic_vector(31 downto 0);
    signal debug_tmpr   : std_logic_vector(64*4 - 1 downto 0);
    signal debug_savr   : std_logic_vector(64*4 - 1 downto 0);
    signal debug_dmem   : std_logic_vector(64*4 - 1 downto 0);

begin

    sscpu_uut : SingleCycleCPU port map(
        clk                 => clk,
        rst                 => rst,
        DEBUG_PC            => debug_pc,
        DEBUG_INSTRUCTION   => debug_inst,
        DEBUG_TMP_REGS      => debug_tmpr,
        DEBUG_SAVED_REGS    => debug_savr,
        DEBUG_MEM_CONTENTS  => debug_dmem
    );

test_cases : process
begin
    -- "start up" the clock
        -- clk <= '0';
        -- wait for 1 ns;

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
            rst <= '1';
            wait for 1 ns;
            rst <= '0';

    -- *** [PROGRAM TESTS] *** --
    
        assert false report "// ... Beginning Program Tests ... ///" severity note;
    -- [ldStr]: STUR and LDUR
            -- STUR X10, [X11,0]
            -- LDUR X10, [X9, 0]
            -- Result: Memory Address in X11 gets X10's Data
                -- aka X11=64x"4", X10=64x"1", so DMEM(4)= "1"?
            -- Result: X10 gets X9's memory address' contents.
                -- aka X9="0", DMEM so X10="0"?
            -- Determine # of loops by seeing which clock edge results in a metavalue.

        assert false report "// ... Testing: [file] ... //" severity note;
        -- for i in 1 to 4 loop
        --     if (i mod 2 = 1) then
        --         clk <= '1';
        --         wait for 50 ns;
        --         assert false report "clock: High, " & to_string(i) severity note;
        --     else
        --         clk <= '0';
        --         wait for 50 ns;
        --         assert false report "clock: Low, " & to_string(i) severity note;
        --     end if;
        -- end loop;

    -- [COMP]: Uses ALU just like in ic_06
        -- for i in 1 to 10 loop
        --     if (i mod 2 = 1) then
        --         clk <= '1';
        --         wait for 50 ns;
        --         assert false report "clock: High, " & to_string(i) severity note;
        --     else
        --         clk <= '0';
        --         wait for 50 ns;
        --         assert false report "clock: Low, " & to_string(i) severity note;
        --     end if;
        -- end loop;

    -- [p1]: Main problem for lab3
        for i in 1 to 20 loop
            if (i mod 2 = 1) then
                clk <= '1';
                wait for 50 ns;
                assert false report "clock: High, " & to_string(i) severity note;
            else
                clk <= '0';
                wait for 50 ns;
                assert false report "clock: Low, " & to_string(i) severity note;
            end if;
        end loop;

        -- clk <= '1';
        --     wait for 1 ns;
        --     assert false report "1st clock high" severity note;
        --     -- assert false report "pc_debug=" & to_hex_string(debug_pc) severity note;
        --     -- assert false report "reg_debugtemp=" & to_hex_string(debug_tmpr) severity note; 
        --     -- assert false report "reg_debugsave=" & to_hex_string(debug_savr) severity note;
        --     -- assert false report "imem_debug=" & to_hex_string(debug_inst) severity note;
        --     -- assert false report "dmem_debug=" & to_hex_string(debug_dmem) severity note;
        --     assert false report "IMEMS" severity note;

        -- clk <= '0';
        --     wait for 1 ns;
        --     assert false report "2nd clock low" severity note;
        --     assert false report "pc_debug=" & to_hex_string(debug_pc) severity note;
        --     assert false report "reg_debugtemp=" & to_hex_string(debug_tmpr) severity note; 
        --     assert false report "reg_debugsave=" & to_hex_string(debug_savr) severity note;
        --     assert false report "imem_debug=" & to_hex_string(debug_inst) severity note;
        --     assert false report "dmem_debug=" & to_hex_string(debug_dmem) severity note;

        assert false report "test done." severity note;
        wait;
end process;
end structural;