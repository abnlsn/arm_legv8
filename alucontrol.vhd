library ieee;
use ieee.std_logic_1164.all;

entity ALUControl is
-- Functionality should match truth table shown in Figure 4.12 in the textbook. Avoid Figure 4.13 as it may 
--  cause confusion.
-- Check table on page2 of ISA.pdf on canvas. Pay attention to opcode of operations and type of operations. 
-- If an operation doesn't use ALU, you don't need to check for its case in the ALU control implemenetation.	
-- To ensure proper functionality, you must implement the "don't-care" values in the funct field,
--  for example when ALUOp = '00", Operation must be "0010" regardless of what Funct is.
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ALUControl;

architecture behavioral of ALUControl is
begin
    process(ALUOp, Opcode)
    begin
        case ALUOp is
            when "00" =>
                Operation <= "0010"; -- ADD
            when "01" =>
                Operation <= "0111"; -- Pass input B
            when "10" =>
                if Opcode = "10001011000" then
                    Operation <= "0010"; -- ADD
                elsif Opcode(10 downto 1) = "1001000100" then
                    Operation <= "0010"; -- ADDI
                elsif Opcode = "11001011000" then
                    Operation <= "0110"; -- SUB
                elsif Opcode(10 downto 1) = "1101000100" then
                    Operation <= "0110"; -- SUBI
                elsif Opcode = "10001010000" then
                    Operation <= "0000"; -- AND
                elsif Opcode(10 downto 1) = "1001001000" then
                    Operation <= "0000"; -- ANDI
                elsif Opcode = "10101010000" then
                    Operation <= "0001"; -- ORR
                elsif Opcode(10 downto 1) = "1011001000" then
                    Operation <= "0001"; -- ORRI
                else
                    Operation <= "UUUU";
                end if;
            when others =>
                Operation <= "XXXX"; -- Default case
            end case;


    end process;
end behavioral;