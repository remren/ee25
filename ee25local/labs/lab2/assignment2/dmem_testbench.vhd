library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dmem_testbench is
    -- empty, test bench
end entity;

architecture structural of dmem_testbench is
component DMEM is
    port(
        WriteData          : in  STD_LOGIC_VECTOR(63 downto 0); -- Input data
        Address            : in  STD_LOGIC_VECTOR(63 downto 0); -- Read/Write address
        MemRead            : in  STD_LOGIC; -- Indicates a read operation
        MemWrite           : in  STD_LOGIC; -- Indicates a write operation
        Clock              : in  STD_LOGIC; -- Writes are triggered by a rising edge
        ReadData           : out STD_LOGIC_VECTOR(63 downto 0); -- Output data
        -- Probe ports used for testing
        -- Four 64-bit words: DMEM(0) & DMEM(4) & DMEM(8) & DMEM(12)
        DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
    );
end component;

    signal wdtb, atb, rdtb : std_logic_vector(63 downto 0); -- write data, address, read data
    signal mrtb, mwtb, clktb : std_logic; -- memread, memwrite, clock
    signal debugtb : std_logic_vector(64*4 - 1 downto 0); -- debug

begin 
    DMEM_uut : DMEM port map(
        WriteData  => wdtb,
        Address    => atb,
        MemRead    => mrtb,
        MemWrite   => mwtb,
        Clock      => clktb,
        ReadData   => rdtb,
        DEBUG_MEM_CONTENTS => debugtb
    );

    test_cases : process
    begin
        -- test case #1, first read attempt
        atb <= x"0000000000000000";
        mrtb <= '1';
        mwtb <= '0';
            wait for 50 ns;
            assert rdtb = b"1000000101100110010101011010101000111100010010011010010101011010" report "fail tc1" severity note;

            assert false report "rdtbtc1:    " & to_string(rdtb) severity note;
        -- debug1
            wait for 50 ns;
            assert false report "DEBUG1:    " & to_string(debugtb(63 downto 0)) severity note;
        -- So debug is direct memory access, but is flipped
        
        -- test case #2, second read attempt, trying to figure out addr interval
        atb <= x"0000000000000010";
        --  memory: contains 8 "blocks", 64 total addresses per line. From 0 to 40
        --          and each interval is at 8?
        mrtb <= '1';
        mwtb <= '0';
            wait for 50 ns;
            assert rdtb = b"1000000101100110010101011010101000111100010010011010010101011010" report "fail tc2" severity note;
            assert false report "rdtbtc2:   " & to_string(rdtb) severity note;
            assert false report "DEBUG2:    " & to_string(debugtb(64*2 - 1 downto 64*1)) severity note;

        -- generic case, trying to figure out addr interval
        atb <= x"0000000000000008";
        --  memory: contains 8 "blocks", 64 total addresses per line. From 0 to 40
        --          and each interval is at 8? Seems right!
        mrtb <= '1';
        mwtb <= '0';
            wait for 50 ns;
            assert rdtb = b"1000000101100110010101011010101000111100010010011010010101011010" report "fail tc" severity note;
            assert false report "generic:   " & to_string(rdtb) severity note;

        -- test case #3, first write attempt
        atb <= x"0000000000000000";
        mrtb <= '0';
        mwtb <= '1';
        clktb <= '1';
        wdtb <= x"FFFFFFFFFFFFFFFF";
            wait for 50 ns;
        atb <= x"0000000000000000";
        mrtb <= '1';
        mwtb <= '0';
        clktb <= '0';
            wait for 50 ns;
            assert rdtb = x"FFFFFFFFFFFFFFFF" report "failed tc3" severity note;
            assert false report "rdtbtc3:   " & to_string(rdtb) severity note;
            assert false report "Debug:     " & to_string(debugtb(63 downto 0)) severity note;

        -- test case #4, second write attempt
        atb <= x"0000000000000010";
        mrtb <= '0';
        mwtb <= '1';
        clktb <= '1';
        wdtb <= x"1234123412341234";
            wait for 50 ns;
        atb <= x"0000000000000010";
        mrtb <= '1';
        mwtb <= '0';
        clktb <= '0';
            wait for 50 ns;
            assert rdtb = x"1234123412341234" report "failed tc4" severity note;
            assert false report "rdtbtc4:   " & to_string(rdtb) severity note;
            assert false report "Debug:     " & to_string(debugtb(64*2 - 1 downto 64*1)) severity note;

            assert false report "test done." severity note;
            wait;
    end process;
end structural;

