library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpucontrol_testbench is
-- Empty for Testbench
end cpucontrol_testbench;

architecture structural of cpucontrol_testbench is
component CPUControl is
    port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
        Reg2Loc   : out STD_LOGIC;
        CBranch  : out STD_LOGIC;  --conditional
        MemRead  : out STD_LOGIC;
        MemtoReg : out STD_LOGIC;
        MemWrite : out STD_LOGIC;
        ALUSrc   : out STD_LOGIC;
        RegWrite : out STD_LOGIC;
        UBranch  : out STD_LOGIC; -- This is unconditional
        ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
    );
end component;

    signal opcodetb :   STD_LOGIC_VECTOR(10 downto 0);
    signal r2ltb    :   STD_LOGIC;
    signal cbtb     :   STD_LOGIC;  --conditional
    signal mrtb     :   STD_LOGIC;
    signal mtrtb    :   STD_LOGIC;
    signal mwtb     :   STD_LOGIC;
    signal alustb   :   STD_LOGIC;
    signal rwtb     :   STD_LOGIC;
    signal ubtb     :   STD_LOGIC; -- This is unconditional
    signal aluoptb  :   STD_LOGIC_VECTOR(1 downto 0);

begin
    CPUControl_uut : CPUControl
        port map (opcodetb,
                  r2ltb,
                  cbtb,
                  mrtb,
                  mtrtb,
                  mwtb,
                  alustb,
                  rwtb,
                  ubtb,
                  aluoptb);

test_cases : process
begin
    -- NOTE: Not making any assertions as all control signals are shown via waveform.
        
    -- R-type Instruction Test: ADD
    opcodetb <= b"10001011000";
        wait for 50 ns;

    -- I-type Instruction Test: ADDI
    opcodetb <= b"1001000100" & '0';  -- opcodetb(0) is filled as a 0
        wait for 50 ns;

    -- R-type Instruction Test: LDUR
    opcodetb <= b"11111000010";
        wait for 50 ns;

    -- R-type Instruction Test: STUR
    opcodetb <= b"11111000000";
        wait for 50 ns;

    -- CB-type Instruction Test: CBZ
    opcodetb <= b"10110100" & b"000"; -- opcodetb(2 downto 0) is filled with 0s
        wait for 50 ns;

    -- B-type Instruction Test: B (uncond. branch)
    opcodetb <= b"000101" & b"00000"; -- opcodetb(4 downto 0) is filled with 0s
        wait for 50 ns;

        assert false report "test done." severity note;
            wait;
end process;

end structural;