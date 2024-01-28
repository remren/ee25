library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;

entity shiftleft2_tb is
    -- empty, testbench!
end shiftleft2_tb;

architecture structural of shiftleft2_tb is
    component ShiftLeft2 is
        port(
			 x : in  STD_LOGIC_VECTOR(63 downto 0);
			 y : out STD_LOGIC_VECTOR(63 downto 0) -- x << 2
		);
    end component;

    -- testing signals!
    signal test_x : STD_LOGIC_VECTOR(63 downto 0);
    signal test_y : STD_LOGIC_VECTOR(63 downto 0);

begin

    sl2_uut : ShiftLeft2 port map(
								  x => test_x,
								  y => test_y
								 );
process begin
	-- test case #1
	test_x <= X"0000000000000001"; wait for 10 ns;
	assert test_y = X"0000000000000004" report "failed 4";

    assert false report "test done." severity note;
    wait;

end process;
end;