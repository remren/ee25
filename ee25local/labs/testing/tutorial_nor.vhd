library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity NOR_GATE is
	port(
		in0		: in	std_logic;
		in1		: in 	std_logic;
		output	: out	std_logic
		);
end NOR_GATE;

architecture dataflow of NOR_GATE is
begin
	output <= in0 nor in1;
end dataflow;