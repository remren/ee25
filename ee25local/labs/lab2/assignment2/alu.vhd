library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
-- as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'ARM Reference Data' sheet at the
--    front of the textbook (or the Green Card pdf on Canvas).
port(
     in0       : in     STD_LOGIC_VECTOR(63 downto 0);
     in1       : in     STD_LOGIC_VECTOR(63 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(63 downto 0);
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
    );
end ALU;

architecture structural of ALU is
	component ADD is
        port(
            in0    : in  STD_LOGIC_VECTOR(63 downto 0);
            in1    : in  STD_LOGIC_VECTOR(63 downto 0);
            output : out STD_LOGIC_VECTOR(63 downto 0)
        );
    end component;
	
	signal add_result, sub_result, onescomp, twoscomp : std_logic_vector(63 downto 0) := (others => '0');
    signal tc_overflow_h0 : std_logic;
	
begin

	add_alu : ADD port map(
							in0 => in0,
							in1 => in1,
							output => add_result
							);
	
    -- subtrahend, for twos complement subtraction
    onescomp <= NOT in1;
    twos_comp : ADD port map(
                                in0 => onescomp,
                                in1 => x"0000000000000001",
                                output => twoscomp
                            );
    sub_alu : ADD port map(
                                in0 => in0,
                                in1 => twoscomp,
                                output => sub_result
                            );
	
    -- 0000 AND, 0001 OR, 0010 add, 0010 sub, 0111 pass input b, 1100 NOR
	result <= in0 and in1 when operation = b"0000" else
			  in0 or  in1 when operation = b"0001" else
			  add_result  when operation = b"0010" else
              sub_result  when operation = b"0110" else
              in1         when operation = b"0111" else
              in0 nor in1 when operation = b"1100";

    tc_overflow_h0 <= '1' when (((in0(63) = '0') and (in1(63) = '1')) and (result(63) = '1')) else
                      '1' when (((in0(63) = '1') and (in1(63) = '0')) and (result(63) = '0')) else
                      '0';

    -- Logic: (1 if msb match, so either both pos/neg) and (1 if msb differ)
    overflow <= (in0(63) xnor in1(63)) and (result(63) xor in0(63)) when operation = b"0010" else
                tc_overflow_h0 when operation = b"0110" else
                '0'; -- for any other case, such as AND/OR

    zero <= '1' when result = x"0000000000000000" else
            '0';
			  
end structural;