library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        clk, reset: in std_logic          -- clock and reset input
    );
end entity;

architecture cpu_arch of cpu is
    -- program counter signals
    signal pc_op: std_logic_vector(1 downto 0);                -- opcode for program counter
    signal pc_addr_in: std_logic_vector(7 downto 0);    -- increments normally if opcode = 0 
    signal pc_addr: std_logic_vector(7 downto 0);       -- or changes addr to addr_in if opcode = 1

    -- rom signal
    signal rom_instruct: std_logic_vector(31 downto 0); -- instruction received from rom 

    -- decoder signals
    signal decoder_opcode: std_logic_vector(6 downto 0);
    signal decoder_rs1, decoder_rs2, decoder_rd: std_logic_vector(4 downto 0);
    signal decoder_f3: std_logic_vector(2 downto 0);
    signal decoder_f7: std_logic_vector(6 downto 0);

    -- immediate generator signal
    signal imm: std_logic_vector(31 downto 0);

    -- alu signals
    signal alu_op: std_logic_vector(3 downto 0);
    signal alu_a, alu_b: std_logic_vector(31 downto 0);
    signal alu_output: std_logic_vector(31 downto 0);
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
            addr=>pc_addr,
            data=>rom_instruct
        );

    -- instantiate the decoder
    decoder: entity work.decoder(decoder_arch)
        port map(
            data=>rom_instruct,
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
            data=>rom_instruct,
            opcode=>decoder_opcode,
            f3=>decoder_f3,
            imm=>imm
        );
    
    -- instantiate the control unit
    ctrl_unit: entity work.ctrl_unit(ctrl_unit_arch)
        port map(
            clk=>clk,
            reset=>reset,
            opcode=>decoder_opcode,
            rs1=>decoder_rs1,
            rs2=>decoder_rs2,
            rd=>decoder_rd,
            f3=>decoder_f3,
            f7=>decoder_f7,
            imm=>imm,
            alu_op=>alu_op,
            alu_a=>alu_a,
            alu_b=>alu_b
        );
    -- instantiate the alu
    alu: entity work.alu(alu_arch)
        port map(
            alu_op=>alu_op,
            a=>alu_a,
            b=>alu_b,
            d=>alu_output
        );
    process(clk)
    begin
        if reset = '1' then
            pc_op <= "00";
        elsif rising_edge(clk) then

        end if;
    end process;
end cpu_arch;