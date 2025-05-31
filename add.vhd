library ieee;
use ieee.std_logic_1164.all;

entity ADD is
-- Adds two signed 64-bit inputs
-- output = in1 + in2
-- carry_in : 1 bit carry_in
-- carry_out : 1 bit carry_out
-- Hint: there are multiple ways to do this
--       -- cascade smaller adders to make the 64-bit adder (make a heirarchy)
--       -- use a Python script (or Excel) to automate filling in the signals
--       -- try a Gen loop (you will have to look this up)
port(
     carry_in : in STD_LOGIC;
     in0    : in  STD_LOGIC_VECTOR(63 downto 0);
     in1    : in  STD_LOGIC_VECTOR(63 downto 0);
     output : out STD_LOGIC_VECTOR(63 downto 0);
     carry_out : out STD_LOGIC
);
end ADD;

architecture structural of ADD is
     component FullAdder is
          port(
                carry_in : in STD_LOGIC;
                in0    : in  STD_LOGIC;
                in1    : in  STD_LOGIC;
                output : out STD_LOGIC;
                carry_out : out STD_LOGIC
          );
     end component;

     signal carry : STD_LOGIC_VECTOR(63 downto 0);
begin

     carry_out <= carry(63);

     add0  : FullAdder port map(carry_in=>carry_in,  in0=>in0(0),  in1=>in1(0),  output=>output(0),  carry_out=>carry(0));
     add1  : FullAdder port map(carry_in=>carry(0),  in0=>in0(1),  in1=>in1(1),  output=>output(1),  carry_out=>carry(1));
     add2  : FullAdder port map(carry_in=>carry(1),  in0=>in0(2),  in1=>in1(2),  output=>output(2),  carry_out=>carry(2));
     add3  : FullAdder port map(carry_in=>carry(2),  in0=>in0(3),  in1=>in1(3),  output=>output(3),  carry_out=>carry(3));
     add4  : FullAdder port map(carry_in=>carry(3),  in0=>in0(4),  in1=>in1(4),  output=>output(4),  carry_out=>carry(4));
     add5  : FullAdder port map(carry_in=>carry(4),  in0=>in0(5),  in1=>in1(5),  output=>output(5),  carry_out=>carry(5));
     add6  : FullAdder port map(carry_in=>carry(5),  in0=>in0(6),  in1=>in1(6),  output=>output(6),  carry_out=>carry(6));
     add7  : FullAdder port map(carry_in=>carry(6),  in0=>in0(7),  in1=>in1(7),  output=>output(7),  carry_out=>carry(7));
     add8  : FullAdder port map(carry_in=>carry(7),  in0=>in0(8),  in1=>in1(8),  output=>output(8),  carry_out=>carry(8));
     add9  : FullAdder port map(carry_in=>carry(8),  in0=>in0(9),  in1=>in1(9),  output=>output(9),  carry_out=>carry(9));
     add10 : FullAdder port map(carry_in=>carry(9), in0=>in0(10), in1=>in1(10), output=>output(10), carry_out=>carry(10));
     add11 : FullAdder port map(carry_in=>carry(10), in0=>in0(11), in1=>in1(11), output=>output(11), carry_out=>carry(11));
     add12 : FullAdder port map(carry_in=>carry(11), in0=>in0(12), in1=>in1(12), output=>output(12), carry_out=>carry(12));
     add13 : FullAdder port map(carry_in=>carry(12), in0=>in0(13), in1=>in1(13), output=>output(13), carry_out=>carry(13));
     add14 : FullAdder port map(carry_in=>carry(13), in0=>in0(14), in1=>in1(14), output=>output(14), carry_out=>carry(14));
     add15 : FullAdder port map(carry_in=>carry(14), in0=>in0(15), in1=>in1(15), output=>output(15), carry_out=>carry(15));
     add16 : FullAdder port map(carry_in=>carry(15), in0=>in0(16), in1=>in1(16), output=>output(16), carry_out=>carry(16));
     add17 : FullAdder port map(carry_in=>carry(16), in0=>in0(17), in1=>in1(17), output=>output(17), carry_out=>carry(17));
     add18 : FullAdder port map(carry_in=>carry(17), in0=>in0(18), in1=>in1(18), output=>output(18), carry_out=>carry(18));
     add19 : FullAdder port map(carry_in=>carry(18), in0=>in0(19), in1=>in1(19), output=>output(19), carry_out=>carry(19));
     add20 : FullAdder port map(carry_in=>carry(19), in0=>in0(20), in1=>in1(20), output=>output(20), carry_out=>carry(20));
     add21 : FullAdder port map(carry_in=>carry(20), in0=>in0(21), in1=>in1(21), output=>output(21), carry_out=>carry(21));
     add22 : FullAdder port map(carry_in=>carry(21), in0=>in0(22), in1=>in1(22), output=>output(22), carry_out=>carry(22));
     add23 : FullAdder port map(carry_in=>carry(22), in0=>in0(23), in1=>in1(23), output=>output(23), carry_out=>carry(23));
     add24 : FullAdder port map(carry_in=>carry(23), in0=>in0(24), in1=>in1(24), output=>output(24), carry_out=>carry(24));
     add25 : FullAdder port map(carry_in=>carry(24), in0=>in0(25), in1=>in1(25), output=>output(25), carry_out=>carry(25));
     add26 : FullAdder port map(carry_in=>carry(25), in0=>in0(26), in1=>in1(26), output=>output(26), carry_out=>carry(26));
     add27 : FullAdder port map(carry_in=>carry(26), in0=>in0(27), in1=>in1(27), output=>output(27), carry_out=>carry(27));
     add28 : FullAdder port map(carry_in=>carry(27), in0=>in0(28), in1=>in1(28), output=>output(28), carry_out=>carry(28));
     add29 : FullAdder port map(carry_in=>carry(28), in0=>in0(29), in1=>in1(29), output=>output(29), carry_out=>carry(29));
     add30 : FullAdder port map(carry_in=>carry(29), in0=>in0(30), in1=>in1(30), output=>output(30), carry_out=>carry(30));
     add31 : FullAdder port map(carry_in=>carry(30), in0=>in0(31), in1=>in1(31), output=>output(31), carry_out=>carry(31));
     add32 : FullAdder port map(carry_in=>carry(31), in0=>in0(32), in1=>in1(32), output=>output(32), carry_out=>carry(32));
     add33 : FullAdder port map(carry_in=>carry(32), in0=>in0(33), in1=>in1(33), output=>output(33), carry_out=>carry(33));
     add34 : FullAdder port map(carry_in=>carry(33), in0=>in0(34), in1=>in1(34), output=>output(34), carry_out=>carry(34));
     add35 : FullAdder port map(carry_in=>carry(34), in0=>in0(35), in1=>in1(35), output=>output(35), carry_out=>carry(35));
     add36 : FullAdder port map(carry_in=>carry(35), in0=>in0(36), in1=>in1(36), output=>output(36), carry_out=>carry(36));
     add37 : FullAdder port map(carry_in=>carry(36), in0=>in0(37), in1=>in1(37), output=>output(37), carry_out=>carry(37));
     add38 : FullAdder port map(carry_in=>carry(37), in0=>in0(38), in1=>in1(38), output=>output(38), carry_out=>carry(38));
     add39 : FullAdder port map(carry_in=>carry(38), in0=>in0(39), in1=>in1(39), output=>output(39), carry_out=>carry(39));
     add40 : FullAdder port map(carry_in=>carry(39), in0=>in0(40), in1=>in1(40), output=>output(40), carry_out=>carry(40));
     add41 : FullAdder port map(carry_in=>carry(40), in0=>in0(41), in1=>in1(41), output=>output(41), carry_out=>carry(41));
     add42 : FullAdder port map(carry_in=>carry(41), in0=>in0(42), in1=>in1(42), output=>output(42), carry_out=>carry(42));
     add43 : FullAdder port map(carry_in=>carry(42), in0=>in0(43), in1=>in1(43), output=>output(43), carry_out=>carry(43));
     add44 : FullAdder port map(carry_in=>carry(43), in0=>in0(44), in1=>in1(44), output=>output(44), carry_out=>carry(44));
     add45 : FullAdder port map(carry_in=>carry(44), in0=>in0(45), in1=>in1(45), output=>output(45), carry_out=>carry(45));
     add46 : FullAdder port map(carry_in=>carry(45), in0=>in0(46), in1=>in1(46), output=>output(46), carry_out=>carry(46));
     add47 : FullAdder port map(carry_in=>carry(46), in0=>in0(47), in1=>in1(47), output=>output(47), carry_out=>carry(47));
     add48 : FullAdder port map(carry_in=>carry(47), in0=>in0(48), in1=>in1(48), output=>output(48), carry_out=>carry(48));
     add49 : FullAdder port map(carry_in=>carry(48), in0=>in0(49), in1=>in1(49), output=>output(49), carry_out=>carry(49));
     add50 : FullAdder port map(carry_in=>carry(49), in0=>in0(50), in1=>in1(50), output=>output(50), carry_out=>carry(50));
     add51 : FullAdder port map(carry_in=>carry(50), in0=>in0(51), in1=>in1(51), output=>output(51), carry_out=>carry(51));
     add52 : FullAdder port map(carry_in=>carry(51), in0=>in0(52), in1=>in1(52), output=>output(52), carry_out=>carry(52));
     add53 : FullAdder port map(carry_in=>carry(52), in0=>in0(53), in1=>in1(53), output=>output(53), carry_out=>carry(53));
     add54 : FullAdder port map(carry_in=>carry(53), in0=>in0(54), in1=>in1(54), output=>output(54), carry_out=>carry(54));
     add55 : FullAdder port map(carry_in=>carry(54), in0=>in0(55), in1=>in1(55), output=>output(55), carry_out=>carry(55));
     add56 : FullAdder port map(carry_in=>carry(55), in0=>in0(56), in1=>in1(56), output=>output(56), carry_out=>carry(56));
     add57 : FullAdder port map(carry_in=>carry(56), in0=>in0(57), in1=>in1(57), output=>output(57), carry_out=>carry(57));
     add58 : FullAdder port map(carry_in=>carry(57), in0=>in0(58), in1=>in1(58), output=>output(58), carry_out=>carry(58));
     add59 : FullAdder port map(carry_in=>carry(58), in0=>in0(59), in1=>in1(59), output=>output(59), carry_out=>carry(59));
     add60 : FullAdder port map(carry_in=>carry(59), in0=>in0(60), in1=>in1(60), output=>output(60), carry_out=>carry(60));
     add61 : FullAdder port map(carry_in=>carry(60), in0=>in0(61), in1=>in1(61), output=>output(61), carry_out=>carry(61));
     add62 : FullAdder port map(carry_in=>carry(61), in0=>in0(62), in1=>in1(62), output=>output(62), carry_out=>carry(62));
     add63 : FullAdder port map(carry_in=>carry(62), in0=>in0(63), in1=>in1(63), output=>output(63), carry_out=>carry(63));

end structural;
