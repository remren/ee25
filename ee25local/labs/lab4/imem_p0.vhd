library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IMEM is
-- The instruction memory is a byte addressable, big-endian, read-only memory
-- Reads occur continuously
generic(NUM_BYTES : integer := 64);
-- NUM_BYTES is the number of bytes in the memory (small to save computation resources)
port(
     Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
     ReadData : out STD_LOGIC_VECTOR(31 downto 0)
);
end IMEM;

architecture behavioral of IMEM is
type ByteArray is array (0 to NUM_BYTES) of STD_LOGIC_VECTOR(7 downto 0); 
signal imemBytes:ByteArray;
-- add and load has been updated
begin
process(Address)
variable addr:integer;
variable first:boolean:=true;
begin
	if(first) then
		-- AND X9, X12, X10
		imemBytes(3) <= "10001010";
		imemBytes(2) <= "00001010";
		imemBytes(1) <= "00000001";
		imemBytes(0) <= "10001001";

		-- LSR X10, X10, 1
		imemBytes(7) <= "11010011";
		imemBytes(6) <= "01000000";
		imemBytes(5) <= "00000101";
		imemBytes(4) <= "01001010";

		-- LSL X11, X11, 1
		imemBytes(11) <= "11010011";
		imemBytes(10) <= "01100000";
		imemBytes(9) <= "00000101";
		imemBytes(8) <= "01101011";

		-- ANDI X12, X12, 15
		imemBytes(15) <= "10010010";
		imemBytes(14) <= "00000000";
		imemBytes(13) <= "00111101";
		imemBytes(12) <= "10001100";

		-- ORR X21, X19, X20
		imemBytes(19) <= "10101010";
		imemBytes(18) <= "00010100";
		imemBytes(17) <= "00000010";
		imemBytes(16) <= "01110101";

		-- ORRI X22, X22, 15
		imemBytes(23) <= "10110010";
		imemBytes(22) <= "00000000";
		imemBytes(21) <= "00111110";
		imemBytes(20) <= "11010110";

		-- NOP
		imemBytes(27) <= "00000000";
		imemBytes(26) <= "00000000";
		imemBytes(25) <= "00000000";
		imemBytes(24) <= "00000000";

		-- NOP
		imemBytes(31) <= "00000000";
		imemBytes(30) <= "00000000";
		imemBytes(29) <= "00000000";
		imemBytes(28) <= "00000000";

		-- NOP
		imemBytes(35) <= "00000000";
		imemBytes(34) <= "00000000";
		imemBytes(33) <= "00000000";
		imemBytes(32) <= "00000000";
	first:=false;
   end if;
   addr:=to_integer(unsigned(Address));
   if (addr+3 < NUM_BYTES) then -- Check that the address is within the bounds of the memory
      ReadData<=imemBytes(addr+3) & imemBytes(addr+2) & imemBytes(addr+1) & imemBytes(addr+0);
   else report "Invalid IMEM addr. Attempted to read 4-bytes starting at address " &
      integer'image(addr) & " but only " & integer'image(NUM_BYTES) & " bytes are available"
      severity error;
   end if;

end process;

end behavioral;

