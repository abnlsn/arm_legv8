library ieee;
use ieee.std_logic_1164.all;

entity ImmediateExtend is
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     immediate_control : in STD_LOGIC_VECTOR(1 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
);
end ImmediateExtend;

architecture structural of ImmediateExtend is
    component SignExtend is
    generic(input_width : integer := 32);
    port(
         x : in  STD_LOGIC_VECTOR(input_width - 1 downto 0);
         y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
    );
    end component;

    signal signex9_out : STD_LOGIC_VECTOR(63 downto 0);
    signal signex12_out : STD_LOGIC_VECTOR(63 downto 0);
    signal signex19_out : STD_LOGIC_VECTOR(63 downto 0);
    signal signex26_out : STD_LOGIC_VECTOR(63 downto 0);

begin
    -- 9 bits for LDUR/STUR
    signex9: SignExtend generic map(input_width=>9) port map(
        x=>x(20 downto 12),
        y=>signex9_out
   );
   -- 12 bits for I-Type
   signex12: SignExtend generic map(input_width=>12) port map(
        x=>x(21 downto 10),
        y=>signex12_out
   );
   -- 19 bits for CBranch
   signex19: SignExtend generic map(input_width=>19) port map(
        x=>x(23 downto 5),
        y=>signex19_out
   );
   -- 26 bits for Ubranch
   signex26: SignExtend generic map(input_width=>26) port map(
        x=>x(25 downto 0),
        y=>signex26_out
   );
   ---

   y <= signex9_out when (immediate_control = "00") else
        signex12_out when (immediate_control = "01") else
        signex19_out when (immediate_control = "10") else
        signex26_out;

end structural;