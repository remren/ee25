library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeadder is
port(
    in0    : in  STD_LOGIC_VECTOR(63 downto 0);
    in1    : in  STD_LOGIC_VECTOR(63 downto 0);
    output : out STD_LOGIC_VECTOR(63 downto 0);
    cout   : out STD_LOGIC;
    clk    : in  STD_LOGIC
);
end pipeadder;

architecture structural of pipeadder is
    component ADD32 is
        port(
            in0    : in  STD_LOGIC_VECTOR(31 downto 0);
            in1    : in  STD_LOGIC_VECTOR(31 downto 0);
            output : out STD_LOGIC_VECTOR(31 downto 0);
            cout   : out STD_LOGIC;
            clk    : in  STD_LOGIC;
            rst    : in  STD_LOGIC
        );
    end component;

    signal in0_lowerhalf : std_logic_vector(31 downto 0) := (others => '0');
    signal in0_upperhalf : std_logic_vector(31 downto 0) := (others => '0');
    signal in1_lowerhalf : std_logic_vector(31 downto 0) := (others => '0');
    signal in1_upperhalf : std_logic_vector(31 downto 0) := (others => '0');

    signal sum_lower : std_logic_vector(31 downto 0) := (others => '0');
    signal sum_upper : std_logic_vector(31 downto 0) := (others => '0');

    signal carry_lower : std_logic_vector(31 downto 0) := (others => '0');

    signal carry_sum : std_logic_vector(31 downto 0) := (others => '0');

    signal sum_register : std_logic_vector(63 downto 0) := (others => '0');
    

    signal cout_lower : std_logic := '0';
    signal cout_upper : std_logic := '0';
    signal rst_lower  : std_logic := '0';
    signal rst_upper  : std_logic := '0';

begin
    lower_adder : ADD32
        port map(
            in0  => in0_lowerhalf,
            in1  => in1_lowerhalf,
            output => sum_lower,
            cout => cout_lower,
            clk  => clk,
            rst  => rst_lower
        );

    carry_adder : ADD32
        port map(
            in0  => carry_lower,
            in1  => sum_upper,
            output => carry_sum,
            cout => cout_upper,
            clk => clk,
            rst => '0'
        );

    upper_adder : ADD32
        port map(
            in0  => in0_lowerhalf,
            in1  => in1_lowerhalf,
            output => sum_upper,
            cout => cout_upper,
            clk  => clk,
            rst  => rst_upper
        );

    process (clk, in0, in1) begin
        if rising_edge(clk) then
            rst_lower <= '0';
            rst_upper <= '1';
            in0_lowerhalf <= in0(31 downto 0);
            in1_lowerhalf <= in1(31 downto 0);
            sum_register <= (63 downto 32 => '0') & sum_lower;
        end if;

        if falling_edge(clk) then
            rst_lower <= '1';
            rst_upper <= '0';
            in0_upperhalf <= in0(63 downto 32);
            in1_upperhalf <= in1(63 downto 32);
            carry_lower <= (31 downto 1 => '0') & cout_lower;
            sum_register <= carry_sum & sum_register(31 downto 0);
            output <= sum_register;
        end if;

    end process;

end structural;