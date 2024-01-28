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
	-- As of Lab 4 (NEW):
          -- R-format Instructions: ADD, LDUR, STUR, SUB
               -- NEW: AND, ANDI, ORR, LSL, LSR
          -- I-format Instructions: ADDI, SUBI
               -- NEW: ORRI
          -- B-format Instructions: B
          -- CB-format Instructions: CBZ
               -- NEW: CBNZ
          -- NEW format - Misc: NOP
begin

	Operation <= b"0010" when ALUOp = b"00" else										   -- General Add, seen in LDUR and STUR...
				 b"0111" when ALUOp = b"01"  and Opcode(10 downto 3) = b"10110100" else    -- CBZ, passes input
                 b"1001" when ALUOp = b"01"  and Opcode(10 downto 3) = b"10110101" else    -- CBNZ, does subtraction
				 b"0010" when ALUOp(1) = '1' and Opcode = b"10001011000" else 			   -- R-format ADD
				 b"0110" when ALUOp(1) = '1' and Opcode = b"11001011000" else			   -- R-format SUB
				 b"0000" when ALUOp(1) = '1' and Opcode = b"10001010000" else			   -- R-format AND
				 b"0001" when ALUOp(1) = '1' and Opcode = b"10101010000" else			   -- R-format ORR
				 b"0101" when ALUOp(1) = '1' and Opcode = b"11010011010" else			   -- R-format LSR
				 b"1010" when ALUOp(1) = '1' and Opcode = b"11010011011" else			   -- R-format LSL
				 -- Seems like "1100" is reserved for NOR?																						   
																						   -- Watch the length, looking for opcode in immediates that are length 10...
				 b"0010" when ALUOp(1) = '1' and Opcode(10 downto 1) =  b"1001000100" else -- I-format ADDI
				 b"0110" when ALUOp(1) = '1' and Opcode(10 downto 1) =  b"1101000100" else -- I-format SUBI
				 b"0000" when ALUOp(1) = '1' and Opcode(10 downto 1) =  b"1001001000" else -- I-format ANDI
				 b"0001" when ALUOp(1) = '1' and Opcode(10 downto 1) =  b"1011001000" else -- I-format ORRI

				 b"----"; -- Misc?
				 
	
end dataflow;