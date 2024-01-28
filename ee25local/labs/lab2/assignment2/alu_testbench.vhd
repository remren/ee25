library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_testbench is
-- Empty! Testbench.
end alu_testbench;

architecture structural of alu_testbench is
	component ALU is
		port(
			 in0       : in     STD_LOGIC_VECTOR(63 downto 0);
			 in1       : in     STD_LOGIC_VECTOR(63 downto 0);
			 operation : in     STD_LOGIC_VECTOR(3 downto 0);
			 result    : buffer STD_LOGIC_VECTOR(63 downto 0);
			 zero      : buffer STD_LOGIC;
			 overflow  : buffer STD_LOGIC
			);
	end component;
	
	signal in0tb, in1tb, rtb : STD_LOGIC_VECTOR(63 downto 0);
	signal optb : STD_LOGIC_VECTOR(3 downto 0); -- Operation
	signal ztb, oftb : STD_LOGIC; -- Zero, Overflow

begin
	ALU_uut : ALU port map (
							in0 => in0tb,
							in1 => in1tb,
							operation => optb,
							result => rtb,
							zero => ztb,
							overflow => oftb
							);
							
test_case : process
begin
	-- test case #1
	in0tb <= x"0000000000000000";
	in1tb <= x"FFFFFFFFFFFFFFFF";
	optb <= b"0000";
		wait for 50 ns;
		assert rtb = x"0000000000000000" report "Failed TC1 AND";

	-- test case #2
	in0tb <= x"FFFF0000FFFF0000";
	in1tb <= x"FFFFFFFFFFFFFFFF";
	optb <= b"0000";
		wait for 50 ns;
		assert rtb = x"FFFF0000FFFF0000" report "Failed TC2 AND";

	-- test case #3
	in0tb <= x"FFFF0000FFFF0000";
	in1tb <= x"FFFFFFFFFFFFFFFF";
	optb <= b"0001";
		wait for 50 ns;
		assert rtb = x"FFFFFFFFFFFFFFFF" report "Failed TC3 OR";

	-- test case #4 unsigned
    in0tb <= x"0000000000000002";
    in1tb <= x"0000000000000002";
	optb <= b"0010";
        wait for 50 ns;
        assert rtb = x"0000000000000004" report "SUM FAILED TC4: " & to_string(rtb);
		assert oftb = '0' report "FAILED TC4 OVERFLOW";
		
	-- test case #5
    in0tb <= x"3217318463978812";
    in1tb <= x"3217318463978812";
	optb <= b"0010";
        wait for 50 ns;
        assert rtb = x"642E6308C72F1024" report "SUM FAILED TC5: " & to_string(rtb);
		assert oftb = '0' report "FAILED TC5 OVERFLOW";

	-- test case #6 - tests for overflow flag '1'
    in0tb <= x"7FFFFFFFFFFFFFFF";
    in1tb <= x"7FFFFFFFFFFFFFFF";
	optb <= b"0010";
        wait for 50 ns;
        assert rtb = x"FFFFFFFFFFFFFFFE" report "SUM FAILED TC6: " & to_string(rtb);
		assert oftb = '1' report "FAILED TC6 OVERFLOW";

	-- test case #7
	in0tb <= x"FFFFFFFFFFFFFFFF";
	in1tb <= x"FFFFFFFFFFFFFFFF";
	optb <= b"0110";
		wait for 50 ns;
		assert rtb = x"0000000000000000" report "fail tc7: " & to_string(rtb);
		assert oftb = '0' report "FAILED TC7 OVERFLOW";

	-- test case #8
	in0tb <= x"0000000000000110";
	in1tb <= x"0000000000000111";
	optb <= b"0110";
		wait for 50 ns;
		assert rtb = x"FFFFFFFFFFFFFFFF" report "fail tc8: " & to_string(rtb);
		assert oftb = '0' report "FAILED TC8 OVERFLOW | in0(63):" & to_string(in0tb(63)) & ", in1(63):" & to_string(in1tb(63)) & ", result(63):" & to_string(rtb(63));

		assert false report "test done." severity note;
        wait;

end process;
end structural;