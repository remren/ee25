library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity and2_tb is
  -- empty
end and2_tb;

architecture structural of and2_tb is
  -- "including" and2 into this module
	component and2 is
	  port (	in0 	: in	STD_LOGIC;
		        in1 	: in	STD_LOGIC;
		        output	: out	STD_LOGIC
         );
	end component;

  -- testing signals
	signal A_in : std_logic := '0';
	signal B_in : std_logic := '0';
	signal Y_out : std_logic;

  begin
		uut: and2 port map (
			in0 => A_in,
			in1 => B_in,
			output => Y_out
		);

	
	test_cases: process
	begin
		-- test case #1: 0 AND 0
		wait for 50 ns;
		A_in <= '0';
		B_in <= '0';

		wait for 50 ns;
		assert Y_out = '0' report "FAILED 0 AND 0";

		-- test case #2: 1 AND 0
                wait for 50 ns;
				A_in <= '1';
                B_in <= '0';

                wait for 50 ns;
                assert Y_out = '0' report "FAILED 1 AND 0";

		-- test case #3: 0 AND 1
                wait for 50 ns;
                A_in <= '0';
                B_in <= '1';

                wait for 50 ns;
                assert Y_out = '0' report "FAILED 0 AND 1";

		-- test case #4: 1 AND 1
                wait for 50 ns;
                A_in <= '1';
                B_in <= '1';

                wait for 50 ns;
                assert Y_out = '1' report "FAILED 1 AND 1";

		-- Clear Inputs
		A_in <= '0';
		B_in <= '0';

		assert false report "Test done." severity note;
		-- what does severity note; do?

		wait; -- wait indef.
	end process;
end structural;


