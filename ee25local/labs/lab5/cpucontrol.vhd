library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPUControl is
-- Functionality should match the truth table shown in Figure 4.22 of the textbook, inlcuding the
--    output 'X' values.
-- The truth table in Figure 4.22 omits the unconditional branch instruction:
--    UBranch = '1'
--    MemWrite = RegWrite = '0'
--    all other outputs = 'X'	
port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
     Reg2Loc   : out STD_LOGIC;
     CBranch  : out STD_LOGIC;  --conditional
     MemRead  : out STD_LOGIC;
     MemtoReg : out STD_LOGIC;
     MemWrite : out STD_LOGIC;
     ALUSrc   : out STD_LOGIC;
     RegWrite : out STD_LOGIC;
     UBranch  : out STD_LOGIC; -- This is unconditional
     ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
);
end CPUControl;

architecture behavioral of CPUControl is
     -- As of ic_05b_CPUC, implement: ADD, ADDI, B, CBZ, LDUR, STUR, SUB, SUBI
          -- R-format Instructions: ADD, LDUR, STUR, SUB
          -- I-format Instructions: ADDI, SUBI
          -- B-format Instructions: B
          -- CB-format Instructions: CBZ

     -- As of Lab 4 (NEW):
          -- R-format Instructions: ADD, LDUR, STUR, SUB
               -- NEW: AND, ORR, LSL, LSR
          -- I-format Instructions: ADDI, SUBI
               -- NEW: ANDI, ORRI
          -- B-format Instructions: B
          -- CB-format Instructions: CBZ
               -- NEW: CBNZ
          -- NEW format - Misc: NOP
begin
     process (Opcode) is
     begin

          -- For R-format:
               -- Ignore FMULS, FADDD, etc. as those are floating point inst.
               -- 10001010000 : AND
               -- 10001011000 : ADD
               -- 11001011000 : SUB
               -- 10101010000 : ORR
               -- 1--0101-000 "General Opcode" <- Leaving out a couple R-formats here like LSL, LSR

          -- R-format ADD, SUB, AND, ORR          v R-Format Instructions v
          if (Opcode ?= b"1--0101-000") then
               Reg2Loc   <= '0';
               ALUSrc    <= '0';
               MemtoReg  <= '0';
               RegWrite  <= '1';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '0';
               ALUOp(1)  <= '1';
               ALUOP(0)  <= '0';
               UBranch   <= '0';
          
          -- R-format (but uses immediates) LSR, LSL        ---
          elsif (Opcode ?= "1101001101-") then
               Reg2Loc   <= '0';
               ALUSrc    <= '1'; -- Using immediates
               MemtoReg  <= '0';
               RegWrite  <= '1'; -- For write back
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '0';
               ALUOp(1)  <= '1'; -- idk i guess up to your interpretation
               ALUOP(0)  <= '1'; -- for ALUOp, only goes to alucontrol...
               UBranch   <= '0';

          -- R-format LDUR                                  ---
          elsif (Opcode=b"11111000010") then
               Reg2Loc   <= '-';   -- X
               ALUSrc    <= '1';
               MemtoReg  <= '1';
               RegWrite  <= '1';
               MemRead   <= '1';
               MemWrite  <= '0';
               CBranch   <= '0';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '0';
               UBranch   <= '0';

          -- R-format STUR                        ^ R-Format Instructions ^
          elsif (Opcode=b"11111000000") then
               Reg2Loc   <= '1';
               ALUSrc    <= '1';
               MemtoReg  <= '-';   -- X
               RegWrite  <= '0';
               MemRead   <= '0';
               MemWrite  <= '1';
               CBranch   <= '0';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '0';
               UBranch   <= '0';
          
          -- For I-format:
               -- 1001000100 : ADDI
               -- 1001001000 : ANDIIIIIIIIII-IIIII WILL ALWAYS
               -- 1011000100 : ADDIS
               -- 1101001000 : ORRI
               -- 1--100--00 "General Opcode"

          -- I-format ADDI, SUBI, ANDI,           - I-Format Instructions -
          elsif (Opcode(10 downto 1)?=b"1--100--00") then
               Reg2Loc   <= '0';
               ALUSrc    <= '1';
               MemtoReg  <= '0';   -- X
               RegWrite  <= '1';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '0';
               ALUOp(1)  <= '1';
               ALUOP(0)  <= '0';
               UBranch   <= '0';

          -- I-format specifically for ORRI... weird fix.
          elsif (Opcode(10 downto 1)=b"1101001000") then
               Reg2Loc   <= '0';
               ALUSrc    <= '1';
               MemtoReg  <= '0';   -- X
               RegWrite  <= '1';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '0';
               ALUOp(1)  <= '1';
               ALUOP(0)  <= '0';
               UBranch   <= '0';
          
          -- B-format B (uncond. branch)          - B-Format Instructions -
          elsif (Opcode(10 downto 5)=b"000101") then
               Reg2Loc   <= '-';
               ALUSrc    <= '-';
               MemtoReg  <= '0';
               RegWrite  <= '0';
               MemRead   <= '-';
               MemWrite  <= '0';
               CBranch   <= '1';
               ALUOp(1)  <= '-';
               ALUOP(0)  <= '-';
               UBranch   <= '1';

          -- CB-format CBZ (cond. branch zero)         v CB-Format Instructions v
          elsif (Opcode(10 downto 3)=b"10110100") then
               Reg2Loc   <= '1';
               ALUSrc    <= '0';
               MemtoReg  <= '-';
               RegWrite  <= '0';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '1';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '1';
               UBranch   <= '0';

          -- CB-format CBNZ (cond. branch if not zero) ^ CB-Format Instructions ^
          elsif (Opcode(10 downto 3)=b"10110101") then
               Reg2Loc   <= '1';
               ALUSrc    <= '0';
               MemtoReg  <= '-';
               RegWrite  <= '0';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '1';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '1';
               UBranch   <= '0';
          
          -- Misc: To handle NOP and undefined values!
          else
               Reg2Loc   <= '0';
               ALUSrc    <= '0';
               MemtoReg  <= '0';
               RegWrite  <= '0';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '0';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '0';
               UBranch   <= '0';

          end if;
     end process;
end behavioral;
