library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hazarddetectionunit is
    port(
        IDEX_Rn         : in std_logic_vector(4 downto 0);
        IDEX_Rm         : in std_logic_vector(4 downto 0);
        EXMEM_Rd        : in std_logic_vector(4 downto 0);
        MEMWB_Rd        : in std_logic_vector(4 downto 0);

        EXMEM_RegWrite  : in std_logic;
        MEMWB_RegWrite  : in std_logic;

        forward_a       : out std_logic_vector(1 downto 0);
        forward_b       : out std_logic_vector(1 downto 0)
    );
end hazarddetectionunit;

architecture dataflow of hazarddetectionunit is

    constant XZR : std_logic_vector(4 downto 0) := b"11111";
    -- See pg.322 in Textbook, Figure 4.54 for table.

begin
    forward_a <=    b"01" when (MEMWB_RegWrite = '1' and
                                (MEMWB_Rd /= XZR) and not
                                ((EXMEM_RegWrite = '1') and (EXMEM_Rd /= XZR)) and
                                (EXMEM_Rd = IDEX_Rn) and
                                (MEMWB_Rd = IDEX_Rn)) else
                    -- First ALU operand from prior (within last pipeline stage?) ALU result, in this case from EX/MEM
                    b"10" when ((EXMEM_Rd = IDEX_Rn) or (EXMEM_Rd = IDEX_Rm)) else
                    -- All other cases (typically no forwarding)
                    b"00";

    forward_b <=    b"01" when (MEMWB_RegWrite = '1' and
                                (MEMWB_Rd /= XZR) and not
                                ((EXMEM_RegWrite = '1') and (EXMEM_Rd /= XZR)) and
                                (EXMEM_Rd = IDEX_Rm) and
                                (MEMWB_Rd = IDEX_Rm)) else
                    -- Second ALU operand from prior (within last pipeline stage?) ALU result, in this case from MEMWB?
                    -- TODO: CHECK IF THIS CAUSES FAILURES... NOT TO SURE ABOUT THIS LINE
                    b"10" when ((EXMEM_Rd = IDEX_Rn) or (EXMEM_Rd = IDEX_Rm)) else
                    b"00";

end architecture;