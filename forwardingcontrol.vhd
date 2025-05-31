library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ForwardingControl is
    port (
        ID_EX_rn : in std_logic_vector(4 downto 0);
        ID_EX_rm : in std_logic_vector(4 downto 0);

        EX_MEM_regwrite : in std_logic;
        EX_MEM_rd : in std_logic_vector(4 downto 0);

        MEM_WB_regwrite : in std_logic;
        MEM_WB_rd : in std_logic_vector(4 downto 0);

        forward_a : out std_logic_vector(1 downto 0);
        forward_b : out std_logic_vector(1 downto 0)
    );
end ForwardingControl;

architecture dataflow of ForwardingControl is

begin
    process (all) begin
        
        if (EX_MEM_rd = ID_EX_rn and EX_MEM_regwrite = '1' and EX_MEM_rd /= "11111") then
            forward_a <= "01";
        elsif (MEM_WB_rd = ID_EX_rn and MEM_WB_regwrite = '1' and MEM_WB_rd /= "11111") then
            forward_a <= "10";
        else
            forward_a <= "00";
        end if;

        if (EX_MEM_rd = ID_EX_rm and EX_MEM_regwrite = '1' and EX_MEM_rd /= "11111") then
            forward_b <= "01";
        elsif (MEM_WB_rd = ID_EX_rm and MEM_WB_regwrite = '1' and MEM_WB_rd /= "11111") then
            forward_b <= "10";
        else
            forward_b <= "00";
        end if;

    end process;
end dataflow;