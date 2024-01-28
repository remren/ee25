library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hazarddetector is
    port(
        IFID_Rm         : in STD_LOGIC_VECTOR(4 downto 0);
        IFID_Rn         : in STD_LOGIC_VECTOR(4 downto 0);

        IDEX_MemRead    : in STD_LOGIC;
        IDEX_Rd         : in STD_LOGIC_VECTOR(4 downto 0);

        pc_write_enable     : out STD_LOGIC;
        IFID_write_enable   : out STD_LOGIC;
        hazardmux_select    : out STD_LOGIC -- either 0 or 1, for a 2 by 1 mux.
    );
end hazarddetector;

architecture dataflow of hazarddetector is

    signal stallpipeline_condition : STD_LOGIC;

begin
    -- Select line: hazardmux_select=0 pass all CPUC signals
    --              hazardmux_select=1 stall pipeline, set all control signals to 0
    stallpipeline_condition <= '1' when ((IDEX_MemRead = '1') and ((IDEX_Rd = IFID_Rn) or (IDEX_Rd = IFID_Rm))) else
                               '0';

    -- When pipeline stall condition is triggered, '1', set enables to LOW.
    pc_write_enable     <= '0' when stallpipeline_condition = '1' else
                           '1';
    IFID_write_enable   <= '0' when stallpipeline_condition = '1' else
                           '1';
    -- When pipeline stall condition is triggered, '1', set select to HIGH.
    -- LOW case is to allow regular CPUControl to pass through to ID/EX.
    hazardmux_select    <= '1' when stallpipeline_condition = '1' else
                           '0';

end architecture;