library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_unit is
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
        o_mux_wb    : out std_logic_vector(1 downto 0)  -- mux that controls writeback
    )
end ctrl_unit;

architecture ctrl_unit_arch is
    constant OP_LUI     : std_logic_vector(6 downto 0) := "0110111";
    constant OP_AUIPC   : std_logic_vector(6 downto 0) := "0010111";
    constant OP_JAL     : std_logic_vector(6 downto 0) := "1101111";
    constant OP_BR      : std_logic_vector(6 downto 0) := "1100011";
    constant OP_JALR    : std_logic_vector(6 downto 0) := "1100111";
    constant OP_LOAD    : std_logic_vector(6 downto 0) := "0000011";
    constant OP_ALUI    : std_logic_vector(6 downto 0) := "0010011";
    constant OP_STORE    : std_logic_vector(6 downto 0) := "0100011";
    constant OP_ALU    : std_logic_vector(6 downto 0) := "0110011";
begin
    process(i_ins)
        variable opcode : std_logic_vector(6 downto 0);
        variable f3     : std_logic_vector(2 downto 0);
        variable f7     : std_logic_vector(6 downto 0);
    begin
        opcode  := i_ins(6 downto 0);
        f3      := i_ins(14 downto 12);
        f7      := i_ins(31 downto 25);

        if (opcode = OP_ALUI) or (opcode = OP_ALU) then
            case(f3) is
                when "000" =>
                    if (opcode = OP_ALU) and (f7 = "0100000") then
                        o_alu_op <= "0001"; -- sub
                    else
                        o_alu_op <= "0000"; -- add
                    end if;
                when "001" =>
                    o_alu_op <= "0010"; -- shift left
                when "101" =>
                    if (f7 = "0000000") then
                        o_alu_op <= "0110"; -- shift right logical
                    else
                        o_alu_op <= "0111"; -- shift right arithmetic
                    end if;
                when "010" =>
                    o_alu_op <= "0011"; -- slt
                when "011" =>
                    o_alu_op <= "0100"; --sltu
                when "100" =>
                    o_alu_op <= "0101"; --xor
                when "110" =>
                    o_alu_op <= "1000"; --or
                when "111" =>
                    o_alu_op <= "1001"; --and
        else
            o_alu_op <= "0000"; -- add
        end if;

        o_mux_alu_b <= '1' when (opcode = OP_LUI
                                or opcode = OP_AUIPC
                                or opcode = OP_LOAD
                                or opcode = OP_ALUI
                                or opcode = OP_STORE) else
                        '0';
        o_mux_alu_a <= "10" when opcode = OP_LUI else
                        "01" when opcode = OP_AUIPC else
                        "00";
        o_rf_wr_en  <= '1' when (opcode = OP_LUI
                                or opcode = OP_AUIPC
                                or opcode = OP_JAL
                                or opcode = OP_JALR
                                or opcode = OP_LOAD
                                or opcode = OP_ALUI
                                or opcode = OP_ALU) else
                        '0';
        o_mux_wb    <= "01" when (opcode = OP_LUI
                                or opcode = OP_AUIPC
                                or opcode = OP_ALUI
                                or opcode = OP_ALU) else
                        "10" when (opcode = OP_JAL
                                or opcode = OP_JALR) else
                        "00";
        o_br_en     <= '1' when (opcode = OP_JAL
                                or opcode = OP_BR
                                or opcode = OP_JALR) else
                        '0';
        o_op_bl     <= '1' when (opcode = OP_LOAD) else
                        '0';
        o_op_bs     <= '1' when (opcode = OP_STORE) else
                        '0';
        o_ram_wr_en <= '1' when opcode = OP_STORE else
                        '0';
    end process;
end ctrl_unit_arch;