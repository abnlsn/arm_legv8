
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity registers is
port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (63 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;
     RD1      : out STD_LOGIC_VECTOR (63 downto 0);
     RD2      : out STD_LOGIC_VECTOR (63 downto 0);
     --Probe ports used for testing
     -- $t0 & $t1 & t2 & t3
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     -- $s0 & $s1 & s2 & s3
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end registers;

architecture behaveioral of registers is
type reg is array(0 to 63) of STD_LOGIC_VECTOR(63 downto 0);
signal regFile:reg;

-- Handy constants to index into specific regsiters
constant XZR:integer:=31;
constant x9:integer:=9;
constant x10:integer:=10;
constant x11:integer:=11;
constant x12:integer:=12;
constant x13:integer:=13;
constant x14:integer:=14;
constant x15:integer:=15;
--constant t7:integer:=15;

constant x19:integer:=19;
constant x20:integer:=20;
constant x21:integer:=21;
constant x22:integer:=22;
constant x23:integer:=23;
constant x24:integer:=24;
constant x25:integer:=25;
constant x26:integer:=26;
constant x27:integer:=27;

begin
   --Probe the signals that we will use for testing
   DEBUG_TMP_REGS <= regFile(x9) & regFile(x10) & regFile(x11) & regFile(x12);
   DEBUG_SAVED_REGS <= regFile(x19) & regFile(x20) & regFile(x21) & regFile(x22);
   process(Clock,RR1,RR2,RegWrite,WD,WR)
   variable R1, R2, WI:integer;
   variable first:boolean:=true;
   begin
      if (first) then
         --Set values for predefnined reg values, $XZR, $to, etc
         regFile(XZR) <= (others=>'0');
         regFile(x9)  <= x"0000000000000001";
         regFile(x10) <= x"0000000000000000";
         regFile(x11) <= x"0000000000000000";
         regFile(x12) <= x"0000000000000000";

         regFile(x19) <= x"0000000000000000";
         regFile(x20) <= x"0000000000000000";
         regFile(x21) <= x"0000000000000000";
         regFile(x22) <= x"0000000000000000";
         first := false;
      end if;
      
      if Clock = '0' and Clock'event and RegWrite = '1' then
         WI := to_integer(unsigned(WR));
         if ( not(WI=XZR) ) then  --Cannot write to $XZR
            regFile(WI) <= WD;
         end if;
      end if;
      

   
   end process;

      RD1 <= regFile(to_integer(unsigned(RR1)));
      RD2 <= regFile(to_integer(unsigned(RR2)));

end behaveioral;
