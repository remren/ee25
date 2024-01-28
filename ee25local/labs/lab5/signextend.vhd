library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SignExtend is
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
);
end SignExtend;

architecture behavioral of SignExtend is

     -- Modified for lab3 to account for different instruction types.
          -- From the Green Card, textbook's Figure 4.22 isn't as helpful here.
          -- Also note, "-" denotes a "don't care"
          -- Note: Unsure if IM should be included. Those seem to be for MOVZ/MOVK...

          -- For R-format:
               -- Ignore FMULS, FADDD, etc. as those are floating point inst.
               -- 10001010000 : AND
               -- 10001011000 : ADD
               -- 10011011000 : MUL
               -- 11001011000 : SUB
               -- 11010011010 : LSR
               -- 11010011011 : LSL
               -- 10101010000 : ORR
               -- 1----01-0-- "General Opcode"

          -- For D-format:
               -- 00111000000 : STURB
               -- 10111000100 : STURW
               -- 11111000010 : LDUR
               -- 11001000010 : LDURS
               -- ----1000--0 "General Opcode"

          -- For CB-format:
               -- 01010100 : B.cond
               -- 10110100 : CBZ
               -- 10110101 : CBNZ
               -- [WRONG] ---101-- "General Opcode"
               -- Ignore B.cond for now... Use: "1011010-"

          -- For I-format:
               -- 1001000100 : ADDI
               -- 1001001000 : ANDIIIIIIIIII-IIIII WILL ALWAYS
               -- 1011000100 : ADDIS
               -- 1101001000 : ORRI
               -- 1--100--00 "General Opcode"

          -- For B-format:
               -- 100101 : BL
               -- 000101 : B
               -- -00101 "General Opcode"

     constant r_format_opcode  : std_logic_vector(10 downto 0) := "1----01-0--";
     constant d_format_opcode  : std_logic_vector(10 downto 0) := "----1000--0";
     constant cb_format_opcode : std_logic_vector(7 downto 0)  := "1011010-";
     constant i_format_opcode  : std_logic_vector(9 downto 0)  := "1--100--00";
     constant b_format_opcode  : std_logic_vector(5 downto 0)  := "-00101";
     -- constant undefined_instr  : std_logic_vector(10 downto 0) := "-----------";

begin

     -- Modified for lab3 to account for different instruction types.
     process (x) begin
          if    x(31 downto 21) ?= r_format_opcode then
               y <= (63 downto 6 => x(15))  & x(15 downto 10);

          elsif x(31 downto 21) ?= d_format_opcode then
               y <= (63 downto 9 => x(20))  & x(20 downto 12);

          elsif x(31 downto 24) ?= cb_format_opcode then
               y <= (63 downto 19 => x(23)) & x(23 downto 5);

          elsif x(31 downto 22) ?= i_format_opcode then
               y <= (63 downto 12 => x(21)) & x(21 downto 10);
          
          elsif x(31 downto 26) ?= b_format_opcode then
               y <= (63 downto 26 => x(25)) & x(25 downto 0);

          -- elsif x(31 downto 21) ?= undefined_instr then -- TODO: Check back if this causes bugs.
          --      y <= 64d"0";
          end if;

     end process;

end behavioral;