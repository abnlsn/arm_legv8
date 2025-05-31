library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HazardDetection is
    port (
        ID_EX_MemRead : in std_logic;
        ID_EX_WBReg : in std_logic_vector (4 downto 0);
        ID_reg1 : in std_logic_vector (4 downto 0);
        ID_reg2 : in std_logic_vector (4 downto 0);

        write_pc : out std_logic;
        write_if_id : out std_logic;
        flush_id_ex : out std_logic
    );
end HazardDetection;

architecture behavioral of HazardDetection is

begin

    -- Logic: if ID/EX has a MemRead
    -- If the WB register is the same as one of the inputs to the ALU
    -- then we need to stall the pipeline

    process (all) begin
        -- TODO: add regwrite check??
        if ID_EX_MemRead = '1' and (ID_EX_WBReg = ID_reg1 or ID_EX_WBReg = ID_reg2) then
            write_pc <= '0';
            write_if_id <= '0';
            flush_id_ex <= '1';
        else
            write_pc <= '1';
            write_if_id <= '1';
            flush_id_ex <= '0';
        end if;

    end process;
    

end behavioral;