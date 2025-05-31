library ieee;
use ieee.std_logic_1164.all;

entity FullAdder is
    port(
         carry_in : in STD_LOGIC;
         in0    : in  STD_LOGIC;
         in1    : in  STD_LOGIC;
         output : out STD_LOGIC;
         carry_out : out STD_LOGIC
    );
    end FullAdder;
    
architecture dataflow of FullAdder is
begin
        output <= (in0 xor in1) xor carry_in;
        carry_out <= (in0 and in1) or (in0 and carry_in) or (in1 and carry_in);
end dataflow;