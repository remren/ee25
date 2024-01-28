library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AND4 is
	port(	i0		: in	STD_LOGIC;
			i1		: in	STD_LOGIC;
			i2		: in	STD_LOGIC;
			i3		: in	STD_LOGIC;
			op		: out	STD_LOGIC
		);
end AND4;

architecture structural of AND4 is
	-- "include" statement for and2 into this module
	component and2 is
		port(	in0		: in	STD_LOGIC;
				in1		: in 	STD_LOGIC;
				output	: out	STD_LOGIC
			);
	end component;

	-- intermediate signals?
	signal AB_out 	: std_logic;
	signal CD_out 	: std_logic;
	-- signal Y_out	: std_logic;
	
begin
	-- still very confused about this part...
	and2_AB : and2 port map (	in0 => i0,
								in1 => i1,
								output => AB_out
							);
	and2_BC : and2 port map (	in0 => i2,
								in1 => i3,
								output => CD_out
							);
	-- and2_Y	: and2 port map (	in0 => AB_out,
								-- in1 => CD_out,
								-- output => Y_out
							-- );
	
	op <= AB_out and CD_out;
	
end structural;