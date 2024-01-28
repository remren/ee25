library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALUControl is
-- Functionality should match truth table shown in Figure 4.13 in the textbook.
-- Check table on page2 of ISA.pdf on canvas. Pay attention to opcode of operations and type of operations. 
-- If an operation doesn't use ALU, you don't need to check for its case in the ALU control implemenetation.	
--  To ensure proper functionality, you must implement the "don't-care" values in the funct field,
-- for example when ALUOp = '00", Operation must be "0010" regardless of what Funct is.
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ALUControl;

architecture dataflow of ALUControl is

begin

	Operation <= b"0010" when ALUOp = b"00" else
				 b"0111" when ALUOp(0) = '1' else
				 b"0010" when ALUOp(1) = '1' and Opcode = b"10001011000" else
				 b"0110" when ALUOp(1) = '1' and Opcode = b"11001011000" else
				 b"0000" when ALUOp(1) = '1' and Opcode = b"10001010000" else
				 b"0001" when ALUOp(1) = '1' and Opcode = b"10101010000" else
				 b"XXXX";
				 
	
end dataflow;