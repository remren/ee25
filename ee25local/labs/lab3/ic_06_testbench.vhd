-- For ic_06, to test registers.vhd and imem_comp.vhd together.
-- 10/23/23

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ic06_testbench is
    -- empty, test bench
end entity;

architecture structural of ic06_testbench is
component IMEM is
    generic(NUM_BYTES : integer := 63);
    port(
            Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
            ReadData : out STD_LOGIC_VECTOR(31 downto 0)
    );
end component;

component registers is
    port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
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

component CPUControl is
    port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
         Reg2Loc  : out STD_LOGIC;
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

    -- Signals for IMEM
    signal Address  : std_logic_vector(63 downto 0);
    signal ReadData : std_logic_vector(31 downto 0);

    -- Signals for CPUControl
    signal Opcode   : std_logic_vector(10 downto 0);
    signal Reg2Loc  : STD_LOGIC;
    signal CBranch  : STD_LOGIC;
    signal MemRead  : STD_LOGIC;
    signal MemtoReg : STD_LOGIC;
    signal MemWrite : STD_LOGIC;
    signal ALUSrc   : STD_LOGIC;
    -- signal RegWrite : STD_LOGIC; -- Already declared for registers.
    signal UBranch  : STD_LOGIC;
    signal ALUOp    : std_logic_vector(1 downto 0);

    -- Signals for registers
    signal RR1, RR2, WR     : std_logic_vector(4 downto 0);
    signal WD, RD1, RD2     : std_logic_vector(63 downto 0);
    signal RegWrite, Clock  : std_logic;
    signal debugtemp        : std_logic_vector(64*4 - 1 downto 0);
    signal debugsave        : std_logic_vector(64*4 - 1 downto 0);

    -- Figure 4.23: IMEM -> Reg -> ALU -> DataMem
    -- Need to connect IMEM to Reg, via signals.
    -- IMEM has 1 input: Address. This is controlled in the testbench. hardcoded
    -- IMEM has 1 output: ReadData, must be linked to Reg. in some way.
    
begin

imem_uut : IMEM
generic map(
    NUM_BYTES => 63
)
port map(
    Address     => Address,
    ReadData    => ReadData
);

cpucontrol_uut : CPUControl port map(
    Opcode   => Opcode,
    Reg2Loc  => Reg2Loc,
    CBranch  => CBranch,
    MemRead  => MemRead,
    MemtoReg => MemtoReg,
    MemWrite => MemWrite,
    ALUSrc   => ALUSrc,
    RegWrite => RegWrite,
    UBranch  => UBranch,
    ALUOp    => ALUOp   
);

reg_uut : registers port map(
    RR1                 => RR1,
    RR2                 => RR2,
    WR                  => WR,
    WD                  => WD,
    RegWrite            => RegWrite,
    Clock               => Clock,
    RD1                 => RD1,
    RD2                 => RD2,
    DEBUG_TMP_REGS      => debugtemp,
    DEBUG_SAVED_REGS    => debugsave
);

test_cases : process
begin
        -- "start up" the clock
        Clock <= '0';
        wait for 1 ns;
        Clock <= '1';
        wait for 1 ns;

    
    -- Bring instruction ADD X10, X9, X11 at address 16.
    Address <= 64d"0"; -- Read at address 16 (up to 19) in IMEM for 32-bits
        wait for 50 ns;
        assert ReadData = b"10001011000010110000000100101010" report "IMEM Read Fail, ReadData=" & to_hex_string(ReadData) severity error;
                        -- |  Opcode  | X11|

    -- Select Correct Fields for an R-type instruction (ADD)
        -- I think normally this is done by CPU control...
        -- As WriteData (WD), RegWrite are unused, I will negelct them here.
    Opcode  <= ReadData(31 downto 21);
        wait for 50 ns;
        assert false report "Opcode=" & to_string(Opcode) severity note; 
        assert MemWrite = '0' report "R-type ADD, incorrect MemWrite!" severity error;
        assert RegWrite = '1' report "R-type ADD, incorrect RegWrite!" severity error;

        -- Ranges for ReadData taken from Figure 4.32 in the textbook.
    WR      <= ReadData(4 downto 0);
    RR1     <= ReadData(9 downto 5);
    RR2     <= ReadData(20 downto 16);
        wait for 50 ns;
        assert false report "WR=    X" & to_string(to_integer(unsigned(WR))) severity note;
        assert false report "RR1=   X" & to_string(to_integer(unsigned(RR1))) severity note;
        assert false report "RR2=   X" & to_string(to_integer(unsigned(RR2))) severity note;
        assert false report "----------" severity note;
        -- RD1 (X9) should be d"0" and RD2 (X11) should be d"2" based on Lab 2's register.vhd.
        assert false report "RD1=   "  & to_string(RD1) severity note;
        assert false report "RD2=   "  & to_string(RD2) severity note;

        assert false report "test done." severity note;
        wait;
end process;
end structural;