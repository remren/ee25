library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity or_gate is
	port(	A	: in std_logic;
			B	: in std_logic;
			Y	: out std_logic
		);
end or_gate;

architecture dataflow of or_gate is
begin
		
	Y <= A OR B;
	
end dataflow;