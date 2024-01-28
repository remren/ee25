library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PipelinedCPU0 is
port(
     clk : in STD_LOGIC;
     rst : in STD_LOGIC;
     --Probe ports used for testing
     --The current address (AddressOut from the PC)
     DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
     --The current instruction (Instruction Output of IMEM)
     DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
     --DEBUG ports from other components
     DEBUG_TMP_REGS     : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_SAVED_REGS   : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end PipelinedCPU0;

architecture structural of PipelinedCPU0 is

-- *** [COMPONENTS]: All components needed for Pipelined CPU *** --
component PC is
     port(
          clk          : in  STD_LOGIC;
          write_enable : in  STD_LOGIC;
          rst          : in  STD_LOGIC;
          AddressIn    : in  STD_LOGIC_VECTOR(63 downto 0);
          AddressOut   : out STD_LOGIC_VECTOR(63 downto 0)
     );
end component;

component IMEM is
     generic(NUM_BYTES : integer := 63);
     port(
          Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
          ReadData : out STD_LOGIC_VECTOR(31 downto 0)
     );
end component;

component IF_ID is
     port(
          clk                    : in std_logic;
          IFID_pc_address_in     : in STD_LOGIC_VECTOR(63 downto 0); -- Takes AddressOut from PC
          IFID_IMEMReadData_in   : in STD_LOGIC_VECTOR(31 downto 0); -- Takes ReadData from IMEM
          -- *** ^ Before pipeline ^ / v After pipeline v *** --
          IFID_pc_address_out    : out STD_LOGIC_VECTOR(63 downto 0);
          IFID_IMEMReadData_out  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end component;

component CPUControl is
     port(
          Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
          Reg2Loc  : out STD_LOGIC;
          CBranch  : out STD_LOGIC;  -- conditional
          MemRead  : out STD_LOGIC;
          MemtoReg : out STD_LOGIC;
          MemWrite : out STD_LOGIC;
          ALUSrc   : out STD_LOGIC;
          RegWrite : out STD_LOGIC;
          UBranch  : out STD_LOGIC; -- This is unconditional
          ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
     );
 end component;

component MUX5 is
     port(
          in0    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 0
          in1    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 1
          sel    : in STD_LOGIC; -- selects in0 or in1
          output : out STD_LOGIC_VECTOR(4 downto 0)
     );
end component;

component registers is
     port(
          RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
          RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
          WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
          WD       : in  STD_LOGIC_VECTOR (63 downto 0);
          RegWrite : in  STD_LOGIC;
          Clock    : in  STD_LOGIC;
          RD1      : out STD_LOGIC_VECTOR (63 downto 0);
          RD2      : out STD_LOGIC_VECTOR (63 downto 0);
          DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
          DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
     );
end component;

component SignExtend is
     port(
          x : in  STD_LOGIC_VECTOR(31 downto 0);
          y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
     );
end component;

component ID_EX is
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
          IDEX_rdrt_4_0_out          : out STD_LOGIC_VECTOR(4 downto 0)   -- Instruction [4-0] 
     );
end component;

component ALUControl is
     port(
          ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
          Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
          Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end component;

component ALU is
     port(
          in0       : in     STD_LOGIC_VECTOR(63 downto 0);
          in1       : in     STD_LOGIC_VECTOR(63 downto 0);
          operation : in     STD_LOGIC_VECTOR(3 downto 0);
          result    : buffer STD_LOGIC_VECTOR(63 downto 0);
          zero      : buffer STD_LOGIC;
          overflow  : buffer STD_LOGIC
     );
end component;

component MUX64 is
     port(
          in0    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
          in1    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
          sel    : in STD_LOGIC; -- selects in0 or in1
          output : out STD_LOGIC_VECTOR(63 downto 0)
     );
end component;

component EX_MEM is
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
end component;

component DMEM is
     port(
          WriteData          : in  STD_LOGIC_VECTOR(63 downto 0); -- Input data
          Address            : in  STD_LOGIC_VECTOR(63 downto 0); -- Read/Write address
          MemRead            : in  STD_LOGIC; -- Indicates a read operation
          MemWrite           : in  STD_LOGIC; -- Indicates a write operation
          Clock              : in  STD_LOGIC; -- Writes are triggered by a rising edge
          ReadData           : out STD_LOGIC_VECTOR(63 downto 0); -- Output data
          --Probe ports used for testing
          -- Four 64-bit words: DMEM(0) & DMEM(4) & DMEM(8) & DMEM(12)
          DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
     );
end component;

component ADD is
     port(
          in0    : in  STD_LOGIC_VECTOR(63 downto 0);
          in1    : in  STD_LOGIC_VECTOR(63 downto 0);
          output : out STD_LOGIC_VECTOR(63 downto 0)
     );
end component;

component ShiftLeft2 is
     port(
          x : in  STD_LOGIC_VECTOR(63 downto 0);
          y : out STD_LOGIC_VECTOR(63 downto 0) -- x << 2
     );
end component;

component MEM_WB is
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

          MEMWB_rdrt_4_0_out             : out STD_LOGIC_VECTOR(4 downto 0)   -- Instruction [4-0] 
    );
end component;

-- *** [SIGNALS FOR COMPONENTS] *** --
     
     -- Signals in commented form are unused, either as a result of direct connections
     --   from a lack of a need of a "buffer wire", development, or keeping track.

     -- ### Signals for PC ###
     signal pc_write_enable                  : std_logic;
     signal pc_address_in, pc_address_out    : std_logic_vector(63 downto 0);

     -- ### Signals for IMEM ###
     signal IMEMReadData : std_logic_vector(31 downto 0);

     -- ### Signals for IF_ID ###
     -- signal IFID_pc_address_in     : in STD_LOGIC_VECTOR(63 downto 0); -- Takes AddressOut from PC
     -- signal IFID_IMEMReadData_in   : in STD_LOGIC_VECTOR(63 downto 0); -- Takes ReadData from IMEM
     --           -- *** ^ Before pipeline ^ / v After pipeline v *** --
     signal IFID_pc_address_out    : STD_LOGIC_VECTOR(63 downto 0);
     signal IFID_IMEMReadData_out  : STD_LOGIC_VECTOR(31 downto 0);

     -- ### Signals for MUX5_IMEM_TO_RR2 ###
     signal mux5_output_imem_to_rr2 : std_logic_vector(4 downto 0);

     -- ### Signals for CPUControl ###
     signal Reg2Loc  : STD_LOGIC;
     signal CBranch  : STD_LOGIC;
     signal MemRead  : STD_LOGIC;
     signal MemtoReg : STD_LOGIC;
     signal MemWrite : STD_LOGIC;
     signal ALUSrc   : STD_LOGIC;
     signal RegWrite : STD_LOGIC;
     signal UBranch  : STD_LOGIC;
     signal ALUOp    : std_logic_vector(1 downto 0);

     -- ### Signals for registers ###
     -- signal RR1, RR2, WR     : std_logic_vector(4 downto 0);
     -- signal WD               : std_logic_vector(63 downto 0);
     signal RD1, RD2         : std_logic_vector(63 downto 0);
     signal reg_debugtemp    : std_logic_vector(64*4 - 1 downto 0);
     signal reg_debugsave    : std_logic_vector(64*4 - 1 downto 0);

     -- ### Signals for SignExtend ###
     signal sign_extend_output : std_logic_vector(63 downto 0);

     -- ### Signals for ID_EX ### (all post pipeline)
     signal IDEX_pc_address_out         : STD_LOGIC_VECTOR(63 downto 0);

     signal IDEX_ALUSrc_out             : std_logic; -- EX control signal
     signal IDEX_MemtoReg_out           : std_logic; -- WB control signal
     signal IDEX_RegWrite_out           : std_logic; -- WB control signal
     signal IDEX_MemRead_out            : std_logic; -- M control signal
     signal IDEX_MemWrite_out           : std_logic; -- M control signal
     signal IDEX_CBranch_out            : std_logic; -- M control signal
     signal IDEX_ALUOp_out              : STD_LOGIC_VECTOR(1 downto 0);  -- EX control signal
     signal IDEX_UBranch_out            : std_logic; -- M control signal

     signal IDEX_RD1_out                : STD_LOGIC_VECTOR(63 downto 0);
     signal IDEX_RD2_out                : STD_LOGIC_VECTOR(63 downto 0);

     signal IDEX_sign_extend_out        : STD_LOGIC_VECTOR(63 downto 0); -- gets output from SignExtend

     signal IDEX_opcode_31_21_out       : STD_LOGIC_VECTOR(10 downto 0); -- Instruction [31-21]
     signal IDEX_rdrt_4_0_out           : STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [4-0]

     -- ### Signals for ALUControl ###
     signal alucontrol_output : std_logic_vector(3 downto 0);

     -- ### Signals for MUX64_REGS_OR_SIGNEXTEND_TO_ALU ###
     signal mux64_output_to_alu : std_logic_vector(63 downto 0);

     -- ### Signals for ALU ###
     signal alu_result   : std_logic_vector(63 downto 0);
     signal alu_zero     : std_logic;
     signal overflow     : std_logic;

     -- ### Signals for EX/MEM ###
     signal EXMEM_shiftleft2_add_pc_out    : STD_LOGIC_VECTOR(63 downto 0);

     signal EXMEM_MemtoReg_out             : std_logic; -- WB control signal
     signal EXMEM_RegWrite_out             : std_logic; -- WB control signal
     signal EXMEM_MemRead_out              : std_logic; -- M control signal
     signal EXMEM_MemWrite_out             : std_logic; -- M control signal
     signal EXMEM_CBranch_out              : std_logic; -- M control signal
     signal EXMEM_UBranch_out              : std_logic; -- M control signal

     signal EXMEM_alu_zero_out             : std_logic;
     signal EXMEM_alu_result_out           : STD_LOGIC_VECTOR(63 downto 0);

     signal EXMEM_RD2_out                  : STD_LOGIC_VECTOR(63 downto 0); -- gets output from SignExtend

     signal EXMEM_rdrt_4_0_out             : STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [4-0] 

     -- ### Signals for DMEM ###
     signal DMEMReadData : std_logic_vector(63 downto 0);
     signal dmem_debug   : std_logic_vector(64*4 - 1 downto 0);

     -- ### Signals for MUX64_DMEM_OR_ALU_TO_REGS ###
     signal mux64_output_to_regs : std_logic_vector(63 downto 0);

     -- ### Signals for ADD_PC_4 ###
     signal add_output_pc_4 : std_logic_vector(63 downto 0);

     -- ### Signals for SHIFTLEFT2_FROM_SIGNEXTEND ###
     signal shiftleft2_output : std_logic_vector(63 downto 0);

     -- ### Signals for ADD_PC_SHIFTLEFT2 ###
     signal add_output_pc_shiftleft2 : std_logic_vector(63 downto 0);

     -- ### Signals for ALU_AND_CPUCONTROL ### (not an actual unit instance)
     signal and_output_alu_cpucontrol : std_logic;

     -- ### Signals for AND_OR_UBRANCH ### (not an actual unit instance)
     signal or_output_and_ubranch : std_logic;

     -- ### Signals for MUX64_RETURN_TO_PC ###
     -- signal mux64_output_return_to_pc : std_logic_vector(63 downto 0);

     -- ### Signals for MEM_WB ###
     signal MEMWB_MemtoReg_out             : std_logic; -- WB control signal
     signal MEMWB_RegWrite_out             : std_logic; -- WB control signal

     signal MEMWB_DMEMReadData_out         : STD_LOGIC_VECTOR(63 downto 0);

     signal MEMWB_alu_result_out           : STD_LOGIC_VECTOR(63 downto 0); -- for Mux at end

     signal MEMWB_rdrt_4_0_out             : STD_LOGIC_VECTOR(4 downto 0);  -- Instruction [4-0] 

begin

PC_0 : PC
     port map(
          clk          => clk,               -- Gets clk from top, (pipelined cpu)
          write_enable => pc_write_enable,   -- ? TBD Input, control signal
          rst          => rst,               -- Gets rst from top (plcpu)
          AddressIn    => pc_address_in,     -- Gets pc_address_in from MUX64_RETURN_TO_PC
          AddressOut   => pc_address_out     -- Output
     );
     pc_write_enable <= '1'; -- Doing this for lab3, not sure if change later... Still haven't changed for lab4...

IMEM_0 : IMEM
     generic map(
          NUM_BYTES => 64
     )
     port map(
          Address     => pc_address_out,     -- gets Address from PC
          ReadData    => IMEMReadData        -- Output
     );

IF_ID_0 : IF_ID
     port map(
          clk                    => clk,                    -- gets clk from Top
          IFID_pc_address_in     => pc_address_out,         -- gets pc_address_out from PC
          IFID_IMEMReadData_in   => IMEMReadData,           -- gets IMEMReadData from IMEM
               -- *** ^ Before pipeline ^ / v After pipeline v *** --
          IFID_pc_address_out    => IFID_pc_address_out,    -- Output
          IFID_IMEMReadData_out  => IFID_IMEMReadData_out   -- Output
     );

MUX5_IMEM_TO_RR2 : MUX5
     port map(
          in0       => IFID_IMEMReadData_out(20 downto 16), -- gets Instruction [20-16] from IF_ID
          in1       => IFID_IMEMReadData_out(4 downto 0),   -- gets Instruction [4-0] from IF_ID
          sel       => IFID_IMEMReadData_out(28),           -- gets Reg2Loc from IF_ID (see figure 4.50 in textbook)
          output    => mux5_output_imem_to_rr2              -- Output
     );

CPUC_0 : CPUControl
     port map(
          Opcode   => IFID_IMEMReadData_out(31 downto 21),  -- gets Instruction [31-21] from IF_ID
          Reg2Loc  => Reg2Loc,                              -- Outputs Reg2Loc to registers
          CBranch  => CBranch,                              -- ! Outputs to AND of ALU and CPUControl
          MemRead  => MemRead,                              -- Outputs MemRead to DMEM
          MemtoReg => MemtoReg,                             -- Outputs MemtoReg to MUX64_DMEM_OR_ALU_TO_REGS
          MemWrite => MemWrite,                             -- Outputs MemWrite to DMEM
          ALUSrc   => ALUSrc,                               -- Outputs ALUSrc to MUX64_RD2_TO_ALU
          RegWrite => RegWrite,                             -- Outputs RegWrite to registers
          UBranch  => UBranch,                              -- ! Outputs to OR of UBranch and AND from ALU/CPUControl
          ALUOp    => ALUOp                                 -- Outputs ALUOp to ALUControl
     );

REGS_0 : registers
     port map(
          RR1                 => IFID_IMEMReadData_out(9 downto 5), -- gets Instruction [9-5] from IF_ID
          RR2                 => mux5_output_imem_to_rr2,           -- gets either Instruction [20-16] or [4-0] from MUX5_IMEM_TO_RR2
          WR                  => MEMWB_rdrt_4_0_out,                -- gets Instruction [4-0] from MEM_WB
          WD                  => mux64_output_to_regs,              -- gets either alu_result or DMEMReadData from MUX64_DMEM_OR_ALU_TO_REGS
          RegWrite            => MEMWB_RegWrite_out,                -- gets RegWrite from MEM_WB (CPUControl) !!!
          Clock               => clk,                               -- gets clk from Top (plcpu)
          RD1                 => RD1,                               -- Outputs to ALU in0
          RD2                 => RD2,                               -- Outputs to MUX64_TO_ALU in0 and DMEM
          DEBUG_TMP_REGS      => reg_debugtemp,                     -- Outputs to Top via signal
          DEBUG_SAVED_REGS    => reg_debugsave                      -- Outputs to Top via signal
     );

SIGN_EXTEND_0 : SignExtend
     port map(
          x => IFID_IMEMReadData_out(31 downto 0), -- gets Instruction [31-0] from IF_ID
          y => sign_extend_output                  -- Outputs 64-bit sign extend result to MUX64_REGS_OR_SIGNEXTEND_TO_ALU and SHIFTLEFT2_FROM_SIGNEXTEND
     );

ID_EX_0 : ID_EX
     port map(
          clk                        => clk, -- gets from Top

          IDEX_pc_address_in         => IFID_pc_address_out, -- gets PC address from IF_ID
                                                  
          -- All below gets input from CPUControl
          IDEX_ALUSrc_in             => ALUSrc,   -- gets ALUSrc from CPUControl
          IDEX_MemtoReg_in           => MemtoReg, -- gets MemtoReg from CPUControl
          IDEX_RegWrite_in           => RegWrite, -- gets RegWrite from CPUControl
          IDEX_MemRead_in            => MemRead,
          IDEX_MemWrite_in           => MemWrite,
          IDEX_CBranch_in            => CBranch,
          IDEX_ALUOp_in              => ALUOp,
          IDEX_UBranch_in            => UBranch,

          -- All below gets input from registers
          IDEX_RD1_in                => RD1,
          IDEX_RD2_in                => RD2,

          IDEX_sign_extend_in        => sign_extend_output, -- gets from SignExtend

          IDEX_opcode_31_21_in       => IFID_IMEMReadData_out(31 downto 21),  -- gets Instruction [31-21] from IF_ID
          IDEX_rdrt_4_0_in           => IFID_IMEMReadData_out(4 downto 0),   -- gets Instruction [4-0] from IF_ID

          -- *** ^ Before pipeline ^ / v After pipeline v *** --

          -- All below output to signals
          IDEX_pc_address_out        => IDEX_pc_address_out,     -- Outputs to ADD_PC_SHIFTLEFT2

          IDEX_ALUSrc_out            => IDEX_ALUSrc_out,         -- Outputs to MUX64_REGS_OR_SIGNEXTEND_TO_ALU
          IDEX_MemtoReg_out          => IDEX_MemtoReg_out,       -- Outputs to EX_MEM (WB)
          IDEX_RegWrite_out          => IDEX_RegWrite_out,       -- Outputs to EX_MEM (WB)
          IDEX_MemRead_out           => IDEX_MemRead_out,        -- Outputs to EX_MEM (M)
          IDEX_MemWrite_out          => IDEX_MemWrite_out,       -- Outputs to EX_MEM (M)
          IDEX_CBranch_out           => IDEX_CBranch_out,        -- Outputs to EX_MEM (M)
          IDEX_ALUOp_out             => IDEX_ALUOp_out,          -- Outputs to ALUControl
          IDEX_UBranch_out           => IDEX_UBranch_out,        -- Outputs to EX_MEM (M)

          IDEX_RD1_out               => IDEX_RD1_out,            -- Outputs to ALU
          IDEX_RD2_out               => IDEX_RD2_out,            -- Outputs to MUX64_REGS_OR_SIGNEXTEND_TO_ALU and EX/MEM

          IDEX_sign_extend_out       => IDEX_sign_extend_out,    -- Outputs to MUX64_REGS_OR_SIGNEXTEND_TO_ALU
          
          IDEX_opcode_31_21_out      => IDEX_opcode_31_21_out,   -- Outputs to ALUControl
          IDEX_rdrt_4_0_out          => IDEX_rdrt_4_0_out        -- Outputs to MUX64_REGS_OR_SIGNEXTEND_TO_ALU and ShiftLeft2
     );

ALUCONTROL_0 : ALUControl
     port map(
          ALUOp     => IDEX_ALUOp_out,            -- gets ALUOp from ID_EX (CPUControl)
          OpCode    => IDEX_opcode_31_21_out,     -- gets Instruction [31-21] from ID_EX (IMEM)
          Operation => alucontrol_output          -- Outputs to ALU
     );

MUX64_REGS_OR_SIGNEXTEND_TO_ALU : MUX64
     port map(
          in0       => IDEX_RD2_out,         -- gets RD2 from ID_EX (registers)
          in1       => IDEX_sign_extend_out, -- gets sign_extend_output from ID_EX (SignExtend)
          sel       => IDEX_ALUSrc_out,      -- gets ALUSrc from ID_EX (CPUControl)
          output    => mux64_output_to_alu   -- Outputs either RD2 or sign_extend_output to ALU
     );

ALU_0 : ALU
     port map(
          in0       => IDEX_RD1_out,         -- gets RD1 from ID_EX (registers)
          in1       => mux64_output_to_alu,  -- gets either RD2 or sign_extend_output from MUX64_TO_ALU
          operation => alucontrol_output,    -- gets alucontrol_output from ALUControl
          result    => alu_result,           -- Outputs to EX_MEM (DMEM and MUX64_DMEM_OR_ALU_TO_REGS)
          zero      => alu_zero,             -- ! Outputs to EX_MEM (ALU_AND_CPUCONTROL)
          overflow  => overflow              -- ? TBD Output
     );

EX_MEM_0 : EX_MEM
     port map(
          clk                            => clk,                      -- gets from Top

          EXMEM_shiftleft2_add_pc_in     => add_output_pc_shiftleft2, -- gets from ADD_PC_SHIFTLEFT2

          EXMEM_MemtoReg_in              => IDEX_MemtoReg_out,        -- WB control signal
          EXMEM_RegWrite_in              => IDEX_RegWrite_out,        -- WB control signal
          EXMEM_MemRead_in               => IDEX_MemRead_out,         -- M control signal
          EXMEM_MemWrite_in              => IDEX_MemWrite_out,        -- M control signal
          EXMEM_CBranch_in               => IDEX_CBranch_out,         -- M control signal
          EXMEM_UBranch_in               => IDEX_UBranch_out,         -- M control signal

          EXMEM_alu_zero_in              => alu_zero,                 -- gets from ALU
          EXMEM_alu_result_in            => alu_result,               -- gets from ALU

          EXMEM_RD2_in                   => IDEX_RD2_out,

          EXMEM_rdrt_4_0_in              => IDEX_rdrt_4_0_out,        -- Instruction [4-0] 
          
          -- *** ^ Before pipeline ^ / v After pipeline v *** --

          EXMEM_shiftleft2_add_pc_out    => EXMEM_shiftleft2_add_pc_out, -- Outputs to MUX64_RETURN_TO_PC

          EXMEM_MemtoReg_out             => EXMEM_MemtoReg_out,       -- Outputs to MEM_WB (WB)
          EXMEM_RegWrite_out             => EXMEM_RegWrite_out,       -- Outputs to MEM_WB (WB)
          EXMEM_MemRead_out              => EXMEM_MemRead_out,        -- Outputs to DMEM (M)
          EXMEM_MemWrite_out             => EXMEM_MemWrite_out,       -- Outputs to DMEM (M)
          EXMEM_CBranch_out              => EXMEM_CBranch_out,        -- Outputs to ALU_AND_CPUCONTROL (M)
          EXMEM_UBranch_out              => EXMEM_UBranch_out,        -- Outputs to AND_OR_UBranch (M)

          EXMEM_alu_zero_out             => EXMEM_alu_zero_out,       -- Outputs to ALU_AND_CPUCONTROL
          EXMEM_alu_result_out           => EXMEM_alu_result_out,     -- Outputs to DMEM and MEM_WB

          EXMEM_RD2_out                  => EXMEM_RD2_out,            -- Outputs to DMEM

          EXMEM_rdrt_4_0_out             => EXMEM_rdrt_4_0_out        -- Outputs to MEM_WB
     );

DMEM_0 : DMEM
     port map(
          WriteData => EXMEM_RD2_out,        -- gets RD2 from EX_MEM (registers)
          Address   => EXMEM_alu_result_out, -- gets alu_result from EX_MEM (ALU)
          MemRead   => EXMEM_MemRead_out,    -- gets MemRead from EX_MEM (CPUControl)
          MemWrite  => EXMEM_MemWrite_out,   -- gets MemWrite from EX_MEM (CPUControl)
          Clock     => clk,                  -- gets clk from Top (plcpu)
          ReadData  => DMEMReadData,         -- Outputs to MEM/WB (MUX64_DMEM_OR_ALU_TO_REGS)
          DEBUG_MEM_CONTENTS => dmem_debug -- Outputs to DEBUG
     );

MUX64_DMEM_OR_ALU_TO_REGS : MUX64
     -- Note in Figure 4.23, 1 is at the top getting DMEMReadData and 0 is bottom getting alu_result
     port map(
          in0       => MEMWB_alu_result_out,      -- gets alu_result from MEM_WB (ALU)
          in1       => MEMWB_DMEMReadData_out,    -- gets DMEMReadData from MEM_WB (DMEM)
          sel       => MEMWB_MemtoReg_out,        -- gets MemtoReg from MEM_WB (CPUControl)
          output    => mux64_output_to_regs       -- Outputs either alu_result or DMEMReadData to in registers and forwarding mu
     );

-- [Following Figure 4.23 from Textbook Left to Right]

-- ### Remaining Paths Back to PC ###
ADD_PC_4 : ADD
     port map(
          in0    => pc_address_out, -- gets pc_address_out from PC
          in1    => 64d"4",         -- Always will add decimal 4
          output => add_output_pc_4 -- Outputs to MUX64_RETURN_TO_PC
     );

SHIFTLEFT2_FROM_SIGNEXTEND : ShiftLeft2
     port map(
          x => IDEX_sign_extend_out, -- gets sign_extend_output from ID_EX (SignExtend)
          y => shiftleft2_output     -- Outputs to ADD_PC_SHIFTLEFT2
     );
     
ADD_PC_SHIFTLEFT2 : ADD
     port map(
          in0    => IDEX_pc_address_out,     -- gets pc_address_out from ID_EX (PC)
          in1    => shiftleft2_output,       -- gets shiftleft2_output from SHIFTLEFT2_FROM_SIGNEXTEND
          output => add_output_pc_shiftleft2 -- Outputs to EX_MEM (MUX64_RETURN_TO_PC)
     );

-- ALU_AND_CPUCONTROL (CBranch)
     and_output_alu_cpucontrol <= EXMEM_CBranch_out and EXMEM_alu_zero_out;

-- AND_OR_UBranch
     or_output_and_ubranch     <= EXMEM_UBranch_out or and_output_alu_cpucontrol;

MUX64_RETURN_TO_PC : MUX64
     port map(
          in0       => add_output_pc_4,          -- gets add_output_pc_4 from ADD_PC_4
          in1       => EXMEM_shiftleft2_add_pc_out, -- gets add_output_pc_shiftleft2 from EX_MEM (ADD_PC_SHIFTLEFT2)
          sel       => or_output_and_ubranch,    -- gets or_output_and_ubranch as select
          output    => pc_address_in             -- Outputs to PC
     );

MEM_WB_0 : MEM_WB
     port map(
          clk                            => clk,                      -- gets from Top
          MEMWB_MemtoReg_in              => EXMEM_MemtoReg_out,       -- get from EX_MEM
          MEMWB_RegWrite_in              => EXMEM_RegWrite_out,       -- get from EX_MEM
          MEMWB_DMEMReadData_in          => DMEMReadData,             -- get from DMEM
          MEMWB_alu_result_in            => EXMEM_alu_result_out,     -- get from EX_MEM
          MEMWB_rdrt_4_0_in              => EXMEM_rdrt_4_0_out,       -- get from EX_MEM
          
          -- *** ^ Before pipeline ^ / v After pipeline v *** --
 
          MEMWB_MemtoReg_out             => MEMWB_MemtoReg_out,       -- Output to MUX64_DMEM_OR_ALU_TO_REGS
          MEMWB_RegWrite_out             => MEMWB_RegWrite_out,       -- Output to registers
          MEMWB_DMEMReadData_out         => MEMWB_DMEMReadData_out,   -- Output to MUX64_DMEM_OR_ALU_TO_REGS
          MEMWB_alu_result_out           => MEMWB_alu_result_out,     -- Output to MUX64_DMEM_OR_ALU_TO_REGS
          MEMWB_rdrt_4_0_out             => MEMWB_rdrt_4_0_out        -- Output to registers
     );

-- Look above for MUX64_DMEM_OR_ALU_TO_REGS, contains MemtoReg (WB)

     -- Debug Assignments
          DEBUG_PC            <= pc_address_out;
          DEBUG_INSTRUCTION   <= IMEMReadData;
          DEBUG_TMP_REGS      <= reg_debugtemp;
          DEBUG_SAVED_REGS    <= reg_debugsave;
          DEBUG_MEM_CONTENTS  <= dmem_debug;

end structural;