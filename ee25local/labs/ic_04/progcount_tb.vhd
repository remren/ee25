library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity progcount_tb is
end progcount;

architecture structral of progcount_tb is
  component PC is -- 64-bit rising-edge triggered register with write-enable and Asynchronous reset
-- For more information on what the PC does, see page 251 in the textbook.
port(
    clk : in STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
    write_enable : in STD_LOGIC; -- Only write if ’1’
    rst : in STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
    AddressIn : in STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
    AddressOut : out STD_LOGIC_VECTOR(63 downto 0) -- Current PC address
    );
end component;

signal tst_clk : std_logic;
signal tst_rst : std_logic;
signal tst_we  : std_logic;
signal tst_ai  : std_logic_vector(63 downto 0);
signal tst_ao  : std_logic_vector(63 downto 0);

begin
uut : port map (
  tst_clk, tst_we, tst_rst, tst_ai, tst_ao
  );

test_cases : process
begin

    -- Kinda stuck, I'm having trouble testing structual components. Do I always have to change clk?
		wait; -- wait indef.
	end process;
end structural;

