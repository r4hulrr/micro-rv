library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        clk, reset: in std_logic          -- clock and reset input
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
    -- Control Unit
    component ctrl_unit is
        port(
            i_ins       : in std_logic_vector(31 downto 0);
            o_alu_op    : out std_logic_vector(3 downto 0);
            o_rf_wr_en  : out std_logic;
            o_ram_wr_en : out std_logic;
            o_op_bs     : out std_logic;
            o_op_bl     : out std_logic;
            o_mux_alu_a : out std_logic;                -- mux that controls input into alu a 
            o_mux_alu_b : out std_logic(1 downto 0);    -- mux that controls input into alu b
            o_bs_en     : out std_logic;
            o_bl_en     : out std_logic;
            o_br_en     : out std_logic;
            o_mux_wb    : out std_logic_vector(1 downto 0)
        );
    end component;
    -- Register File
    component register_file is
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
begin
    -- instantiate the program counter
    pc: entity work.pc(pc_arch)
        port map(
            clk=>clk,
            reset=>reset,
            pc_op=>pc_op,
            addr_in=>pc_addr_in,
            addr=>pc_addr
        );

    -- instantiate the rom
    rom: entity work.rom(rom_arch)
        port map(
            clk=>clk,
            addr=>rom_addr_in,
            data=>rom_instruct
        );

    -- instantiate the decoder
    decoder: entity work.decoder(decoder_arch)
        port map(
            data=>decoder_instruct_in,
            opcode=>decoder_opcode,
            rs1=>decoder_rs1,
            rs2=>decoder_rs2,
            rd=>decoder_rd,
            f3=>decoder_f3,
            f7=>decoder_f7
        );

    -- instantiate the immediate generator
    imm_gen: entity work.imm_gen(imm_gen_arch)
        port map(
            data=>imm_instruct_in,
            opcode=>imm_opcode_in,
            f3=>imm_f3_in,
            imm=>imm
        );
    
    -- instantiate the control unit
    ctrl_unit: entity work.ctrl_unit(ctrl_unit_arch)
        port map(
            clk=>clk,
            state=>cu_state,
            opcode=>cu_opcode_in,
            rs1=>cu_rs1_in,
            rs2=>cu_rs2_in,
            rd=>cu_rd_in,
            f3=>cu_f3_in,
            f7=>cu_f7_in,
            imm=>cu_imm_in,
            pc_addr_in=>cu_pc_addr_in,
            pc_op=>cu_pc_op_out,
            pc_addr_out=>cu_pc_addr_out
        );

    process(reset, clk)
    begin
        if reset = '1' then
            state <= "000";          -- should be in fetch state initially
            pc_op <= "00";          -- pc addr out should remain same for now - no increment
            cu_state <= '0';        -- control unit should be in its first stage
        elsif rising_edge(clk) then
            case state is
                when "000" =>                                -- fetch 
                    rom_addr_in <= pc_addr;                 -- pc address should be sent to rom
                    state <= "001";        
                when "001" =>
                    decoder_instruct_in <= rom_instruct;    -- instruction received from rom sent to decoder
                    imm_instruct_in <= rom_instruct;        -- instruction from rom also sent to imm gen
                    imm_opcode_in <= decoder_opcode;        -- opcode from decoder sent to imm gen
                    imm_f3_in <= decoder_f3;                -- f3 from decoder sent to imm gen
                    state <= "011";                          -- move to decode
                
                when "011" =>
                    cu_state <= '0';                        -- control unit should be in its first state
                    cu_opcode_in <= decoder_opcode;         -- decoder outputs are sent to control unit
                    cu_rs1_in <= decoder_rs1;
                    cu_rs2_in <= decoder_rs2;
                    cu_rd_in <= decoder_rd;
                    cu_f3_in <= decoder_f3;
                    cu_f7_in <= decoder_f7;
                    cu_imm_in <= imm;                       -- immediate is sent to control unit
                    cu_pc_addr_in <= pc_addr;               -- current pc address is sent to control unit
                    pc_op <= cu_pc_op_out;                  -- outputs of control unit are sent to pc
                    pc_addr_in <= cu_pc_addr_out;
                    state <= "100";
                
                when "100" =>                               -- execute
                    cu_state <= '1';                        -- control unit should be in its second state state
                    cu_opcode_in <= decoder_opcode;         -- decoder outputs are sent to control unit
                    cu_rs1_in <= decoder_rs1;
                    cu_rs2_in <= decoder_rs2;
                    cu_rd_in <= decoder_rd;
                    cu_f3_in <= decoder_f3;
                    cu_f7_in <= decoder_f7;
                    cu_imm_in <= imm;                       -- immediate is sent to control unit
                    cu_pc_addr_in <= pc_addr;               -- current pc address is sent to control unit
                    pc_op <= cu_pc_op_out;                  -- outputs of control unit are sent to pc
                    pc_addr_in <= cu_pc_addr_out;
                    state <= "000";
                when others =>
                    pc_op <= "00";
            end case;
        end if;
    end process;
end cpu_arch;