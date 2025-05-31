library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CPUControl is
-- Based on the Opcode (11 bits), CPU Control outputs select lines that are used throughout the rest 
--  of the processor architecture. In other words, given an operation (specified by an Opcode), CPU 
--  Control sets the select lines at 0 or 1 in order to appropriately control the rest of the functional 
--  units. For a visual, please refer to Figure 4.23 in the textbook. 
-- Functionality should match the truth table shown in Figure 4.22 of the textbook, inlcuding the
--    output 'X' values.
-- The truth table in Figure 4.22 only lists R-format, LDUR, STUR, and CBZ instructions. You will need
--  to implement I-format and UBranch instructions as well. To implement the unconditional branch 
--  instruction:
--    UBranch = '1'
--    MemWrite = RegWrite = '0'
--    all other outputs = 'X'	
port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
     LogicalShift : out STD_LOGIC;
     Reg2Loc  : out STD_LOGIC;
     CBranch  : out STD_LOGIC;  --conditional
     CBranchNz : out STD_LOGIC;  -- 
     MemRead  : out STD_LOGIC;
     MemtoReg : out STD_LOGIC;
     MemWrite : out STD_LOGIC;
     ALUSrc   : out STD_LOGIC;
     RegWrite : out STD_LOGIC;
     UBranch  : out STD_LOGIC; -- This is unconditional
     ALUOp    : out STD_LOGIC_VECTOR(1 downto 0);
     ImmediateControl : out STD_LOGIC_VECTOR(1 downto 0)
);
end CPUControl;

architecture Behavioral of CPUControl is
begin

     -- Instructions to implement: ADD, ADDI, B, CBZ, LDUR, STUR, SUB, SUBI

     process (Opcode) begin

          if (Opcode = 11x"0") then
               -- NOP
               LogicalShift    <= '0';
               Reg2Loc  <= '0';
               ALUSrc   <= '0';
               MemtoReg <= '0';
               RegWrite <= '0';
               MemRead  <= '0';
               MemWrite <= '0';
               UBranch  <= '0';
               ALUOp    <= "00";
               CBranch  <= '0';
               CBranchNz <= '0';
               ImmediateControl <= "00";
          elsif (Opcode = "10001011000" -- ADD
               or Opcode = "11001011000" -- SUB
               or Opcode = "10001010000" -- AND
               or Opcode = "10101010000" -- OR
          ) then
               -- R-Type
               LogicalShift    <= '0';
               Reg2Loc  <= '0';
               ALUSrc   <= '0';
               MemtoReg <= '0';
               RegWrite <= '1';
               MemRead  <= '0';
               MemWrite <= '0';
               UBranch  <= '0';
               ALUOp    <= "10";
               CBranch  <= '0';
               CBranchNz <= '0';
               ImmediateControl <= "00";
          elsif (
               Opcode = "11010011011" -- LSL
               or Opcode = "11010011010" -- LSR
          ) then
               -- Shifts Type
               LogicalShift    <= '1';
               Reg2Loc  <= '0';
               ALUSrc   <= '0';
               MemtoReg <= '0';
               RegWrite <= '1';
               MemRead  <= '0';
               MemWrite <= '0';
               UBranch  <= '0';
               ALUOp    <= "10";
               CBranch  <= '0';
               CBranchNz <= '0';
               ImmediateControl <= "00";
          elsif (Opcode(10 downto 1) = "1001000100" -- ADDI
                 or Opcode(10 downto 1) = "1101000100" -- SUBI
                 or Opcode(10 downto 1) = "1001001000" -- ANDI
                 or Opcode(10 downto 1) = "1011001000" -- ORRI
          ) then
               -- ADDI or SUBI
               LogicalShift    <= '0';
               Reg2Loc  <= '1';
               ALUSrc   <= '1';
               MemtoReg <= '0';
               RegWrite <= '1';
               MemRead  <= '0';
               MemWrite <= '0';
               UBranch  <= '0';
               ALUOp    <= "10";
               CBranch  <= '0';
               CBranchNz <= '0';
               ImmediateControl <= "01";
          elsif (Opcode(10 downto 5) = "000101") then
               -- B
               LogicalShift    <= '0';
               Reg2Loc  <= '0';
               ALUSrc   <= '0';
               MemtoReg <= '0';
               RegWrite <= '0'; -- write to PC?
               MemRead  <= '0';
               MemWrite <= '0';
               UBranch  <= '1';
               ALUOp    <= "00"; -- default ALU operation
               CBranch  <= '0';
               CBranchNz <= '0';
               ImmediateControl <= "11";
          elsif (
               Opcode(10 downto 3) = "10110100" -- CBZ
               or Opcode(10 downto 3) = "10110101" -- CBNZ
          ) then
               -- CBZ
               LogicalShift    <= '0';
               Reg2Loc  <= '1';
               ALUSrc   <= '0';
               MemtoReg <= '0';
               RegWrite <= '0';
               MemRead  <= '0';
               MemWrite <= '0';
               UBranch  <= '0';
               ALUOp    <= "01";
               CBranch  <= '1';
               CBranchNz <= Opcode(3);
               ImmediateControl <= "10";
          elsif (Opcode = "11111000000") then
               -- STUR
               LogicalShift    <= '0';
               Reg2Loc  <= '1';
               ALUSrc   <= '1';
               MemtoReg <= '0';
               RegWrite <= '0';
               MemRead  <= '0';
               MemWrite <= '1';
               UBranch  <= '0';
               ALUOp    <= "00";
               CBranch  <= '0';
               CBranchNz <= '0';
               ImmediateControl <= "00";
          elsif (Opcode = "11111000010") then
               -- LDUR
               LogicalShift    <= '0';
               Reg2Loc  <= '1';
               ALUSrc   <= '1';
               MemtoReg <= '1';
               RegWrite <= '1';
               MemRead  <= '1';
               MemWrite <= '0';
               UBranch  <= '0';
               ALUOp    <= "00";
               CBranch  <= '0';
               CBranchNz <= '0';
               ImmediateControl <= "00";
          else
               -- default
               LogicalShift    <= '0';
               Reg2Loc <= 'U';
               CBranch <= 'U';
               CBranchNz <= 'U';
               MemRead <= 'U';
               MemtoReg <= 'U';
               MemWrite <= 'U';
               ALUSrc <= 'U';
               RegWrite <= 'U';
               UBranch <= 'U';
               ALUOp <= "UU";
               ImmediateControl <= "UU";
          end if;
          
     end process;


end Behavioral;


-- SUBI :  11 0100 0100
-- ADDI :  10 0100 0100
-- ADD  : 100 0101 1000
-- SUB  : 110 0101 1000
-- B    :        000101
-- CBZ  :     1011 0100
-- STUR : 101 1110 0000
-- LDUR : 101 1110 0010