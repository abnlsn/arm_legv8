library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity PipeCPU_testbench is
end PipeCPU_testbench;

-- when your testbench is complete you should report error with severity failure.
-- this will end the simulation. Do not add stop times to the Makefile

architecture tb of PipeCPU_testbench is
    component PipelinedCPU1 is
        port(
             clk : in STD_LOGIC;
             rst : in STD_LOGIC;
             --Probe ports used for testing
             --The current address (AddressOut from the PC)
             DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
             --The current instruction (Instruction output of IMEM)
             DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
             --DEBUG ports from other components
             DEBUG_TMP_REGS     : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
             DEBUG_SAVED_REGS   : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
             DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
        );
    end component;

    signal clk : STD_LOGIC := '1';
    signal rst : STD_LOGIC := '0';
    signal DEBUG_PC : STD_LOGIC_VECTOR(63 downto 0);
    signal DEBUG_INSTRUCTION : STD_LOGIC_VECTOR(31 downto 0);
    signal DEBUG_TMP_REGS : STD_LOGIC_VECTOR(64*4 - 1 downto 0);
    signal DEBUG_SAVED_REGS : STD_LOGIC_VECTOR(64*4 - 1 downto 0);
    signal DEBUG_MEM_CONTENTS : STD_LOGIC_VECTOR(64*4 - 1 downto 0);

    signal finished : boolean := false;

begin

    uut : PipelinedCPU1 port map(
        clk => clk,
        rst => rst,
        DEBUG_PC => DEBUG_PC,
        DEBUG_INSTRUCTION => DEBUG_INSTRUCTION,
        DEBUG_TMP_REGS => DEBUG_TMP_REGS,
        DEBUG_SAVED_REGS => DEBUG_SAVED_REGS,
        DEBUG_MEM_CONTENTS => DEBUG_MEM_CONTENTS
    );

    clk <= not clk after 5 ns when not finished else '0';

    process begin
        rst <= '1';
        wait for 2 ns;
        rst <= '0';
        wait for 3 ns;

        wait for 45 ns;
        wait for 100 ns;

        report "Testbench done" severity failure;
        finished <= true;
        wait;
    end process;
end tb;