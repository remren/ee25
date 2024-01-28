library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeadder_tb is
end pipeadder_tb;

architecture structural of pipeadder_tb is
component pipeadder is
    port(
        in0    : in  STD_LOGIC_VECTOR(63 downto 0);
        in1    : in  STD_LOGIC_VECTOR(63 downto 0);
        output : out STD_LOGIC_VECTOR(63 downto 0);
        cout   : out STD_LOGIC;
        clk    : in  STD_LOGIC
    );
end component;

    signal in0_tb : std_logic_vector(63 downto 0);
    signal in1_tb : std_logic_vector(63 downto 0);
    signal out_tb : std_logic_vector(63 downto 0);
    signal clk : std_logic;

begin
    pipeadder_uut : pipeadder
        port map(
            in0 => in0_tb,
            in1 => in1_tb,
            output => out_tb,
            clk => clk
        );

test_cases : process
begin

    clk <= '0';
    wait for 1 ns;

    in0_tb <= 64d"1";
    in1_tb <= 64d"1";
    wait for 1 ns;

    clk <= '1';
    wait for 1 ns;

    in0_tb <= 64d"42";
    in1_tb <= 64d"68";
    wait for 1 ns;

    clk <= '0';
    wait for 1 ns;

    assert false report "test done." severity note;
    wait;
end process;
end structural;

