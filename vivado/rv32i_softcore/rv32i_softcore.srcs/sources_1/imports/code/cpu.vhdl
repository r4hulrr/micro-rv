library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        i_clk, i_reset: in std_logic;
        leds          : out std_logic_vector(3 downto 0)
    );
end entity;

architecture cpu_arch of cpu is

    -- === Component Declarations ===

    component pc is
        port(
            i_clk, i_reset  : in std_logic;
            i_addr          : in std_logic_vector(7 downto 0);
            o_addr          : out std_logic_vector(7 downto 0)
        );
    end component;

    component rom is
        port(
            i_clk, i_reset  : in std_logic;
            i_addr          : in std_logic_vector(7 downto 0);
            o_ins           : out std_logic_vector(31 downto 0)
        );
    end component;

    component imm_gen is
        port(
            i_ins: in std_logic_vector(31 downto 0);
            o_imm: out std_logic_vector(31 downto 0)
        );
    end component;

    component mux_3to1_32b is
        port(
            mux_select : in std_logic_vector(1 downto 0);
            data_a     : in std_logic_vector(31 downto 0);
            data_b     : in std_logic_vector(31 downto 0);
            data_c     : in std_logic_vector(31 downto 0);
            data_y     : out std_logic_vector(31 downto 0)
        );
    end component;

    component mux_2to1_32b is
        port(
            mux_select : in std_logic;
            data_a     : in std_logic_vector(31 downto 0);
            data_b     : in std_logic_vector(31 downto 0);
            data_y     : out std_logic_vector(31 downto 0)
        );
    end component;

    component ctrl_unit is
        port(
            i_ins       : in std_logic_vector(31 downto 0);
            o_alu_op    : out std_logic_vector(3 downto 0);
            o_rf_wr_en  : out std_logic;
            o_ram_wr_en : out std_logic;
            o_op_bs     : out std_logic;
            o_op_bl     : out std_logic;
            o_mux_alu_b : out std_logic;
            o_mux_alu_a : out std_logic_vector(1 downto 0);
            o_bs_en     : out std_logic;
            o_bl_en     : out std_logic;
            o_br_en     : out std_logic;
            o_mux_wb    : out std_logic_vector(1 downto 0)
        );
    end component;

    component reg_file is
        port(
            i_clk       : in std_logic;
            i_reset     : in std_logic;
            i_wr_en     : in std_logic;
            i_rd_sel1   : in std_logic_vector(4 downto 0);
            i_rd_sel2   : in std_logic_vector(4 downto 0);
            i_wr_sel    : in std_logic_vector(4 downto 0);
            i_wr_data   : in std_logic_vector(31 downto 0);
            o_rd1       : out std_logic_vector(31 downto 0);
            o_rd2       : out std_logic_vector(31 downto 0)
        );
    end component;

    component alu is
        port(
            i_alu_op    : in std_logic_vector(3 downto 0);
            i_a         : in std_logic_vector(31 downto 0);
            i_b         : in std_logic_vector(31 downto 0);
            o_d         : out std_logic_vector(31 downto 0)
        );
    end component;

    component branch_logic is
        port(
            i_branch_en : in std_logic;
            i_rs1       : in std_logic_vector(31 downto 0);
            i_rs2       : in std_logic_vector(31 downto 0);
            i_op        : in std_logic_vector(6 downto 0);
            i_f3        : in std_logic_vector(2 downto 0);
            i_imm       : in std_logic_vector(31 downto 0);
            i_pc        : in std_logic_vector(7 downto 0);
            o_pc        : out std_logic_vector(7 downto 0)
        );
    end component;

    component ram is
        port(
            i_clk   : in std_logic;
            i_reset : in std_logic;
            i_wr_en : in std_logic;
            i_addr  : in std_logic_vector(9 downto 0);
            i_data  : in std_logic_vector(31 downto 0);
            o_data  : out std_logic_vector(31 downto 0)
        );
    end component;

    component byte_extract is
        port(
            i_be_en : in std_logic;
            i_data  : in std_logic_vector(31 downto 0);
            i_f3    : in std_logic_vector(2 downto 0);
            o_data  : out std_logic_vector(31 downto 0)
        );
    end component;

    -- === Signal Declarations ===

    signal sig_cur_pc       : std_logic_vector(7 downto 0);
    signal sig_next_pc      : std_logic_vector(7 downto 0);
    signal sig_ins          : std_logic_vector(31 downto 0);
    signal sig_imm          : std_logic_vector(31 downto 0);
    signal sig_alu_op       : std_logic_vector(3 downto 0);
    signal sig_rf_wr_en     : std_logic;
    signal sig_ram_wr_en    : std_logic;
    signal sig_op_bs        : std_logic;
    signal sig_op_bl        : std_logic;
    signal sig_mux_alu_b    : std_logic;
    signal sig_mux_alu_a    : std_logic_vector(1 downto 0);
    signal sig_bs_en        : std_logic;
    signal sig_bl_en        : std_logic;
    signal sig_br_en        : std_logic;
    signal sig_mux_wb       : std_logic_vector(1 downto 0);
    signal sig_rs1          : std_logic_vector(31 downto 0);
    signal sig_rs2          : std_logic_vector(31 downto 0);
    signal sig_alu_a        : std_logic_vector(31 downto 0);
    signal sig_alu_b        : std_logic_vector(31 downto 0);
    signal sig_alu_output   : std_logic_vector(31 downto 0);
    signal sig_ram_wr_data  : std_logic_vector(31 downto 0);
    signal sig_ram_rd_data  : std_logic_vector(31 downto 0);
    signal sig_bl_data      : std_logic_vector(31 downto 0);
    signal sig_wb_data      : std_logic_vector(31 downto 0);
    signal sig_ram_addr_10b : std_logic_vector(9 downto 0);
    signal sig_pc_ext       : std_logic_vector(31 downto 0);
    signal sig_pc_plus_4    : std_logic_vector(31 downto 0);

