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

architecture structural of CPUControl is 
     process (Opcode, MemWrite, ALUOp) begin
               -- R-format ADD, Incorrect, need to account for ADD/SUB/AND/ORR in X values
          if (Opcode(10)='1' and Opcode(7 downto 4)="0101" and Opcode(2 downto 0)="000") then
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

               -- LDUR
          elsif (Opcode="11111000010") then
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

               -- STUR
          elsif (Opcode="11111000000") then
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
               
               -- CBZ, Incorrect (?) account for X in opcode?
          elsif (Opcode(10 downto 3)="10110100") then
               Reg2Loc   <= '1';
               ALUSrc    <= '0';
               MemtoReg  <= '0';   -- X
               RegWrite  <= '0';
               MemRead   <= '0';
               MemWrite  <= '0';
               CBranch   <= '1';
               ALUOp(1)  <= '0';
               ALUOP(0)  <= '1';
               UBranch   <= '0';
          end if;
     end process;
end structural;
