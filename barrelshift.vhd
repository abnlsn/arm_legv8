library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BarrelShift is
    port (
        x : in STD_LOGIC_VECTOR(63 downto 0);
        shamt : in STD_LOGIC_VECTOR(5 downto 0);
        direction : in STD_LOGIC; -- 0 = left, 1 = right
        y : out STD_LOGIC_VECTOR(63 downto 0)
    );
end BarrelShift;

architecture Behavioral of BarrelShift is
begin

    y <= x(63 - to_integer(unsigned(shamt)) downto 0) & (to_integer(unsigned(shamt)) - 1 downto 0 => '0') when direction = '0' else
         (to_integer(unsigned(shamt)) - 1 downto 0 => '0') & x(63 downto to_integer(unsigned(shamt)));

end Behavioral;