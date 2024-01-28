library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SingleCycleCPU is
port(clk :in STD_LOGIC;
     rst :in STD_LOGIC;
     --Probe ports used for testing
     --The current address (AddressOut from the PC)
     DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
     --The current instruction (Instruction output of IMEM)
     DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
     --DEBUG ports from other components
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end SingleCycleCPU;

architecture structural of SingleCycleCPU is
-- *** [COMPONENTS]: All components needed for SingleCycle CPU *** --
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

-- *** [SIGNALS FOR COMPONENTS] *** --
     
     -- Signals in commented form are unused, either as a result of direct connections
     --   from a lack of a need of a "buffer wire", development, or keeping track.

     -- ### Signals for PC ###
     signal pc_write_enable                  : std_logic;
     signal pc_address_in, pc_address_out    : std_logic_vector(63 downto 0);

     -- ### Signals for IMEM ###
     signal IMEMReadData : std_logic_vector(31 downto 0);

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

     -- ### Signals for ALUControl ###
     signal alucontrol_output : std_logic_vector(3 downto 0);

     -- ### Signals for MUX64_REGS_OR_SIGNEXTEND_TO_ALU ###
     signal mux64_output_to_alu : std_logic_vector(63 downto 0);

     -- ### Signals for ALU ###
     signal alu_result   : std_logic_vector(63 downto 0);
     signal alu_zero     : std_logic;
     signal overflow     : std_logic;

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

     -- ### Signals for ALU_AND_CPUCONTROL ### (not an actual unit)
     signal and_output_alu_cpucontrol : std_logic;

     -- ### Signals for AND_OR_UBRANCH ### (not an actual unit)
     signal or_output_and_ubranch : std_logic;

     -- ### Signals for MUX64_RETURN_TO_PC ###
     -- signal mux64_output_return_to_pc : std_logic_vector(63 downto 0);

begin

PC_0 : PC
     port map(
          clk          => clk,               -- Gets clk from top, singlecyclecpu (sccpu)
          write_enable => pc_write_enable,   -- ? TBD Input, control signal
          rst          => rst,               -- Gets rst from top (sccpu)
          AddressIn    => pc_address_in,     -- ? TBD Input
          AddressOut   => pc_address_out     -- Output
     );
     pc_write_enable <= '1'; -- Doing this for lab3, not sure if change later...

IMEM_0 : IMEM
     generic map(
          NUM_BYTES => 64
     )
     port map(
          Address     => pc_address_out,     -- gets Address from PC
          ReadData    => IMEMReadData        -- Output
     );

MUX5_IMEM_TO_RR2 : MUX5
     port map (
          in0       => IMEMReadData(20 downto 16), -- gets Instruction [20-16] from IMEM
          in1       => IMEMReadData(4 downto 0),   -- gets Instruction [4-0] from IMEM
          sel       => Reg2Loc,                    -- gets Reg2Loc from CPUControl
          output    => mux5_output_imem_to_rr2     -- Output
     );

CPUC_0 : CPUControl
     port map(
          Opcode   => IMEMReadData(31 downto 21),  -- gets Instruction [31-21] from IMEM
          Reg2Loc  => Reg2Loc,                     -- Outputs Reg2Loc to registers
          CBranch  => CBranch,                     -- ! Outputs to AND of ALU and CPUControl
          MemRead  => MemRead,                     -- Outputs MemRead to DMEM
          MemtoReg => MemtoReg,                    -- Outputs MemtoReg to MUX64_DMEM_OR_ALU_TO_REGS
          MemWrite => MemWrite,                    -- Outputs MemWrite to DMEM
          ALUSrc   => ALUSrc,                      -- Outputs ALUSrc to MUX64_RD2_TO_ALU
          RegWrite => RegWrite,                    -- Outputs RegWrite to registers
          UBranch  => UBranch,                     -- ! Outputs to OR of UBranch and AND from ALU/CPUControl
          ALUOp    => ALUOp                        -- Outputs ALUOp to ALUControl
     );

REGS_0 : registers
     port map(
          RR1                 => IMEMReadData(9 downto 5), -- gets Instruction [9-5] from IMEM
          RR2                 => mux5_output_imem_to_rr2,  -- gets either Instruction [20-16] or [4-0] from MUX5_IMEM_TO_RR2
          WR                  => IMEMReadData(4 downto 0), -- gets Instruction [4-0] from IMEM
          WD                  => mux64_output_to_regs,     -- gets either alu_result or DMEMReadData from MUX64_DMEM_OR_ALU_TO_REGS
          RegWrite            => RegWrite,                 -- gets RegWrite from CPUControl
          Clock               => clk,                      -- gets clk from Top (sccpu)
          RD1                 => RD1,                      -- Outputs to ALU in0
          RD2                 => RD2,                      -- Outputs to MUX64_TO_ALU in0 and DMEM
          DEBUG_TMP_REGS      => reg_debugtemp,            -- Outputs to Top via signal
          DEBUG_SAVED_REGS    => reg_debugsave             -- Outputs to Top via signal
     );

SIGN_EXTEND_0 : SignExtend
     port map(
          x => IMEMReadData(31 downto 0), -- gets Instruction [31-0]
          y => sign_extend_output         -- Outputs 64-bit sign extend result to MUX64_REGS_OR_SIGNEXTEND_TO_ALU and SHIFTLEFT2_FROM_SIGNEXTEND
     );

ALUCONTROL_0 : ALUControl
     port map(
          ALUOp     => ALUOp,                        -- gets ALUOp from CPUControl
          OpCode    => IMEMReadData(31 downto 21),   -- gets Instruction [31-21] from IMEM
          Operation => alucontrol_output             -- Outputs to ALU
     );

MUX64_REGS_OR_SIGNEXTEND_TO_ALU : MUX64
     port map(
          in0       => RD2,                  -- gets RD2 from registers
          in1       => sign_extend_output,   -- gets sign_extend_output from SignExtend
          sel       => ALUSrc,               -- gets ALUSrc from CPUControl
          output    => mux64_output_to_alu   -- Outputs either RD2 or sign_extend_output to ALU
     );

ALU_0 : ALU
     port map(
          in0       => RD1,                  -- gets RD1 from registers
          in1       => mux64_output_to_alu,  -- gets either RD2 or sign_extend_output from MUX64_TO_ALU
          operation => alucontrol_output,    -- gets alucontrol_output from ALUControl
          result    => alu_result,           -- Outputs to DMEM and MUX64_DMEM_OR_ALU_TO_REGS
          zero      => alu_zero,             -- ! Outputs to ALU_AND_CPUCONTROL
          overflow  => overflow              -- ? TBD Output
     );

DMEM_0 : DMEM
     port map(
          WriteData => RD2,          -- gets RD2 from registers
          Address   => alu_result,   -- gets alu_result from ALU
          MemRead   => MemRead,      -- gets MemRead from CPUControl
          MemWrite  => MemWrite,     -- gets MemWrite from CPUControl
          Clock     => clk,          -- gets clk from Top (sccpu)
          ReadData  => DMEMReadData, -- Outputs to MUX64_DMEM_OR_ALU_TO_REGS
          DEBUG_MEM_CONTENTS => dmem_debug -- Outputs to DEBUG
     );

MUX64_DMEM_OR_ALU_TO_REGS : MUX64
     -- Note in Figure 4.23, 1 is at the top getting DMEMReadData and 0 is bottom getting alu_result
     port map(
          in0       => alu_result,           -- gets alu_result from ALU
          in1       => DMEMReadData,         -- gets sign_extend_output from SignExtend
          sel       => MemtoReg,             -- gets MemtoReg from CPUControl
          output    => mux64_output_to_regs  -- Outputs either alu_result or DMEMReadData to WD in registers
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
          x => sign_extend_output, -- gets sign_extend_output from SignExtend
          y => shiftleft2_output   -- Outputs to ADD_PC_SHIFTLEFT2
     );
     
ADD_PC_SHIFTLEFT2 : ADD
     port map(
          in0    => pc_address_out,          -- gets pc_address_out from PC
          in1    => shiftleft2_output,       -- gets shiftleft2_output from SHIFTLEFT2_FROM_SIGNEXTEND
          output => add_output_pc_shiftleft2 -- Outputs to MUX64_RETURN_TO_PC
     );

-- ALU_AND_CPUCONTROL (CBranch)
     and_output_alu_cpucontrol <= CBranch and alu_zero;

-- AND_OR_UBranch
     or_output_and_ubranch     <= UBranch or and_output_alu_cpucontrol;

MUX64_RETURN_TO_PC : MUX64
     port map(
          in0       => add_output_pc_4,          -- gets add_output_pc_4 from ADD_PC_4
          in1       => add_output_pc_shiftleft2, -- gets add_output_pc_shiftleft2 from ADD_PC_SHIFTLEFT2
          sel       => or_output_and_ubranch,    -- gets or_output_and_ubranch as select
          output    => pc_address_in             -- Outputs to PC
     );

     -- Debug Assignments
          DEBUG_PC            <= pc_address_out;
          DEBUG_INSTRUCTION   <= IMEMReadData;
          DEBUG_TMP_REGS      <= reg_debugtemp;
          DEBUG_SAVED_REGS    <= reg_debugsave;
          DEBUG_MEM_CONTENTS  <= dmem_debug;

end structural; -- structural