library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity tregisters is
-- This component is described in the textbook, starting on section 4.3
-- The indices of each of the registers can be found on the LEGv8 Green Card
-- Keep in mind that register XZR has a constant value of 0 and cannot be overwritten
-- This should only write on the negative edge of Clock when RegWrite is asserted.
-- Reads should be purely combinatorial, i.e. they don't depend on Clock
-- HINT: Use the provided dmem.vhd as a starting point
port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); -- read 1
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); -- read 2
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); -- write
     WD       : in  STD_LOGIC_VECTOR (63 downto 0);-- write data
     RegWrite : in  STD_LOGIC;                     -- write enable
     Clock    : in  STD_LOGIC;                     -- clock; check if write on each clock cycle
     RD1      : out STD_LOGIC_VECTOR (63 downto 0);-- read 1 data
     RD2      : out STD_LOGIC_VECTOR (63 downto 0);-- read 2 data
     --Probe ports used for testing.
     -- Notice the width of the port means that you are
     --      reading only part of the register file.
     -- This is only for debugging
     -- You are debugging a sebset of registers here
     -- Temp registers: $X9 & $X10 & X11 & X12
     -- 4 refers to number of registers you are debugging
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     -- Saved Registers X19 & $X20 & X21 & X22
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0) 
);
end tregisters;
architecture behavioral of tregisters is
     type RegisterArray is array (31 downto 0) of std_logic_vector(63 downto 0);
     signal Regs:RegisterArray;
begin
     RD1 <= Regs(to_integer(unsigned(RR1))); -- read 1 
     RD2 <= Regs(to_integer(unsigned(RR2))); -- read 2
     process(Clock, RegWrite)

     -- Initialize Reg
     variable first:boolean := true;
     begin
          if (first) then
               Regs(0) <= X"0000000000000000";  -- Argument / Result
               Regs(1) <= X"0000000000000000";  --         .
               Regs(2) <= X"0000000000000000";  --         .
               Regs(3) <= X"0000000000000000";  --         .
               Regs(4) <= X"0000000000000000";  --         .
               Regs(5) <= X"0000000000000000";  --         .
               Regs(6) <= X"0000000000000000";  --         .
               Regs(7) <= X"0000000000000000";  -- Argument / Result
               Regs(8) <= X"0000000000000000";  -- Indirect Result Location Register
               Regs(9) <= X"0000000000000000";  -- Temporaries
               Regs(10) <= X"0000000000000001"; --      .
               Regs(11) <= X"0000000000000002"; --      .
               Regs(12) <= X"0000000000000004"; --      .
               Regs(13) <= X"0000000000000008"; --      .
               Regs(14) <= X"0000000000000010"; --      .
               Regs(15) <= X"0000000000000020"; -- Temporaries
               Regs(16) <= X"0000000000000000"; -- IP0
               Regs(17) <= X"0000000000000000"; -- IP1
               Regs(18) <= X"0000000000000000"; -- Platform
               Regs(19) <= X"0000000000000008"; -- Saved
               Regs(20) <= X"0000000000000000"; --   .
               Regs(21) <= X"0000000000000002"; --   .
               Regs(22) <= X"0000000000000004"; --   .
               Regs(23) <= X"0000000000000010"; --   .
               Regs(24) <= X"0000000000000020"; --   .
               Regs(25) <= X"0000000000000040"; --   .
               Regs(26) <= X"0000000000000080"; --   .
               Regs(27) <= X"0000000000000080"; -- Saved
               Regs(28) <= X"0000000000000000"; -- SP
               Regs(29) <= X"0000000000000000"; -- FP
               Regs(30) <= X"0000000000000000"; -- LR
               Regs(31) <= X"0000000000000000"; -- XZR
               first := false;
          end if;
          
          if falling_edge(Clock) and RegWrite = '1' then
               Regs(to_integer(unsigned(WR))) <= WD;
          end if;
     end process;
     DEBUG_TMP_REGS <=
          Regs(9) & Regs(10) & Regs(11) & Regs(12);
     DEBUG_SAVED_REGS <=
          Regs(19) & Regs(20) & Regs(21) & Regs(22);
end behavioral;