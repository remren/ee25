-- help!
library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.numeric_std.all;

entity shiftleft2_test is
end shiftleft2_test;

architecture test of shiftleft2_test is

component ShiftLeft2 is
	port(
		x : in	STD_LOGIC_VECTOR(63 downto 0);
		y : out STD_LOGIC_VECTOR(63 downto 0)
		);
end component;

signal x : STD_LOGIC_VECTOR(63 downto 0);
signal y : STD_LOGIC_VECTOR(63 downto 0);

begin

uut : ShiftLeft2 port map(x, y);
	process begin
		x <= X"1111222233334444"; wait for 10 ns;
		assert y = X"44448888CCCD1110" report "failed";
		x <= X"0000000000000001"; wait for 10 ns;
		assert y = X"0000000000000004" report "failed 4";
		assert false report "TEST done" severity note;
		
		wait;
		
	end process;
end test;	