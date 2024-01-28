library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- "in" here refers to the input to the pipeline...
-- "out" refers to the output of the pipeline...
-- This might get confusing... Maybe some kind of SPI like naming convention might help?

entity EX_MEM is
    port(
         clk                            : in std_logic;

         EXMEM_shiftleft2_add_pc_in     : in STD_LOGIC_VECTOR(63 downto 0);

         EXMEM_MemtoReg_in              : in std_logic; -- WB control signal
         EXMEM_RegWrite_in              : in std_logic; -- WB control signal
         EXMEM_MemRead_in               : in std_logic; -- M control signal
         EXMEM_MemWrite_in              : in std_logic; -- M control signal
         EXMEM_CBranch_in               : in std_logic; -- M control signal
         EXMEM_UBranch_in               : in std_logic; -- M control signal

         EXMEM_alu_zero_in              : in std_logic;
         EXMEM_alu_result_in            : in STD_LOGIC_VECTOR(63 downto 0);

         EXMEM_RD2_in                   : in STD_LOGIC_VECTOR(63 downto 0); -- gets output from SignExtend

         EXMEM_rdrt_4_0_in              : in STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [4-0] 
         
         -- *** ^ Before pipeline ^ / v After pipeline v *** --

         EXMEM_shiftleft2_add_pc_out    : out STD_LOGIC_VECTOR(63 downto 0);

         EXMEM_MemtoReg_out             : out std_logic; -- WB control signal
         EXMEM_RegWrite_out             : out std_logic; -- WB control signal
         EXMEM_MemRead_out              : out std_logic; -- M control signal
         EXMEM_MemWrite_out             : out std_logic; -- M control signal
         EXMEM_CBranch_out              : out std_logic; -- M control signal
         EXMEM_UBranch_out              : out std_logic; -- M control signal

         EXMEM_alu_zero_out             : out std_logic;
         EXMEM_alu_result_out           : out STD_LOGIC_VECTOR(63 downto 0);

         EXMEM_RD2_out                  : out STD_LOGIC_VECTOR(63 downto 0); -- gets output from SignExtend

         EXMEM_rdrt_4_0_out             : out STD_LOGIC_VECTOR(4 downto 0)   -- Instruction [4-0] 
    );
end EX_MEM;

architecture dataflow of EX_MEM is
begin
    process (clk) begin
        if rising_edge(clk) then
            EXMEM_shiftleft2_add_pc_out <= EXMEM_shiftleft2_add_pc_in;

            EXMEM_MemtoReg_out          <= EXMEM_MemtoReg_in;
            EXMEM_RegWrite_out          <= EXMEM_RegWrite_in;
            EXMEM_MemRead_out           <= EXMEM_MemRead_in;
            EXMEM_MemWrite_out          <= EXMEM_MemWrite_in;
            EXMEM_CBranch_out           <= EXMEM_CBranch_in;
            EXMEM_UBranch_out           <= EXMEM_UBranch_in;                       
            
                        
                                  
            EXMEM_alu_zero_out          <= EXMEM_alu_zero_in;
            EXMEM_alu_result_out        <= EXMEM_alu_result_in;

            EXMEM_RD2_out               <= EXMEM_RD2_in;

            EXMEM_rdrt_4_0_out          <= EXMEM_rdrt_4_0_in;

        end if;
        
    end process;
end dataflow;