library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity test_tb is
end test_tb;

architecture sim of test_tb is
component tregisters is
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

    signal RR1, RR2, WR: STD_LOGIC_VECTOR(4 downto 0);
    signal WD: STD_LOGIC_VECTOR(63 downto 0);
    signal RegWrite, Clock: STD_LOGIC;
    signal RD1, RD2: STD_LOGIC_VECTOR(63 downto 0);
    
    begin
        UUT : tregisters
            port map (
                RR1 => RR1,
                RR2 => RR2,
                WR => WR,
                WD => WD,
                RegWrite => RegWrite,
                Clock => Clock,
                RD1 => RD1,
                RD2 => RD2
            );

        -- Process for clock generation
        process
        begin
            Clock <= '0';
            wait for 5 ns;
            Clock <= '1';
            wait for 5 ns;
        end process;

        -- Test process
        process
        begin
            -- Wait for initialization
            wait for 10 ns;

            -- Read from registers (location 10 & 11)
            RR1 <= "01010"; -- Reg(10)
            RR2 <= "01011"; -- Reg(11)
            RegWrite <= '0';
            wait for 10 ns;
            assert RD1 = X"000000000000001" report "Reading RD1 failed " & to_string(RD1);
            assert RD2 = X"0000000000000002" report "Reading RD2 failed " & to_string(RD2);

            -- Write to registers (location 10)
            WR <= "01010"; -- Reg(10)
            WD <= X"ABCDEF0123456789";
            RegWrite <= '1';
            wait for 10 ns;

            -- Read from registers Reg(10) again
            RR1 <= "01010"; -- Reg(10)
            RegWrite <= '0';
            wait for 10 ns;
            assert RD1 = X"ABCDEF0123456789" report "Writing RD1 failed " & to_string(RD1);

            -- End simulation
            assert false report "Test Done." severity note;
            wait;
        end process;
end sim;
