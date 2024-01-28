library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- "in" here refers to the input to the pipeline...
-- "out" refers to the output of the pipeline...
-- This might get confusing... Maybe some kind of SPI like naming convention might help?

entity IF_ID is
    port(
        clk                     : in std_logic;
        IFID_write_enable       : in std_logic;

        IFID_pc_address_in      : in STD_LOGIC_VECTOR(63 downto 0);
        IFID_IMEMReadData_in    : in STD_LOGIC_VECTOR(31 downto 0);
        -- *** ^ Before pipeline ^ / v After pipeline v *** --
        IFID_pc_address_out     : out STD_LOGIC_VECTOR(63 downto 0);
        IFID_IMEMReadData_out   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end IF_ID;

architecture dataflow of IF_ID is
begin
    process (clk) begin
        if rising_edge(clk) and IFID_write_enable = '1' then
            IFID_pc_address_out   <= IFID_pc_address_in;
            IFID_IMEMReadData_out <= IFID_IMEMReadData_in;
        end if;
        
    end process;
end dataflow;