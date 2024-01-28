library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_control_testbench is
-- Empty for Testbench
end alu_control_testbench;

architecture structural of alu_control_testbench is
	component alucontrol is
		port(
			ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
			Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
			Operation : out STD_LOGIC_VECTOR(3 downto 0)
			);
	end component;
	
	signal aop : STD_LOGIC_VECTOR(1 downto 0);
	signal opc : STD_LOGIC_VECTOR(10 downto 0);
	signal opr : STD_LOGIC_VECTOR(3 downto 0);
	
begin
	ALUControl_uut : alucontrol
		port map (aop, opc, opr);
		
test_cases : process
begin
	-- test case #1
	aop <= b"00";
	opc <= b"10010100101";
		wait for 50 ns;
		assert opr = b"0010" report "fail tc1 - check 00";
		
	-- test case #2
	aop <= "01";
	opc <= b"11111111000";
		wait for 50 ns;
		assert opr = b"0111" report "fail tc2 - check 01";
		
	-- test case #3
	aop <= "10";
	opc <= b"10001011000";
		wait for 50 ns;
		assert opr = b"0010" report "fail tc3 - check 1X w/opcode 1";
		
	-- test case #4
	aop <= "11";
	opc <= b"10001011000";
		wait for 50 ns;
		assert opr = b"0111" report "fail tc4 - check 1X w/opcode 1";
		assert false report "test :D " & to_string(opr) severity note;
		
	-- test case #5
	aop <= "10";
	opc <= b"11001011000";
		wait for 50 ns;
		assert opr = b"0110" report "fail tc5- check 1X w/opcode 2";
	
	-- test case #6
	aop <= "10";
	opc <= b"11001011000";
		wait for 50 ns;
		assert opr = b"0110" report "fail tc6 - check 1X w/opcode 2";
		
	-- test case #7
	aop <= "10";
	opc <= b"10001010000";
		wait for 50 ns;
		assert opr = b"0000" report "fail tc7 - check 1X w/opcode 3";
		
	-- test case #8
	aop <= "10";
	opc <= b"10101010000";
		wait for 50 ns;
		assert opr = b"0001" report "fail tc8 - check 1X w/opcode 4";
		
		assert false report "test done." severity note;
        wait;

end process;

end structural;