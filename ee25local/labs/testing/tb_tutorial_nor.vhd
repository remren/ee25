library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_nor is
	-- empty
end tb_nor;

architecture structural of tb_nor is
	component NOR_GATE is
		port(
				in0 : in 	std_logic;
				in1 : in 	std_logic;
				output : out	std_logic
			);
	end component;
	
	signal A_in	: std_logic := '0';
	signal B_in : std_logic := '0';
	signal Y_out : std_logic;

	begin
		instance : NOR_GATE port map (
			in0 => A_in,
			in1 => B_in,
			output => Y_out
		);
	
	test_cases: process
	begin
		
		A_in <= '0';
		B_in <= '0';
			wait for 50 ns;
			assert Y_out = '1' report "Fail 0 NOR 0";
		
		A_in <= '1';
		B_in <= '0';
			wait for 50 ns;
			assert Y_out = '0' report "Fail 1 NOR 0";
			
		A_in <= '0';
		B_in <= '1';
			wait for 50 ns;
			assert Y_out = '0' report "Fail 0 NOR 1";
		
		A_in <= '1';
		B_in <= '1';
			wait for 50 ns;
			assert Y_out = '0' report "Fail 1 NOR 1";
			
		A_in <= '0';
		B_in <= '0';
			assert false report "Test done." severity note;
		
			wait;
		
	end process;
end structural;