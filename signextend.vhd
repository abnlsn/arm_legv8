library ieee;
use ieee.std_logic_1164.all;

entity SignExtend is
generic(input_width : integer := 32);
port(
     x : in  STD_LOGIC_VECTOR(input_width - 1 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
);
end SignExtend;

architecture dataflow of SignExtend is
begin
     y <= (63 downto input_width => '1') & x when x(input_width-1) = '1'
          else (63 downto input_width => '0') & x;
end dataflow;