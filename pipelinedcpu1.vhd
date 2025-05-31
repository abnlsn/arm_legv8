library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PipelinedCPU1 is
port(
clk :in std_logic;
rst :in std_logic;
--Probe ports used for testing
-- Forwarding control signals
DEBUG_FORWARDA : out std_logic_vector(1 downto 0); -- (new)
DEBUG_FORWARDB : out std_logic_vector(1 downto 0); -- (new)
--The current address (AddressOut from the PC)
DEBUG_PC : out std_logic_vector(63 downto 0);
--Value of PC.write_enable
DEBUG_PC_WRITE_ENABLE : out STD_LOGIC; -- (new)
--The current instruction (Instruction output of IMEM)
DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
--DEBUG ports from other components
DEBUG_TMP_REGS : out std_logic_vector(64*4-1 downto 0);
DEBUG_SAVED_REGS : out std_logic_vector(64*4-1 downto 0);
DEBUG_MEM_CONTENTS : out std_logic_vector(64*4-1 downto 0)
);
end PipelinedCPU1;

architecture structural of PipelinedCPU1 is

    -- Component declarations
    component PC is
         port(
              clk          : in  STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
              write_enable : in  STD_LOGIC; -- Only write if '1'
              rst          : in  STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
              AddressIn    : in  STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
              AddressOut   : out STD_LOGIC_VECTOR(63 downto 0) -- Current PC address
         );
    end component;
    
    
    component ALU is
    port(
         in0       : in     STD_LOGIC_VECTOR(63 downto 0);
         in1       : in     STD_LOGIC_VECTOR(63 downto 0);
         operation : in     STD_LOGIC_VECTOR(3 downto 0);
         result    : buffer STD_LOGIC_VECTOR(63 downto 0);
         zero      : buffer STD_LOGIC;
         overflow  : buffer STD_LOGIC
    );
    end component;

    component ADD is
    port(
         carry_in : in STD_LOGIC;
         in0    : in  STD_LOGIC_VECTOR(63 downto 0);
         in1    : in  STD_LOGIC_VECTOR(63 downto 0);
         output : out STD_LOGIC_VECTOR(63 downto 0);
         carry_out : out STD_LOGIC
    );
    end component;

    component registers is
    port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
         RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
         WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
         WD       : in  STD_LOGIC_VECTOR (63 downto 0);
         RegWrite : in  STD_LOGIC;
         Clock    : in  STD_LOGIC;
         RD1      : out STD_LOGIC_VECTOR (63 downto 0);
         RD2      : out STD_LOGIC_VECTOR (63 downto 0);
         DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
         DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
    );   
    end component;

    component CPUControl is
    port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
         LogicalShift    : out STD_LOGIC;
         Reg2Loc  : out STD_LOGIC;
         CBranch  : out STD_LOGIC;  --conditional
         CBranchNz : out STD_LOGIC;
         MemRead  : out STD_LOGIC;
         MemtoReg : out STD_LOGIC;
         MemWrite : out STD_LOGIC;
         ALUSrc   : out STD_LOGIC;
         RegWrite : out STD_LOGIC;
         UBranch  : out STD_LOGIC; -- This is unconditional
         ALUOp    : out STD_LOGIC_VECTOR(1 downto 0);
         ImmediateControl : out STD_LOGIC_VECTOR(1 downto 0)
    );
    end component;

    component IMEM is
    port(
         Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
         ReadData : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component ALUControl is
    port(
         ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
         Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
         Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
    end component;

    component ImmediateExtend is
    port(
         x : in  STD_LOGIC_VECTOR(31 downto 0);
         immediate_control : in STD_LOGIC_VECTOR(1 downto 0);
         y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
    );
    end component;

    component DMEM is
    port(
         WriteData          : in  STD_LOGIC_VECTOR(63 downto 0); -- Input data
         Address            : in  STD_LOGIC_VECTOR(63 downto 0); -- Read/Write address
         MemRead            : in  STD_LOGIC; -- Indicates a read operation
         MemWrite           : in  STD_LOGIC; -- Indicates a write operation
         Clock              : in  STD_LOGIC; -- Writes are triggered by a rising edge
         ReadData           : out STD_LOGIC_VECTOR(63 downto 0); -- Output data
         -- Four 64-bit words: DMEM(0) & DMEM(4) & DMEM(8) & DMEM(12)
         DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
    );
    end component;

    component ShiftLeft2 is
    port(
         x : in  STD_LOGIC_VECTOR(63 downto 0);
         y : out STD_LOGIC_VECTOR(63 downto 0)
    );
    end component;

    component BarrelShift is
    port (
         x : in STD_LOGIC_VECTOR(63 downto 0);
         shamt : in STD_LOGIC_VECTOR(5 downto 0);
         direction : in STD_LOGIC; -- 0 = left, 1 = right
         y : out STD_LOGIC_VECTOR(63 downto 0)
    );
    end component;

     component HazardDetection is
          port (
               ID_EX_MemRead : in std_logic;
               ID_EX_WBReg : in std_logic_vector (4 downto 0);
               ID_reg1 : in std_logic_vector (4 downto 0);
               ID_reg2 : in std_logic_vector (4 downto 0);

               write_pc : out std_logic;
               write_if_id : out std_logic;
               flush_id_ex : out std_logic
          );
     end component;

     component ForwardingControl is
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
      end component;

    --- PIPELINE REGISTERS ---
    constant cpucontrol_reg_size : integer := 14;

    signal IF_ID_pc : STD_LOGIC_VECTOR(63 downto 0);
    signal IF_ID_instruction : STD_LOGIC_VECTOR(31 downto 0);

    signal ID_EX_pc : STD_LOGIC_VECTOR(63 downto 0);
    signal ID_EX_rd1 : STD_LOGIC_VECTOR(63 downto 0);
    signal ID_EX_rd2 : STD_LOGIC_VECTOR(63 downto 0);
    signal ID_EX_signextend : STD_LOGIC_VECTOR(63 downto 0);
    signal ID_EX_cpucontrol : STD_LOGIC_VECTOR(cpucontrol_reg_size - 1 downto 0);
    signal ID_EX_instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal ID_EX_rr1 : STD_LOGIC_VECTOR(4 downto 0);
    signal ID_EX_rr2 : STD_LOGIC_VECTOR(4 downto 0);
    signal ID_pcwrite : STD_LOGIC;
    signal ID_write_if_id : STD_LOGIC;
    signal ID_flush_id_ex : STD_LOGIC;

    signal EX_MEM_cpucontrol : STD_LOGIC_VECTOR(cpucontrol_reg_size - 1 downto 0);
    signal EX_MEM_alu_result : STD_LOGIC_VECTOR(63 downto 0);
    signal EX_MEM_alu_zero : STD_LOGIC;
    signal EX_MEM_rd2 : STD_LOGIC_VECTOR(63 downto 0);
    signal EX_MEM_pc : STD_LOGIC_VECTOR(63 downto 0);
    signal EX_MEM_branch_add_out : STD_LOGIC_VECTOR(63 downto 0);
    signal EX_MEM_instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal EX_alu_forward_a : STD_LOGIC_VECTOR(1 downto 0);
    signal EX_alu_forward_b : STD_LOGIC_VECTOR(1 downto 0);
    signal EX_alu_in0 : STD_LOGIC_VECTOR(63 downto 0);
    signal EX_alu_in1_forwarded : STD_LOGIC_VECTOR(63 downto 0);


    signal MEM_pcsrc : std_logic;
    signal MEM_WB_dmem_readdata : STD_LOGIC_VECTOR(63 downto 0);
    signal MEM_WB_alu_result : STD_LOGIC_VECTOR(63 downto 0);
    signal MEM_WB_cpucontrol : STD_LOGIC_VECTOR(cpucontrol_reg_size - 1 downto 0);
    signal MEM_WB_instruction : STD_LOGIC_VECTOR(31 downto 0);

    -- SIGNALS ---------------
    signal IF_pc_addressin : STD_LOGIC_VECTOR(63 downto 0);

    signal imem_address : STD_LOGIC_VECTOR(63 downto 0);
    signal imem_data    : STD_LOGIC_VECTOR(31 downto 0);

    signal cpucontrol_reg : STD_LOGIC_VECTOR(cpucontrol_reg_size - 1 downto 0);
    constant REG2LOC_INDEX : integer := 0;
    constant CBRANCH_INDEX : integer := 1;
    constant CBRANCHNZ_INDEX : integer := 2;
    constant MEMREAD_INDEX : integer := 3;
    constant MEMTOREG_INDEX : integer := 4;
    constant MEMWRITE_INDEX : integer := 5;
    constant ALUSRC_INDEX : integer := 6;
    constant REGWRITE_INDEX : integer := 7;
    constant UBRANCH_INDEX : integer := 8;
    subtype ALUOP_INDEX is natural range 10 downto 9;
    subtype IMMEDIATECONTROL_INDEX is natural range 12 downto 11;
    constant LOGICALSHIFT_INDEX : integer := 13;

    signal registers_rr2 : STD_LOGIC_VECTOR(4 downto 0);
    signal registers_rd1 : STD_LOGIC_VECTOR(63 downto 0);
    signal registers_rd2 : STD_LOGIC_VECTOR(63 downto 0);
    signal registers_regwrite : STD_LOGIC;
    signal WB_writedata : STD_LOGIC_VECTOR(63 downto 0);

    signal EX_barrelshift_result : STD_LOGIC_VECTOR(63 downto 0);
    signal cpucontrol_shift : STD_LOGIC;

    signal EX_alu_in1 : STD_LOGIC_VECTOR(63 downto 0);
    signal EX_alu_zero : STD_LOGIC;
    signal EX_alu_operation : STD_LOGIC_VECTOR(3 downto 0);
    signal alucontrol_op : STD_LOGIC_VECTOR(1 downto 0);
    signal EX_alu_result : STD_LOGIC_VECTOR(63 downto 0);
    signal alu_zero : STD_LOGIC;

    signal signextend_out : STD_LOGIC_VECTOR(63 downto 0);

    signal MEM_dmem_readdata : STD_LOGIC_VECTOR(63 downto 0);

    signal pc_add_out : STD_LOGIC_VECTOR(63 downto 0);

    signal EX_shiftleft2_out : STD_LOGIC_VECTOR(63 downto 0);
    signal EX_branch_add_out : STD_LOGIC_VECTOR(63 downto 0);

    signal math_result : STD_LOGIC_VECTOR(63 downto 0);

begin

    -- COMPONENT INSTANTIATIONS ---


    -- PIPELINE -------------------
    ---- INSTRUCTION FETCH --------
    DEBUG_PC <= imem_address;
    DEBUG_INSTRUCTION <= imem_data;

    IF_imem: IMEM port map(Address=>imem_address, ReadData=>imem_data);
    IF_pc: PC port map(clk=>clk,
         write_enable=>ID_pcwrite,
         rst=>rst,
         AddressIn=>IF_pc_addressin,
         AddressOut=>imem_address
    );
    IF_pc_add: ADD port map(
         carry_in=>'0',
         in0=>imem_address,
         in1=>64x"4",
         output=>pc_add_out
    );

    IF_pc_addressin <= pc_add_out when MEM_pcsrc = '0'
         else EX_MEM_branch_add_out;

    process(clk, rst) begin
         if rst = '1' then
              IF_ID_pc <= (others=>'0');
              IF_ID_instruction <= (others=>'0');
         elsif rising_edge(clk) and ID_write_if_id = '1' then
              --- UPDATE IF/ID REGISTER ---
              IF_ID_pc <= imem_address;
              IF_ID_instruction <= imem_data;
         end if;
    end process;

    ---- INSTRUCTION DECODE -------
    ID_cpucontrol: CPUControl port map(
         Opcode=>IF_ID_instruction(31 downto 21),
         Reg2Loc=>cpucontrol_reg(REG2LOC_INDEX),
         CBranch=>cpucontrol_reg(CBRANCH_INDEX),
         CBranchNz=>cpucontrol_reg(CBRANCHNZ_INDEX),
         MemRead=>cpucontrol_reg(MEMREAD_INDEX),
         MemtoReg=>cpucontrol_reg(MEMTOREG_INDEX),
         MemWrite=>cpucontrol_reg(MEMWRITE_INDEX),
         ALUSrc=>cpucontrol_reg(ALUSRC_INDEX),
         RegWrite=>cpucontrol_reg(REGWRITE_INDEX),
         UBranch=>cpucontrol_reg(UBRANCH_INDEX),
         ALUOp=>cpucontrol_reg(ALUOP_INDEX),
         ImmediateControl=>cpucontrol_reg(IMMEDIATECONTROL_INDEX),
         LogicalShift=>cpucontrol_reg(LOGICALSHIFT_INDEX)
    );

    registers_rr2 <= IF_ID_instruction(4 downto 0) when cpucontrol_reg(REG2LOC_INDEX) = '1'
                     else IF_ID_instruction(20 downto 16);

    ID_registers: registers port map(
         RR1=>IF_ID_instruction(9 downto 5),
         RR2=>registers_rr2,
         WR=>MEM_WB_instruction(4 downto 0),
         WD=>WB_writedata,
         RegWrite=>MEM_WB_cpucontrol(REGWRITE_INDEX),
         Clock=>clk,
         RD1=>registers_rd1,
         RD2=>registers_rd2,
         DEBUG_TMP_REGS=>DEBUG_TMP_REGS,
         DEBUG_SAVED_REGS=>DEBUG_SAVED_REGS
    );

    ID_signextend: ImmediateExtend port map(
         x=>IF_ID_instruction,
         immediate_control=>cpucontrol_reg(IMMEDIATECONTROL_INDEX),
         y=>signextend_out
    );

    ID_hazard_detection : HazardDetection port map(
          ID_EX_MemRead => ID_EX_cpucontrol(MEMREAD_INDEX),
          ID_EX_WBReg => ID_EX_instruction(4 downto 0),
          ID_reg1 => IF_ID_instruction(9 downto 5),
          ID_reg2 => registers_rr2,
          write_pc => ID_pcwrite,
          write_if_id => ID_write_if_id,
          flush_id_ex => ID_flush_id_ex
    );
    
    process(clk, rst) begin
           if rst = '1' then
                 ID_EX_instruction <= (others=>'0');
                 ID_EX_pc <= (others=>'0');
                 ID_EX_rd1 <= (others=>'0');
                 ID_EX_rd2 <= (others=>'0');
                 ID_EX_rr1 <= (others=>'0');
                 ID_EX_rr2 <= (others=>'0');
                 ID_EX_signextend <= (others=>'0');
                 ID_EX_cpucontrol <= (others=>'0');
         elsif rising_edge(clk) then
              --- UPDATE IF/ID REGISTER ---
              if ID_flush_id_ex = '0' then
                    ID_EX_instruction <= IF_ID_instruction;
                    ID_EX_pc <= IF_ID_pc;
                    ID_EX_rd1 <= registers_rd1;
                    ID_EX_rd2 <= registers_rd2;
                    ID_EX_rr1 <= IF_ID_instruction(9 downto 5);
                    ID_EX_rr2 <= registers_rr2;
                    ID_EX_signextend <= signextend_out;
                    ID_EX_cpucontrol <= cpucontrol_reg;
               else
                    ID_EX_instruction <= (others => '0');
                    ID_EX_pc <= (others => '0');
                    ID_EX_rd1 <= (others => '0');
                    ID_EX_rd2 <= (others => '0');
                    ID_EX_signextend <= (others => '0');
                    ID_EX_cpucontrol <= (others => '0');
               end if;

         end if;
    end process;

    ---- EXECUTE ------------------


    EX_alu_in0 <= ID_EX_rd1 when EX_alu_forward_a = "00"
               else EX_MEM_alu_result when EX_alu_forward_a = "01"
               else WB_writedata;


    EX_alu_in1_forwarded <= EX_MEM_rd2 when EX_alu_forward_b = "00"
                  else EX_MEM_alu_result when EX_alu_forward_b = "01"
                  else WB_writedata;
    
    EX_alu_in1 <= ID_EX_signextend when ID_EX_cpucontrol(ALUSRC_INDEX) = '1'
               else EX_alu_in1_forwarded;

    EX_alucontrol : ALUControl port map(
         ALUOp=>ID_EX_cpucontrol(ALUOP_INDEX),
         Opcode=>ID_EX_instruction(31 downto 21),
         Operation=>EX_alu_operation
    );

    EX_alu: ALU port map(
         in0=>EX_alu_in0,
         in1=>EX_alu_in1,
         operation=>EX_alu_operation,
         result=>EX_alu_result,
         zero=>EX_alu_zero
    );

    EX_shiftleft2: ShiftLeft2 port map(
         x=>ID_EX_signextend,
         y=>EX_shiftleft2_out
    );

    EX_branchadd: ADD port map(
         carry_in=>'0',
         in0=>ID_EX_pc,
         in1=>EX_shiftleft2_out,
         output=>EX_branch_add_out
    );

    EX_barrelshift: BarrelShift port map(
         x=>ID_EX_rd1,
         shamt=>ID_EX_instruction(15 downto 10),
         direction=>not ID_EX_instruction(21),
         y=>EX_barrelshift_result
    );

    EX_forwarding: ForwardingControl port map(
          ID_EX_rn => ID_EX_instruction(9 downto 5),
          ID_EX_rm => ID_EX_rr2,
          EX_MEM_regwrite => EX_MEM_cpucontrol(REGWRITE_INDEX),
          EX_MEM_rd => EX_MEM_instruction(4 downto 0),
          MEM_WB_regwrite => MEM_WB_cpucontrol(REGWRITE_INDEX),
          MEM_WB_rd => MEM_WB_instruction(4 downto 0),
          forward_a => EX_alu_forward_a,
          forward_b => EX_alu_forward_b
    );

    DEBUG_FORWARDA <= EX_alu_forward_a;
    DEBUG_FORWARDB <= EX_alu_forward_b;

    process(clk, rst) begin
         if rst = '1' then
              EX_MEM_cpucontrol <= (others => '0');
              EX_MEM_alu_result <= (others => '0');
              EX_MEM_alu_zero <= '0';
              EX_MEM_rd2 <= (others => '0');
              EX_MEM_pc <= (others => '0');
              EX_MEM_branch_add_out <= (others => '0');
              EX_MEM_instruction <= (others => '0');

         elsif rising_edge(clk) then
              --- UPDATE IF/ID REGISTER ---
              EX_MEM_cpucontrol <= ID_EX_cpucontrol;
              EX_MEM_alu_result <= EX_alu_result when ID_EX_cpucontrol(LOGICALSHIFT_INDEX) = '0'
                                  else EX_barrelshift_result;
              EX_MEM_alu_zero <= EX_alu_zero;
              EX_MEM_rd2 <= EX_alu_in1_forwarded;
              EX_MEM_pc <= ID_EX_pc;
              EX_MEM_branch_add_out <= EX_branch_add_out;
              EX_MEM_instruction <= ID_EX_instruction;

         end if;
    end process;

    ---- MEMORY -------------------
    MEM_pcsrc <= '1' when (EX_MEM_alu_zero and EX_MEM_cpucontrol(CBRANCH_INDEX))
                   or (not EX_MEM_alu_zero and EX_MEM_cpucontrol(CBRANCHNZ_INDEX))
                   or (EX_MEM_cpucontrol(UBRANCH_INDEX))
                   else '0';

    MEM_dmem: DMEM port map(
         WriteData=>EX_MEM_rd2,
         Address=>EX_MEM_alu_result,
         MemRead=>EX_MEM_cpucontrol(MEMREAD_INDEX),
         MemWrite=>EX_MEM_cpucontrol(MEMWRITE_INDEX),
         Clock=>clk,
         ReadData=>MEM_dmem_readdata,
         DEBUG_MEM_CONTENTS=>DEBUG_MEM_CONTENTS
    );


    process(clk, rst) begin
         if rst = '1' then
              MEM_WB_dmem_readdata <= (others => '0');
              MEM_WB_alu_result <= (others => '0');
              MEM_WB_cpucontrol <= (others => '0');
              MEM_WB_instruction <= (others => '0');
         elsif rising_edge(clk) then
              MEM_WB_dmem_readdata <= MEM_dmem_readdata;
              MEM_WB_alu_result <= EX_MEM_alu_result;
              MEM_WB_cpucontrol <= EX_MEM_cpucontrol;
              MEM_WB_instruction <= EX_MEM_instruction;
         end if;
    end process;

    ---- WRITE BACK ---------------
    WB_writedata <= MEM_WB_dmem_readdata when MEM_WB_cpucontrol(MEMTOREG_INDEX) = '1'
                   else MEM_WB_alu_result;

end structural;