library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forwardingunit is
    port(
        IDEX_Rn         : in std_logic_vector(4 downto 0); -- Instruction[9-5]
        IDEX_Rm         : in std_logic_vector(4 downto 0); -- Instruction[20-16]
        IDEX_Rt         : in std_logic_vector(4 downto 0); -- Instruction[4-0]

        EXMEM_Rd        : in std_logic_vector(4 downto 0); -- Instruction[4-0]
        MEMWB_Rd        : in std_logic_vector(4 downto 0); -- Instruction[4-0]

        EXMEM_RegWrite  : in std_logic;
        MEMWB_RegWrite  : in std_logic;

        forward_a       : out std_logic_vector(1 downto 0);
        forward_b       : out std_logic_vector(1 downto 0)
    );
end forwardingunit;

architecture dataflow of forwardingunit is

    constant XZR : std_logic_vector(4 downto 0) := b"11111";
    -- See pg.322 in Textbook, Figure 4.54 for table.

begin

    process(all) begin
        -- EX hazard
        if ( EXMEM_RegWrite = '1' and (EXMEM_Rd /= "11111") and (EXMEM_Rd = IDEX_Rn) ) then
            forward_a <= "10";
        -- MEM hazard
        elsif (MEMWB_RegWrite = '1'
            and (MEMWB_Rd /= "11111")
            and not (EXMEM_RegWrite = '1' and (EXMEM_Rd /= "1111")
            and (EXMEM_Rd = IDEX_Rn))
            and (MEMWB_Rd = IDEX_Rn) ) then
            forward_a <= "01";
        else
            forward_a <= "00";
        end if;

        -- EX Hazard
        if ( EXMEM_RegWrite = '1' and (EXMEM_Rd /= "11111") and (EXMEM_Rd = IDEX_Rm) ) then
            forward_b <= "10";
        -- MEM Hazard
        elsif (MEMWB_RegWrite = '1'
                and (MEMWB_Rd /= "11111")
                and not (EXMEM_RegWrite = '1' and (EXMEM_Rd /= "1111")
                and (EXMEM_Rd = IDEX_Rm))
                and (MEMWB_Rd = IDEX_Rm) ) then
                forward_b <= "01";
        else
            forward_b <= "00";
        end if;
    end process;
                    
                    -- EX Hazard? First ALU operand from prior (within last pipeline stage?) ALU result, in this case from EX/MEM
    forward_a <=    b"10" when ((EXMEM_RegWrite = '1') and (EXMEM_Rd /= XZR) and (EXMEM_Rd = IDEX_Rn)) else
                    -- MEM Hazard?
                    b"01" when (MEMWB_RegWrite = '1'
                                and (MEMWB_Rd /= XZR)
                                and not (EXMEM_RegWrite = '1' and EXMEM_Rd /= XZR)
                                and (EXMEM_Rd = IDEX_Rn)
                                and (MEMWB_Rd = IDEX_Rn)) else
                    -- All other cases (typically no forwarding)
                    b"00";

    --                     -- MEM Hazard?
    -- -- forward_a <=    b"01" when (MEMWB_RegWrite = '1'
    -- --                             and (MEMWB_Rd /= XZR)
    -- --                             and (MEMWB_Rd = IDEX_Rn)) else
    -- --                 -- EX Hazard? First ALU operand from prior (within last pipeline stage?) ALU result, in this case from EX/MEM
    -- --                 b"10" when (((EXMEM_RegWrite = '1') and EXMEM_Rd /= XZR) and ((EXMEM_Rd = IDEX_Rn) or (EXMEM_Rd = IDEX_Rm))) else
    -- --                 -- All other cases (typically no forwarding)
    -- --                 b"00";

                    -- EX Hazard, Second ALU operand from prior (within last pipeline stage?) ALU result, in this case from MEMWB?
    forward_b <=    b"10" when ((EXMEM_RegWrite = '1') and (EXMEM_Rd /= XZR) and (EXMEM_Rd = IDEX_Rm)) else
                    -- MEM Hazard
                    b"01" when (MEMWB_RegWrite = '1' -- 1
                                and (MEMWB_Rd /= XZR) -- 1
                                and not (EXMEM_RegWrite = '1' and EXMEM_Rd /= XZR) -- not ((1) and (1)) = 0
                                and (EXMEM_Rd = IDEX_Rm)
                                and (MEMWB_Rd = IDEX_Rm)) else
                    b"00";
    
    --                 -- MEM Hazard
    -- -- forward_b <=    b"01" when (MEMWB_RegWrite = '1'
    -- --                             and (MEMWB_Rd /= XZR)
    -- --                             and (MEMWB_Rd = IDEX_Rm)) else
    -- --                 -- EX Hazard? First ALU operand from prior (within last pipeline stage?) ALU result, in this case from EX/MEM
    -- --                 b"10" when (((EXMEM_RegWrite = '1') and EXMEM_Rd /= XZR) and ((EXMEM_Rd = IDEX_Rn) or (EXMEM_Rd = IDEX_Rm))) else
    -- --                 -- All other cases (typically no forwarding)
    -- --                 b"00";

end architecture;