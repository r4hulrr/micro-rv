library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        clk, reset: in std_logic          -- clock and reset input
    );
end entity;

architecture cpu_arch of cpu is
    -- states of cpu
    signal state: std_logic_vector(1 downto 0);         -- states of the cpu in fsm (fetch, decode, execute)

    -- program counter signals
    signal pc_op: std_logic_vector(1 downto 0);         -- opcode for program counter
    signal pc_addr_in: std_logic_vector(7 downto 0);    -- increments normally if opcode = 0 
    signal pc_addr: std_logic_vector(7 downto 0);       -- or changes addr to addr_in if opcode = 1

    -- rom signals
    signal rom_addr_in: std_logic_vector(7 downto 0);   -- address of rom array to read from
    signal rom_instruct: std_logic_vector(31 downto 0); -- instruction received from rom 

    -- decoder signals
    signal decoder_instruct_in: std_logic_vector(31 downto 0);  -- raw instruction from rom that is sent to decoder
    signal decoder_opcode: std_logic_vector(6 downto 0);        
    signal decoder_rs1, decoder_rs2, decoder_rd: std_logic_vector(4 downto 0);
    signal decoder_f3: std_logic_vector(2 downto 0);
    signal decoder_f7: std_logic_vector(6 downto 0);

    -- immediate generator signals
    signal imm_instruct_in: std_logic_vector(31 downto 0);
    signal imm_opcode_in: std_logic_vector(6 downto 0);
    signal imm_f3_in: std_logic_vector(2 downto 0);
    signal imm: std_logic_vector(31 downto 0);

    -- control unit signals
    signal cu_state: std_logic;
    signal cu_opcode_in: std_logic_vector(6 downto 0);        
    signal cu_rs1_in, cu_rs2_in, cu_rd_in: std_logic_vector(4 downto 0);
    signal cu_f3_in: std_logic_vector(2 downto 0);
    signal cu_f7_in: std_logic_vector(6 downto 0);
    signal cu_imm_in: std_logic_vector(31 downto 0);
    signal cu_pc_addr_in: std_logic_vector(7 downto 0);
    signal cu_pc_op_out: std_logic_vector(1 downto 0);            
    signal cu_pc_addr_out: std_logic_vector(7 downto 0);       

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

    process(clk)
    begin
        if reset = '1' then
            state <= "00";          -- should be in fetch state initially
            pc_op <= "00";          -- pc addr out should remain same for now - no increment
            cu_state <= '0';        -- control unit should be in its first stage
        elsif rising_edge(clk) then
            case state is
                when "00" =>                                -- fetch 
                    rom_addr_in <= pc_addr;                 -- pc address should be sent to rom
                    decoder_instruct_in <= rom_instruct;    -- instruction received from rom sent to decoder
                    imm_instruct_in <= rom_instruct;        -- instruction from rom also sent to imm gen
                    imm_opcode_in <= decoder_opcode;        -- opcode from decoder sent to imm gen
                    imm_f3_in <= decoder_f3;                -- f3 from decoder sent to imm gen
                    state <= "01";                          -- move to decode

                when "01" =>                                -- decode
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
                    state <= "10";
                
                when "10" =>                                -- execute
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
                    state <= "00";
            end case;
        end if;
    end process;
end cpu_arch;