library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- "in" here refers to the input to the pipeline...
-- "out" refers to the output of the pipeline...
-- This might get confusing... Maybe some kind of SPI like naming convention might help?

entity ID_EX is
    port(
        clk                        : in std_logic;

        IDEX_pc_address_in         : in STD_LOGIC_VECTOR(63 downto 0);

        IDEX_ALUSrc_in             : in std_logic; -- EX control signal
        IDEX_MemtoReg_in           : in std_logic; -- WB control signal
        IDEX_RegWrite_in           : in std_logic; -- WB control signal
        IDEX_MemRead_in            : in std_logic; -- M control signal
        IDEX_MemWrite_in           : in std_logic; -- M control signal
        IDEX_CBranch_in            : in std_logic; -- M control signal
        IDEX_ALUOp_in              : in STD_LOGIC_VECTOR(1 downto 0);  -- EX control signal
        IDEX_UBranch_in            : in std_logic; -- M control signal

        IDEX_RD1_in                : in STD_LOGIC_VECTOR(63 downto 0);
        IDEX_RD2_in                : in STD_LOGIC_VECTOR(63 downto 0);

        IDEX_sign_extend_in        : in STD_LOGIC_VECTOR(63 downto 0); -- gets output from SignExtend

        IDEX_opcode_31_21_in       : in STD_LOGIC_VECTOR(10 downto 0); -- Instruction [31-21]
        IDEX_rdrt_4_0_in           : in STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [4-0]

        IDEX_Rm_in                 : in STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [20-16]
        IDEX_Rn_in                 : in STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [9-5]
        
        -- *** ^ Before pipeline ^ / v After pipeline v *** --
        IDEX_pc_address_out        : out STD_LOGIC_VECTOR(63 downto 0);

        IDEX_ALUSrc_out            : out std_logic; -- EX control signal
        IDEX_MemtoReg_out          : out std_logic; -- WB control signal
        IDEX_RegWrite_out          : out std_logic; -- WB control signal
        IDEX_MemRead_out           : out std_logic; -- M control signal
        IDEX_MemWrite_out          : out std_logic; -- M control signal
        IDEX_CBranch_out           : out std_logic; -- M control signal
        IDEX_ALUOp_out             : out STD_LOGIC_VECTOR(1 downto 0);  -- EX control signal
        IDEX_UBranch_out           : out std_logic; -- M control signal

        IDEX_RD1_out               : out STD_LOGIC_VECTOR(63 downto 0);
        IDEX_RD2_out               : out STD_LOGIC_VECTOR(63 downto 0);

        IDEX_sign_extend_out       : out STD_LOGIC_VECTOR(63 downto 0); -- gets output from SignExtend

        IDEX_opcode_31_21_out      : out STD_LOGIC_VECTOR(10 downto 0); -- Instruction [31-21]
        IDEX_rdrt_4_0_out          : out STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [4-0]

        IDEX_Rm_out                : out STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [20-16]
        IDEX_Rn_out                : out STD_LOGIC_VECTOR(4 downto 0)   -- Instruction [9-5]
    );
end ID_EX;

architecture dataflow of ID_EX is

    -- signal IDEX_RD1 : STD_LOGIC_VECTOR(63 downto 0);
    
begin
    process (clk) begin
        if rising_edge(clk) then
            IDEX_pc_address_out     <= IDEX_pc_address_in;

            IDEX_ALUSrc_out         <= IDEX_ALUSrc_in;
            IDEX_MemtoReg_out       <= IDEX_MemtoReg_in;
            IDEX_RegWrite_out       <= IDEX_RegWrite_in;
            IDEX_MemRead_out        <= IDEX_MemRead_in;
            IDEX_MemWrite_out       <= IDEX_MemWrite_in;
            IDEX_CBranch_out        <= IDEX_CBranch_in;
            IDEX_ALUOp_out          <= IDEX_ALUOp_in;
            IDEX_UBranch_out        <= IDEX_UBranch_in;

            IDEX_RD1_out            <= IDEX_RD1_in;
            IDEX_RD2_out            <= IDEX_RD2_in;

            IDEX_sign_extend_out    <= IDEX_sign_extend_in;

            IDEX_opcode_31_21_out   <= IDEX_opcode_31_21_in;
            IDEX_rdrt_4_0_out       <= IDEX_rdrt_4_0_in;

            IDEX_Rm_out             <= IDEX_Rm_in;
            IDEX_Rn_out             <= IDEX_Rn_in;
        end if;
        
    end process;

end dataflow;