library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity registers_testbench is
    -- empty, test bench
end entity;

architecture structural of registers_testbench is
component registers is
    port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
        RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
        WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
        WD       : in  STD_LOGIC_VECTOR (63 downto 0);
        RegWrite : in  STD_LOGIC;
        Clock    : in  STD_LOGIC;
        RD1      : out STD_LOGIC_VECTOR (63 downto 0);
        RD2      : out STD_LOGIC_VECTOR (63 downto 0);
        DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
        DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
    );
end component;

    signal rr1tb, rr2tb, wrtb : std_logic_vector(4 downto 0);
    signal wdtb, rd1tb, rd2tb : std_logic_vector(63 downto 0);
    signal rwtb, clktb        : std_logic;
    signal debugtemp          : std_logic_vector(64*4 - 1 downto 0);
    signal debugsave          : std_logic_vector(64*4 - 1 downto 0);

begin
reg_uut : registers port map(
    RR1                 => rr1tb,
    RR2                 => rr2tb,
    WR                  => wrtb,
    WD                  => wdtb,
    RegWrite            => rwtb,
    Clock               => clktb,
    RD1                 => rd1tb,
    RD2                 => rd2tb,
    DEBUG_TMP_REGS      => debugtemp,
    DEBUG_SAVED_REGS    => debugsave
);

test_cases:process
begin
        -- Read from X19 via read 1
            -- "Start" up the clock
            clktb <= '0';
            wait for 1 ns;
            clktb <= '1';
            wait for 1 ns;
        
            -- read should not need a clock edge
        rr1tb <= b"10011"; -- X19
        rr2tb <= b"01010"; -- X10
            wait for 50 ns;
            assert rd1tb = x"0000000000000008" report "Failed X19: " & to_string(rd1tb) severity note;
            assert rd2tb = x"0000000000000001" report "Failed X10: " & to_string(rd2tb) severity note;
            -- Working!
        
        -- Write to Register X20
        rwtb <= '1';
        wrtb <= b"10100";
        wdtb <= x"1234123412341234";
        clktb <= '0';
            wait for 50 ns;
        rwtb <= '0';
        rr1tb <= b"10100";
            wait for 50 ns;
            assert rd1tb = x"1234123412341234" report "Failed X20: " & to_string(rd1tb) severity note; 
        -- Create a Negative Clock Edge! Works!

        -- Demo of Writing to XZR (should fail)
        rwtb <= '1';
        wrtb <= b"11111";
        wdtb <= x"1234123412341234";
        clktb <= '0';
            wait for 50 ns;
        rwtb <= '0';
        rr1tb <= b"11111";
            wait for 50 ns;
            assert rd1tb = x"0000000000000000" report "Failed XZR: " & to_string(rd1tb) severity note;
            assert false report "XZR: " & to_string(rd1tb) severity note;

        assert false report "test done." severity note;
        wait;
end process;
end structural;