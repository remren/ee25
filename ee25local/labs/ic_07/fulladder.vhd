library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FA is
-- adds two bits together, with a carry in and carry out
port(
    a       : in STD_LOGIC;
    b       : in STD_LOGIC;
    sum     : out STD_LOGIC;
    carry_in    : in STD_LOGIC;
    carry_out   : out STD_LOGIC
);
end FA;

architecture dataflow of FA is

    signal axorb : std_logic;

begin

    axorb       <= a xor b;
    sum         <= axorb xor carry_in;
    carry_out   <= ( axorb and carry_in ) or ( a and b );

end;