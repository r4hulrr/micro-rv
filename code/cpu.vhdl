library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        i_clk, i_reset: in std_logic          -- clock and reset input
    );
end entity;

architecture cpu_arch of cpu is
    -- program counter
   component pc is
        port(
            i_clk, i_reset  : in std_logic;        
            i_addr          : in std_logic_vector(7 downto 0); 
            o_addr          : out std_logic_vector(7 downto 0)
        );
    end component;
    -- ROM
    component rom is
        port(
            i_clk, i_reset	: in std_logic;							-- clock
            i_addr			: in std_logic_vector(7 downto 0);		-- address of rom to read from
            o_ins			: out std_logic_vector(31 downto 0)	
        );
    end component;
    -- IMM GEN
    component imm_gen is
        port(
            i_ins: in std_logic_vector(31 downto 0);
            o_imm: out std_logic_vector(31 downto 0)
        );
    end component;
    -- 32 bit 3 to 1 mux
    component mux_3to1_32b is
        port(
            mux_select : in std_logic_vector(1 downto 0);
            data_a     : in std_logic_vector(31 downto 0);
            data_b     : in std_logic_vector(31 downto 0);
            data_c     : in std_logic_vector(31 downto 0);
            data_y     : out std_logic_vector(31 downto 0)
        );
    end component;
    -- 32 bit 2 to 1 mux
    component mux_2to1_32b is
        port(
            mux_select : in std_logic_vector(1 downto 0);
            data_a     : in std_logic_vector(31 downto 0);
            data_b     : in std_logic_vector(31 downto 0);
            data_y     : out std_logic_vector(31 downto 0)
        );
    end component;
    -- Control Unit
    component ctrl_unit is
        port(
            i_ins       : in std_logic_vector(31 downto 0);
            o_alu_op    : out std_logic_vector(3 downto 0);
            o_rf_wr_en  : out std_logic;
            o_ram_wr_en : out std_logic;
            o_op_bs     : out std_logic;
            o_op_bl     : out std_logic;
            o_mux_alu_b : out std_logic;                -- mux that controls input into alu a 
            o_mux_alu_a : out std_logic(1 downto 0);    -- mux that controls input into alu b
            o_bs_en     : out std_logic;
            o_bl_en     : out std_logic;
            o_br_en     : out std_logic;
            o_mux_wb    : out std_logic_vector(1 downto 0)
        );
    end component;
    -- Register File
    component reg_file is
        port(
            i_clk		: in std_logic;							-- clk
            i_reset		: in std_logic;							-- reset
            i_wr_en		: in std_logic;							-- write enable
            i_rd_sel1	: in std_logic_vector (4 downto 0);		-- to choose which of the 32 registers to read/write to 
            i_rd_sel2	: in std_logic_vector (4 downto 0);
            i_wr_sel	: in std_logic_vector (4 downto 0);
            i_wr_data	: in std_logic_vector (31 downto 0);	-- data in from memory if writing to register
            o_rd1		: out std_logic_vector (31 downto 0);	-- data out from selected registers
            o_rd2		: out std_logic_vector (31 downto 0)
        );
    end component;
    -- ALU
    component alu is 
        port(
            i_alu_op	: in std_logic_vector(3 downto 0);		-- ALU op code from control logic
            i_a			: in std_logic_vector(31 downto 0);		-- Operands
            i_b			: in std_logic_vector(31 downto 0);
            o_d 		: out std_logic_vector(31 downto 0)	
        );
    end component;
    -- Branch Logic
    component branch_logic is
        port(
            i_branch_en : std_logic;
            i_rs1       : std_logic_vector(31 downto 0);
            i_rs2       : std_logic_vector(31 downto 0);
            i_op        : std_logic_vector(6 downto 0);
            i_f3        : std_logic_vector(2 downto 0);
            i_imm       : std_logic_vector(31 downto 0);
            i_pc        : std_logic_vector(7 downto 0);
            o_pc      : std_logic_vector(31 downto 0)
        );
    end component;
    -- RAM
    component ram is
        port(
            i_clk	: in std_logic;				-- clk, reset and write enable
            i_reset	: in std_logic;
            i_wr_en	: in std_logic;
            i_addr	: in std_logic_vector(9 downto 0);		-- address in ram to read/write
            i_data	: in std_logic_vector(31 downto 0);	-- data to write to register
            o_data	: out std_logic_vector(31 downto 0)	-- data read from register
        );
    end component;
    -- Byte extractor
    component byte_extract is
        port(
            i_be_en     : in std_logic;                              -- Byte enable
            i_data      : in std_logic_vector(31 downto 0);          -- Data from rs2 (store) or memory (load)
            i_f3        : in std_logic_vector(2 downto 0);           -- funct3
            o_data      : out std_logic_vector(31 downto 0)
        );
    end component;
    -- signals
    -- PC
    signal sig_cur_pc   : std_logic_vector(7 downto 0);
    signal sig_next_pc  : std_logic_vector(7 downto 0);
    -- ROM
    signal sig_ins      : std_logic_vector(31 downto 0);
    -- Imm gen
    signal sig_imm      : std_logic_vector(31 downto 0);
    -- Control Unit
    signal sig_alu_op       : std_logic_vector(3 downto 0);
    signal sig_rf_wr_en     : std_logic;
    signal sig_ram_wr_en    : std_logic;
    signal sig_op_bs        : std_logic;
    signal sig_op_bl        : std_logic;
    signal sig_mux_alu_b    : std_logic;                -- mux that controls input into alu a 
    signal sig_mux_alu_a    : std_logic(1 downto 0);    -- mux that controls input into alu b
    signal sig_bs_en        : std_logic;
    signal sig_bl_en        : std_logic;
    signal sig_br_en        : std_logic;
    signal sig_mux_wb       : std_logic_vector(1 downto 0);
    -- Reg File
    signal sig_rs1          : std_logic_vector(31 downto 0);
    signal sig_rs2          : std_logic_vector(31 downto 0);
    -- ALU
    signal sig_alu_a        : std_logic_vector(31 downto 0);
    signal sig_alu_b        : std_logic_vector(31 downto 0);
    signal sig_alu_output   : std_logic_vector(31 downto 0);
    -- RAM
    signal sig_ram_wr_data  : std_logic_vector(31 downto 0);
    signal sig_ram_rd_data  : std_logic_vector(31 downto 0);
    signal sig_ram_addr     : std_logic_vector(31 downto 0);
