library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fulladder_tb is
    -- empty for testbench
end fulladder_tb;

architecture structural of fulladder_tb is
    component FA is
        port(
            a       : in STD_LOGIC;
            b       : in STD_LOGIC;
            sum     : out STD_LOGIC;
            carry_in    : in STD_LOGIC;
            carry_out   : out STD_LOGIC
        );
    end component;

    signal atb : std_logic;
    signal btb : std_logic;
    signal stb : std_logic;
    signal citb : std_logic;
    signal cotb : std_logic;

begin
    FA_uut : FA port map(
                        a => atb,
                        b => btb,
                        sum => stb,
                        carry_in => citb,
                        carry_out => cotb
                        );

test_cases : process
begin

    -- test case #1
    atb <= '0';
    btb <= '0';
    citb <= '0';
        wait for 50 ns;
        assert stb = '0' report "SUM FAILED TC1";
        assert cotb = '0' report "CARRY OUT FAILED TC1";

    -- test case #2
    atb <= '0';
    btb <= '0';
    citb <= '1';
        wait for 50 ns;
        assert stb = '1' report "SUM FAILED TC2";
        assert cotb = '0' report "CARRY OUT FAILED TC2";

    -- test case #3
    atb <= '0';
    btb <= '1';
    citb <= '0';
        wait for 50 ns;
        assert stb = '1' report "SUM FAILED TC3";
        assert cotb = '0' report "CARRY OUT FAILED TC3";

    -- test case #4
    atb <= '0';
    btb <= '1';
    citb <= '1';
        wait for 50 ns;
        assert stb = '0' report "SUM FAILED TC4";
        assert cotb = '1' report "CARRY OUT FAILED TC4";

    -- test case #5
    atb <= '1';
    btb <= '0';
    citb <= '0';
        wait for 50 ns;
        assert stb = '1' report "SUM FAILED TC5";
        assert cotb = '0' report "CARRY OUT FAILED TC5";

    -- test case #6
    atb <= '1';
    btb <= '0';
    citb <= '1';
        wait for 50 ns;
        assert stb = '0' report "SUM FAILED TC6";
        assert cotb = '1' report "CARRY OUT FAILED TC6";

    -- test case #7
    atb <= '1';
    btb <= '1';
    citb <= '0';
        wait for 50 ns;
        assert stb = '0' report "SUM FAILED TC6";
        assert cotb = '1' report "CARRY OUT FAILED TC6";

    -- test case #8
    atb <= '1';
    btb <= '1';
    citb <= '1';
        wait for 50 ns;
        assert stb = '1' report "SUM FAILED TC7";
        assert cotb = '1' report "CARRY OUT FAILED TC7";

        assert false report "test done." severity note;
        wait;

end process;

end structural ; -- structural