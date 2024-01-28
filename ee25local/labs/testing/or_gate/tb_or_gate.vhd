library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity or_gate_tb is
	-- empty
end or_gate_tb;

architecture structural of or_gate_tb is
	component or_gate is
		port(
				A : in 	STD_LOGIC;
				B : in 	STD_LOGIC;
				Y : out	STD_LOGIC
			);
	end component;
	
	signal A_in	: std_logic := '0';
	signal B_in : std_logic := '0';
	signal Y_out : std_logic;

	begin
		uut: or_gate port map (
			A => A_in,
			B => B_in,
			Y => Y_out
		);
	
	stim_proc: process
	begin
		
		A_in <= '0';
		B_in <= '0';
			wait for 50 ns;
			assert Y_out = '0' report "Fail 0 OR 0";
		
		A_in <= '1';
		B_in <= '0';
			wait for 50 ns;
			assert Y_out = '1' report "Fail 1 NOR 0";
			
		A_in <= '0';
		B_in <= '1';
			wait for 50 ns;
			assert Y_out = '1' report "Fail 0 NOR 1";
		
		A_in <= '1';
		B_in <= '1';
			wait for 50 ns;
			assert Y_out = '1' report "Fail 1 NOR 1";
			
		A_in <= '0';
		B_in <= '0';
			assert false report "Test done." severity note;
		
			wait;
		
end process;
end structural;