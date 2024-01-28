library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- "in" here refers to the input to the pipeline...
-- "out" refers to the output of the pipeline...
-- This might get confusing... Maybe some kind of SPI like naming convention might help?

entity MEM_WB is
    port(
         clk                            : in std_logic;

         MEMWB_MemtoReg_in              : in std_logic; -- WB control signal
         MEMWB_RegWrite_in              : in std_logic; -- WB control signal

         MEMWB_DMEMReadData_in          : in STD_LOGIC_VECTOR(63 downto 0);

         MEMWB_alu_result_in            : in STD_LOGIC_VECTOR(63 downto 0); -- for Mux at end

         MEMWB_rdrt_4_0_in              : in STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [4-0] 
         
         -- *** ^ Before pipeline ^ / v After pipeline v *** --

         MEMWB_MemtoReg_out             : out std_logic; -- WB control signal
         MEMWB_RegWrite_out             : out std_logic; -- WB control signal

         MEMWB_DMEMReadData_out         : out STD_LOGIC_VECTOR(63 downto 0);

         MEMWB_alu_result_out           : out STD_LOGIC_VECTOR(63 downto 0); -- for Mux at end

         MEMWB_rdrt_4_0_out             : out STD_LOGIC_VECTOR(4 downto 0)  -- Instruction [4-0] 
    );
end MEM_WB;

architecture dataflow of MEM_WB is
begin
    process (clk) begin
        if rising_edge(clk) then
            MEMWB_MemtoReg_out          <= MEMWB_MemtoReg_in;
            MEMWB_RegWrite_out          <= MEMWB_RegWrite_in;

            MEMWB_DMEMReadData_out      <= MEMWB_DMEMReadData_in;

            MEMWB_alu_result_out        <= MEMWB_alu_result_in;

            MEMWB_rdrt_4_0_out          <= MEMWB_rdrt_4_0_in;

        end if;
        
    end process;
end dataflow;