library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity pc_testbench is
    -- empty. tb.
end pc_testbench;

architecture structural of pc_testbench is
component PC is
    port(
     clk          : in  STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
     write_enable : in  STD_LOGIC; -- Only write if '1'
     rst          : in  STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
     AddressIn    : in  STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
     AddressOut   : out STD_LOGIC_VECTOR(63 downto 0) -- Current PC address
);
end component;

    signal clk, write_enable, rst : std_logic;
    signal AddressIn, AddressOut  : std_logic_vector(63 downto 0);

begin

    pc_uut : PC port map( clk, write_enable, rst, AddressIn, AddressOut );

test_cases : process
begin
        -- "start up" the clock
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
        clk <= '0';
        wait for 1 ns;
        
        assert false report "AddressOut=" & to_string(AddressOut) severity note;
    write_enable <= '1';
        wait for 1 ns;

    AddressIn <= 64d"0";
    write_enable <= '0';
        wait for 1 ns;
        
    rst <= '1';
        wait for 1 ns;
    clk <= '1';
        wait for 1 ns;
        assert false report "AddressOut=" & to_string(AddressOut) severity note;

        assert false report "test done." severity note;
        wait;
end process;
end structural;