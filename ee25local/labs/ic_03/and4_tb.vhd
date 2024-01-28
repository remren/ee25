library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity and4_tb is
  -- empty
end and4_tb;

architecture structural of and4_tb is
  -- "including" and2 into this module
	component and4 is
	  port (	in0 	: in	STD_LOGIC;
		        in1 	: in	STD_LOGIC;
		        in2 	: in	STD_LOGIC;
		        in3 	: in	STD_LOGIC;
		        output	: out	STD_LOGIC
         );
	end component;

  -- testing signals
	signal A_in : std_logic := '0';
	signal B_in : std_logic := '0';
	signal C_in : std_logic := '0';
	signal D_in : std_logic := '0';
	signal Y_out : std_logic;

  begin
		-- uut = unit-under-test
		uut: and4 port map (
			in0 => A_in,
			in1 => B_in,
			in2 => C_in,
			in3 => D_in,
			output => Y_out
		);

	
	test_cases: process
	begin
		-- test case #1: 0 AND 0 AND 0 AND 0
		wait for 50 ns;
		A_in <= '0';
		B_in <= '0';
		C_in <= '0';
		D_in <= '0';

		wait for 50 ns;
		assert Y_out = '0' report "FAILED 0 AND 0 AND 0 AND 0";
		
		-- For brevity, all 16 test cases are not included. I wanted
		-- to also use a for loop (for i in 0 to 16 loop) but syntax
		-- is wack.

		-- Clear Inputs
		A_in <= '0';
		B_in <= '0';
		C_in <= '0';
		D_in <= '0';

		assert false report "Test done." severity note;
		-- what does severity note; do?

		wait; -- wait indef.
	end process;
end structural;


