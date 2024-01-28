library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hazardmux is -- Three by one mux with 64 bit inputs/outputs
port(
    -- Select line: hazardmux_select=0 pass all CPUC signals
    --              hazardmux_select=1 stall pipeline, set all control signals to 0
    hazardmux_select : in STD_LOGIC;

    CPUC_ALUSrc     : in std_logic; -- EX control signal
    CPUC_MemtoReg   : in std_logic; -- WB control signal
    CPUC_RegWrite   : in std_logic; -- WB control signal
    CPUC_MemRead    : in std_logic; -- M control signal
    CPUC_MemWrite   : in std_logic; -- M control signal
    CPUC_CBranch    : in std_logic; -- M control signal
    CPUC_ALUOp      : in STD_LOGIC_VECTOR(1 downto 0);  -- EX control signal
    CPUC_UBranch    : in std_logic; -- M control signal

    hazardmux_ALUSrc     : out std_logic; -- EX control signal
    hazardmux_MemtoReg   : out std_logic; -- WB control signal
    hazardmux_RegWrite   : out std_logic; -- WB control signal
    hazardmux_MemRead    : out std_logic; -- M control signal
    hazardmux_MemWrite   : out std_logic; -- M control signal
    hazardmux_CBranch    : out std_logic; -- M control signal
    hazardmux_ALUOp      : out STD_LOGIC_VECTOR(1 downto 0);  -- EX control signal
    hazardmux_UBranch    : out std_logic  -- M control signal

);
end hazardmux;

architecture dataflow of hazardmux is
begin
    -- Not sure about the default ALUOp value when stalling... Check if errors.
    hazardmux_ALUSrc    <= CPUC_ALUSrc   when hazardmux_select = '0' else '0';
    hazardmux_MemtoReg  <= CPUC_MemtoReg when hazardmux_select = '0' else '0';
    hazardmux_RegWrite  <= CPUC_RegWrite when hazardmux_select = '0' else '0';
    hazardmux_MemRead   <= CPUC_MemRead  when hazardmux_select = '0' else '0';
    hazardmux_MemWrite  <= CPUC_MemWrite when hazardmux_select = '0' else '0';
    hazardmux_CBranch   <= CPUC_CBranch  when hazardmux_select = '0' else '0';
    hazardmux_ALUOp     <= CPUC_ALUOp    when hazardmux_select = '0' else b"00";
    hazardmux_UBranch   <= CPUC_UBranch  when hazardmux_select = '0' else '0';

end dataflow;