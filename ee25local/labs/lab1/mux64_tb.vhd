library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mux64_tb is
    -- empty, testbench!
end mux64_tb;

architecture structural of mux64_tb is
    component MUX64 is -- Two by one mux with 5 bit inputs/outputs
        port(
            in0    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
            in1    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
            sel    : in STD_LOGIC; -- selects in0 or in1
            output : out STD_LOGIC_VECTOR(63 downto 0)
        );
    end component;

    -- testing signals!
    signal m64a      : std_logic_vector(63 downto 0) := x"0000000000000000";
    signal m64b      : std_logic_vector(63 downto 0) := x"FFFFFFFFFFFFFFFF";
    signal m64sel    : std_logic;
    signal m64output : std_logic_vector(63 downto 0);

begin
    mux64_uut : MUX64 port map (
                                in0    => m64a,
                                in1    => m64b,
                                sel    => m64sel,
                                output => m64output
                               );
    
test_cases : process
begin
    -- test case #1: sel = '0', should get in0
    m64sel <= '0';
        wait for 50 ns;
        assert m64output = m64a report "FAILED sel=0";
    -- test case #2: sel = '1', should get in1
    m64sel <= '1';
        wait for 50 ns;
        assert m64output = m64b report "FAILED sel=1";

    -- Clear Input
    m64sel <= '0';
    assert false report "test done." severity note;
    wait;

end process;
end structural;