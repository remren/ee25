library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;

entity signextend_tb is
    -- empty, testbench!
end signextend_tb;

architecture structural of signextend_tb is
    component SignExtend is -- Two by one mux with 5 bit inputs/outputs
        port(
			 x : in  STD_LOGIC_VECTOR(31 downto 0);
			 y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
		);
    end component;

    -- testing signals!
    signal testx	: STD_LOGIC_VECTOR(31 downto 0);
    signal testy : STD_LOGIC_VECTOR(63 downto 0);

begin	
    se_uut : SignExtend port map(
								  x => testx,
								  y => testy
								 );
    
process begin
    -- test case #1: se_x = "FFFFFFFF", should get "FFFFFFFFFFFFFFFF"
    testx <= X"A0000000"; wait for 50 ns;
        assert (testy = x"FFFFFFFFA0000000") report "FAILED all Fs";
    -- test case #2: = '10000000', should get 00000000100000000
    testx <= X"10000000"; wait for 50 ns;
        assert testy = x"0000000010000000" report "FAILED 01";

    assert false report "test done." severity note;
    wait;

end process;
end;