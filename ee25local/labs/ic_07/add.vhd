library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- help me https://www.edaplayground.com/x/389T

entity ADD32 is
-- Adds two signed 64-bit inputs
-- output = in1 + in2
port(
     in0    : in  STD_LOGIC_VECTOR(31 downto 0);
     in1    : in  STD_LOGIC_VECTOR(31 downto 0);
     output : out STD_LOGIC_VECTOR(31 downto 0);
     cout   : out STD_LOGIC;
     clk    : in  STD_LOGIC;
     rst    : in  STD_LOGIC
);
end ADD32;

architecture structural of ADD32 is
     component FA is
          port(
            a       : in STD_LOGIC;
            b       : in STD_LOGIC;
            sum     : out STD_LOGIC;
            carry_in    : in STD_LOGIC;
            carry_out   : out STD_LOGIC
        );
     end component;

     signal carry : std_logic_vector (31 downto 0) := (others => '0');

begin
	GEN_FA : for n in 0 to 30 generate
          one_bit : FA
               port map(
                         a => in0(n),
                         b => in1(n),
                         sum => output(n),
                         carry_in => carry(n),
                         carry_out => carry(n + 1)
                         -- holy crap this is smart, shoutouts to Owen
                         );
     end generate GEN_FA;
          last_bit : FA
               port map(
                         a => in0(31),
                         b => in1(31),
                         sum => output(31),
                         carry_in => carry(31),
                         carry_out => cout
                         );
                         -- added this part to circumvent out of index error

     output <= 32d"0" when rst = '1';
     cout   <= '0' when rst = '1';
     
end structural;