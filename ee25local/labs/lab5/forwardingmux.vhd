library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forwardingmux is -- Three by one mux with 64 bit inputs/outputs
port(
    in00    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 00
    in10    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 10
    in01    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 01
    sel     : in STD_LOGIC_VECTOR(1 downto 0); -- selects in00 or in10 or in01
    -- Select should never be "11". This should throw an error. TODO!
    output : out STD_LOGIC_VECTOR(63 downto 0)
);
end forwardingmux;

architecture dataflow of forwardingmux is
begin

    output <= in00 when sel = "00" else
              in01 when sel = "01" else
              in10 when sel = "10";

end dataflow;