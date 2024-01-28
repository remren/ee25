library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity add_testbench is
    -- empty for testbench
end add_testbench;

architecture structural of add_testbench is
    component ADD is
        port(
            in0    : in  STD_LOGIC_VECTOR(63 downto 0);
            in1    : in  STD_LOGIC_VECTOR(63 downto 0);
            output : out STD_LOGIC_VECTOR(63 downto 0)
        );
    end component;

	signal in0tb : std_logic_vector(63 downto 0);
    signal in1tb : std_logic_vector(63 downto 0);
    signal outtb : std_logic_vector(63 downto 0);

begin
	
    ADD_uut : ADD port map(in0tb, in1tb, outtb);

test_cases : process
begin

    -- test case #1 unsigned
    in0tb <= x"0000000000000002";
    in1tb <= x"0000000000000002";
        wait for 50 ns;
        assert outtb = x"0000000000000004" report "SUM FAILED TC1";
		
	-- test case #2
    in0tb <= x"3217318463978812";
    in1tb <= x"3217318463978812";
        wait for 50 ns;
        assert outtb = x"642E6308C72F1024" report "SUM FAILED TC2";

        assert false report "test done." severity note;
        wait;

end process;

end structural ; -- structural