begin
    -- program counter
    pc: pc 
    port map(
        i_clk   => i_clk;
        i_reset => i_reset;
        i_addr  => sig_next_pc;
        o_addr  => sig_cur_pc
    );
    -- rom
    rom: rom
    port map(
        i_clk   => i_clk;
        i_reset => i_reset;
        i_addr  => sig_cur_pc;
        o_ins   => sig_ins
    );
    -- imm gen
    imm_gen: imm_gen
    port map(
        i_ins   => sig_ins;
        o_imm   => sig_imm
    );
    -- ctrl unit
    ctrl_unit: ctrl_unit
    port map(
        i_ins       => sig_ins;
        o_alu_op    => sig_alu_op;
        o_rf_wr_en  => sig_rf_wr_en;
        o_ram_wr_en => sig_ram_wr_en;
        o_op_bs     => sig_op_bs;
        o_op_bl     => sig_op_bl;
        o_mux_alu_a => sig_mux_alu_a;       -- mux that controls input into alu a 
        o_mux_alu_b => sig_mux_alu_b;       -- mux that controls input into alu b
        o_bs_en     => sig_bs_en;
        o_bl_en     => sig_bl_en;
        o_br_en     => sig_br_en;
        o_mux_wb    => sig_mux_wb
    );
    -- reg file
    reg_file: reg_file
    port map(
        i_clk		=> i_clk;
		i_reset		=> i_reset;
		i_wr_en		=> sig_rf_wr_en;
		i_rd_sel1	=> sig_ins(19 downto 15);
		i_rd_sel2	=> sig_ins(24 downto 20);
		i_wr_sel	=> sig_ins(11 downto 8);
		i_wr_data	=> sig_wr_data;
		o_rd1		=> sig_rs1;
		o_rd2		=> sig_rs2
    );
    -- mux for alu a
    mux_alu_a: mux_3to1_32b
    port map(
        mux_select => sig_mux_alu_a;
        data_a     => sig_rs1;
        data_b     => std_logic_vector(resize(unsigned(sig_cur_pc), 32));
        data_c     => x"00000000";
        data_y     => sig_alu_a
    );
    -- mux for alu b
    mux_alu_b: mux_2to1_32b
    port map(
        mux_select => sig_mux_alu_b;
        data_a     => sig_rs2;
        data_b     => sig_imm;
        data_y     => sig_alu_b
    );
    -- alu
    alu: alu
    port map(
        i_alu_op   => sig_alu_op;
		i_a		   => sig_alu_a;
		i_b		   => sig_alu_b;
		o_d 	   => sig_alu_output	
    );
    -- branch logic
    branch_logic: branch_logic
    port map(
        i_branch_en     => sig_br_en;
        i_rs1           => sig_rs1;
        i_rs2           => sig_rs2;
        i_op            => sig_ins(6 downto 0);
        i_f3            => sig_ins(14 downto 12);
        i_imm           => sig_imm;
        i_pc            => sig_cur_pc;
        o_pc            => sig_next_pc
    );
    -- byte extractor (store)
    byte_extract_store: byte_extract
    port map(
        i_be_en     => sig_bs_en;
        i_data      => sig_rs2;  
        i_f3        => sig_ins(14 downto 12);
        o_data      => sig_ram_wr_data
    );
    -- ram
    ram: ram
    port map(
        i_clk	    => i_clk;
		i_reset	    => i_reset;
		i_wr_en	    => sig_ram_wr_en;
		i_addr	    => std_logic_vector(resize(unsigned(sig_alu_output, 10))
		i_data	    => sig_ram_wr_data;
		o_data	    => sig_ram_rd_data
    );
end cpu_arch;