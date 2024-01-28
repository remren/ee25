library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity registers is
-- This component is described in the textbook, starting on section 4.3 
-- The indices of each of the registers can be found on the LEGv8 Green Card
-- Keep in mind that register XZR has a constant value of 0 and cannot be overwritten

-- This should only write on the negative edge of Clock when RegWrite is asserted.
-- Reads should be purely combinatorial, i.e. they don't depend on Clock
-- HINT: Use the provided dmem.vhd as a starting point
port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (63 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;
     RD1      : out STD_LOGIC_VECTOR (63 downto 0);
     RD2      : out STD_LOGIC_VECTOR (63 downto 0);
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
end registers;

architecture behavioral of registers is
type regarray is array (31 downto 0) of STD_LOGIC_VECTOR(63 downto 0);
signal regbytes : regarray;

begin

     -- Reads as said earlier, are entirely combinational
     RD2 <= regbytes(to_integer(unsigned(RR2)));
     RD1 <= regbytes(to_integer(unsigned(RR1)));

     process( Clock, RegWrite )      -- Run when any of these are changed
     variable first:boolean := true; -- Initialization
     begin
          if (first) then -- Entire area is memory data initialization
               regbytes(0)    <= x"0000000000000000"; -- v procedure args/results v
               regbytes(1)    <= x"0000000000000000";
               regbytes(2)    <= x"0000000000000000";
               regbytes(3)    <= x"0000000000000000";
               regbytes(4)    <= x"0000000000000000";
               regbytes(5)    <= x"0000000000000000";
               regbytes(7)    <= x"0000000000000000";
               regbytes(8)    <= x"0000000000000000"; -- ^ procedure args/results ^

               regbytes(9)    <= x"0000000000000000"; -- v temporaries v
               regbytes(10)   <= x"0000000000000001";
               regbytes(11)   <= x"0000000000000002";
               regbytes(12)   <= x"0000000000000004";
               regbytes(13)   <= x"0000000000000008";
               regbytes(14)   <= x"0000000000000010";
               regbytes(15)   <= x"0000000000000020"; -- ^ temporaries ^

               regbytes(16)   <= x"0000000000000000"; -- IP0
               regbytes(17)   <= x"0000000000000000"; -- IP1
               regbytes(18)   <= x"0000000000000000"; -- Platform Reg or Temp Reg

               regbytes(19)   <= x"0000000000000008"; -- v     Saved     v
               regbytes(20)   <= x"0000000000000000";
               regbytes(21)   <= x"0000000000000002";
               regbytes(22)   <= x"0000000000000004";
               regbytes(23)   <= x"0000000000000010";
               regbytes(24)   <= x"0000000000000020";
               regbytes(25)   <= x"0000000000000040";
               regbytes(26)   <= x"0000000000000080";
               regbytes(27)   <= x"0000000000000080"; -- ^     Saved     ^

               regbytes(28)   <= x"0000000000000000"; -- SP
               regbytes(29)   <= x"0000000000000000"; -- FP
               regbytes(30)   <= x"0000000000000000"; -- LR
               regbytes(31)   <= x"0000000000000000"; -- XZR, const. 0
               
               first := false; -- Do not initialize next time process is ran
          end if;

          -- WR has 5 bits, so 31st register is accessed via b"10000"
          if falling_edge(Clock) and RegWrite = '1' then 
               if WR /= b"10000" then
                    regbytes(to_integer(unsigned(WR))) <= WD;
               else report "Invalid write to XZR." severity error;
               end if;
          end if;
     end process;
     DEBUG_TMP_REGS <=
          regbytes( 9) & regbytes(10) & regbytes(11) & regbytes(12);
     DEBUG_SAVED_REGS <=
          regbytes(19) & regbytes(20) & regbytes(21) & regbytes(22);
end behavioral;