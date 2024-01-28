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
begin
     process (Opcode) is
     begin
          -- Setting any "don't cares" to 0.
     
               -- R-format ADD                         v R-Format Instructions v
          if (Opcode=b"10001011000") then
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

               -- R-format SUB                                   ---
          elsif (Opcode=b"11001011000") then
               Reg2Loc   <= '0';   -- Outputs seemingly same as ADD
               ALUSrc    <= '0';
               MemtoReg  <= '0';
               RegWrite  <= '1';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '0';
               ALUOp(1)  <= '1';
               ALUOP(0)  <= '0';
               UBranch   <= '0';

               -- R-format LDUR                                  ---
          elsif (Opcode=b"11111000010") then
               Reg2Loc   <= '0';   -- X
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
               MemtoReg  <= '0';   -- X
               RegWrite  <= '0';
               MemRead   <= '0';
               MemWrite  <= '1';
               CBranch   <= '0';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '0';
               UBranch   <= '0';
               
               -- I-format ADDI                        v I-Format Instructions v
          elsif (Opcode(10 downto 1)=b"1001000100") then
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
          
               -- I-format SUBI                        ^ I-Format Instructions ^
          elsif (Opcode(10 downto 1)=b"1101000100") then
               Reg2Loc   <= '0';   -- Assuming outputs are same as ADDI
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
               Reg2Loc   <= '0';
               ALUSrc    <= '0';
               MemtoReg  <= '0';
               RegWrite  <= '0';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '0';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '0';
               UBranch   <= '1';

               -- CB-format CBZ (cond. branch zero)   - CB-Format Instructions -
          elsif (Opcode(10 downto 3)=b"10110100") then
               Reg2Loc   <= '1';
               ALUSrc    <= '0';
               MemtoReg  <= '0';
               RegWrite  <= '0';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '1';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '1';
               UBranch   <= '0';
          -- elsif (Opcode ?= "-----------") then -- TODO: Check if this causes errors, supposed to account for undefined (no imem inst.) case.
          --      Reg2Loc   <= '0';
          --      ALUSrc    <= '0';
          --      MemtoReg  <= '0';
          --      RegWrite  <= '0';
          --      MemRead   <= '0';
          --      MemWrite  <= '0';
          --      CBranch   <= '0';
          --      ALUOp(1)  <= '0';
          --      ALUOP(0)  <= '0';
          --      UBranch   <= '0';
          end if;
     end process;
end behavioral;
