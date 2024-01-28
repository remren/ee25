library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.numeric_std.all;



entity ShiftLeft2 is
	port(
		x : in	STD_LOGIC_VECTOR(63 downto 0);
		y : out	STD_LOGIC_VECTOR(63 downto 0)
		);
end ShiftLeft2;

architecture synth of ShiftLeft2 is
begin
	y <= x(61 downto 0) & "00";
end;