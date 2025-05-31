library ieee;
use IEEE.std_logic_1164.all;

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
-- as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'ARM Reference Data' sheet at the
--    front of the textbook (or the Green Card pdf on Canvas).
port(
     in0       : in     STD_LOGIC_VECTOR(63 downto 0);
     in1       : in     STD_LOGIC_VECTOR(63 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(63 downto 0);
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
    );
end ALU;


architecture structural of ALU is
    component ADD is
        port(
            carry_in : in STD_LOGIC;
            in0    : in  STD_LOGIC_VECTOR(63 downto 0);
            in1    : in  STD_LOGIC_VECTOR(63 downto 0);
            output : out STD_LOGIC_VECTOR(63 downto 0);
            carry_out : out STD_LOGIC
        );
    end component;

    signal add_result : STD_LOGIC_VECTOR(63 downto 0);
    signal add_carry_out : STD_LOGIC;

    signal add_in1 : STD_LOGIC_VECTOR(63 downto 0);
    signal add_carry_in : STD_LOGIC := '0';

    signal unit_select : STD_LOGIC_VECTOR(1 downto 0);
    signal in1_negate : STD_LOGIC;

begin
    unit_select <= operation(1 downto 0);
    in1_negate <= operation(2);

    add_in1 <= not in1 when in1_negate = '1' else in1;
    add_carry_in <= in1_negate;

    ADD1 : ADD port map(
        carry_in=>in1_negate,
        in0=>in0,
        in1=>add_in1,
        output=>add_result,
        carry_out=>add_carry_out
    );

    overflow <=      '1' when unit_select = "10" and in1_negate = '0' and in0(63) = '0' and in1(63) = '0' and add_result(63) = '1' -- (+) + (+) = (-)
                else '1' when unit_select = "10" and in1_negate = '0' and in0(63) = '1' and in1(63) = '1' and add_result(63) = '0' -- (-) + (-) = (+)
                else '1' when unit_select = "10" and in1_negate = '1' and in0(63) = '0' and in1(63) = '1' and add_result(63) = '1' -- (-) - (+) = (+)
                else '1' when unit_select = "10" and in1_negate = '1' and in0(63) = '1' and in1(63) = '0' and add_result(63) = '0' -- (+) - (-) = (-)
                else '0';

    zero <= '1' when result = 64x"0000000000000000" else '0';
    
    result <= (in0 and in1) when unit_select = "00" else
              (in0 or in1) when unit_select = "01" else
              add_result when unit_select = "10" else
              in1 when unit_select = "11";
end structural;