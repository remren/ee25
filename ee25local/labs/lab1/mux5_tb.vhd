library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mux5_tb is
    -- empty, testbench!
end mux5_tb;

architecture structural of mux5_tb is
    component MUX5 is -- Two by one mux with 5 bit inputs/outputs
        port(
            in0    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 0
            in1    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 1
            sel    : in STD_LOGIC; -- selects in0 or in1
            output : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

    -- testing signals!
    signal m5a      : std_logic_vector(4 downto 0);
    signal m5b      : std_logic_vector(4 downto 0);
    signal m5sel    : std_logic;
    signal m5output : std_logic_vector(4 downto 0);

begin
    mux5_uut : MUX5 port map (
                              in0    => m5a,
                              in1    => m5b,
                              sel    => m5sel,
                              output => m5output
                             );
    
test_cases : process
begin
    -- test case #1: sel = '0', should get in0
    m5a   <= b"00000";
    m5b   <= b"11111";
    m5sel <= '0';
        wait for 50 ns;
        assert m5output = m5a report "FAILED sel=0";
    -- test case #2: sel = '1', should get in1
    m5a   <= b"00000";
    m5b   <= b"11111";
    m5sel <= '1';
        wait for 50 ns;
        assert m5output = m5b report "FAILED sel=1";

    -- Clear Input
    m5a   <= b"00000";
    m5b   <= b"00000";
    m5sel <= '0';
    assert false report "test done." severity note;
    wait;

end process;
end structural;