begin

    leds <= sig_wb_data(3 downto 0); -- added so design isnt optimized away

    -- === Computed Signals ===

    sig_pc_ext       <= std_logic_vector(resize(unsigned(sig_cur_pc), 32));
    sig_pc_plus_4    <= std_logic_vector(resize(unsigned(sig_cur_pc) + 4, 32));
    sig_ram_addr_10b <= std_logic_vector(resize(unsigned(sig_alu_output), 10));

    -- === Instantiations ===

    pc_inst: pc
    port map(
        i_clk   => i_clk,
        i_reset => i_reset,
        i_addr  => sig_next_pc,
        o_addr  => sig_cur_pc
    );

    rom_inst: rom
    port map(
        i_clk   => i_clk,
        i_reset => i_reset,
        i_addr  => sig_cur_pc,
        o_ins   => sig_ins
    );

    imm_gen_inst: imm_gen
    port map(
        i_ins => sig_ins,
        o_imm => sig_imm
    );

    ctrl_unit_inst: ctrl_unit
    port map(
        i_ins       => sig_ins,
        o_alu_op    => sig_alu_op,
        o_rf_wr_en  => sig_rf_wr_en,
        o_ram_wr_en => sig_ram_wr_en,
        o_op_bs     => sig_op_bs,
        o_op_bl     => sig_op_bl,
        o_mux_alu_a => sig_mux_alu_a,
        o_mux_alu_b => sig_mux_alu_b,
        o_bs_en     => sig_bs_en,
        o_bl_en     => sig_bl_en,
        o_br_en     => sig_br_en,
        o_mux_wb    => sig_mux_wb
    );

    reg_file_inst: reg_file
    port map(
        i_clk       => i_clk,
        i_reset     => i_reset,
        i_wr_en     => sig_rf_wr_en,
        i_rd_sel1   => sig_ins(19 downto 15),
        i_rd_sel2   => sig_ins(24 downto 20),
        i_wr_sel    => sig_ins(11 downto 7),
        i_wr_data   => sig_wb_data,
        o_rd1       => sig_rs1,
        o_rd2       => sig_rs2
    );

    mux_alu_a_inst: mux_3to1_32b
    port map(
        mux_select => sig_mux_alu_a,
        data_a     => sig_rs1,
        data_b     => sig_pc_ext,
        data_c     => (others => '0'),
        data_y     => sig_alu_a
    );

    mux_alu_b_inst: mux_2to1_32b
    port map(
        mux_select => sig_mux_alu_b,
        data_a     => sig_rs2,
        data_b     => sig_imm,
        data_y     => sig_alu_b
    );

    alu_inst: alu
    port map(
        i_alu_op => sig_alu_op,
        i_a      => sig_alu_a,
        i_b      => sig_alu_b,
        o_d      => sig_alu_output
    );

    branch_logic_inst: branch_logic
    port map(
        i_branch_en => sig_br_en,
        i_rs1       => sig_rs1,
        i_rs2       => sig_rs2,
        i_op        => sig_ins(6 downto 0),
        i_f3        => sig_ins(14 downto 12),
        i_imm       => sig_imm,
        i_pc        => sig_cur_pc,
        o_pc        => sig_next_pc
    );

    byte_extract_store_inst: byte_extract
    port map(
        i_be_en => sig_bs_en,
        i_data  => sig_rs2,
        i_f3    => sig_ins(14 downto 12),
        o_data  => sig_ram_wr_data
    );

    ram_inst: ram
    port map(
        i_clk   => i_clk,
        i_reset => i_reset,
        i_wr_en => sig_ram_wr_en,
        i_addr  => sig_ram_addr_10b,
        i_data  => sig_ram_wr_data,
        o_data  => sig_ram_rd_data
    );

    byte_extract_load_inst: byte_extract
    port map(
        i_be_en => sig_bl_en,
        i_data  => sig_ram_rd_data,
        i_f3    => sig_ins(14 downto 12),
        o_data  => sig_bl_data
    );

    mux_wb_inst: mux_3to1_32b
    port map(
        mux_select => sig_mux_wb,
        data_a     => sig_bl_data,
        data_b     => sig_alu_output,
        data_c     => sig_pc_plus_4,
        data_y     => sig_wb_data
    );

end architecture;
