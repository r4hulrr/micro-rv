library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        i_clk   : in std_logic;
        i_reset : in std_logic;
        i_addr  : in std_logic_vector(7 downto 0); -- 8-bit byte address
        o_ins   : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rom_arch of rom is
    type rom_type is array(0 to 255) of std_logic_vector(31 downto 0); -- 256 words (1 KB)
    signal sig_insn_mem : rom_type := (
        -- U-Type: LUI, AUIPC
        0  => x"00A001B7", -- LUI x3, 0x00A00
        1  => x"00A00217", -- AUIPC x4, 0x00A00
    
        -- J-Type: JAL
        2  => x"004002EF", -- JAL x5, 4
    
        -- I-Type: JALR
        3  => x"00428367", -- JALR x6, 4(x5)
    
        -- Store instructions (S-Type)
        4  => x"00328023", -- SB x3, 0(x5)
        5  => x"00429023", -- SH x4, 0(x5)
        6  => x"0052A023", -- SW x5, 0(x5)
    
        -- Load instructions (I-Type) - AFTER store
        7  => x"00020103", -- LB x2, 0(x4)
        8  => x"0002A203", -- LH x4, 0(x5)
        9  => x"0002A283", -- LW x5, 0(x5)
        10 => x"0002A303", -- LBU x6, 0(x5)
        11 => x"0002A383", -- LHU x7, 0(x5)
    
        -- I-Type ALU ops
        12 => x"0062A393", -- ADDI x7, x5, 6
        13 => x"0062B393", -- SLTI x7, x5, 6
        14 => x"0062C393", -- SLTIU x7, x5, 6
        15 => x"0062E393", -- ORI x7, x5, 6
        16 => x"0062F393", -- ANDI x7, x5, 6
        17 => x"0022D393", -- SRAI x7, x5, 2
        18 => x"0022C393", -- SRLI x7, x5, 2
        19 => x"0022A393", -- SLLI x7, x5, 2
        20 => x"0062E393", -- XORI x7, x5, 6
    
        -- R-Type ALU ops
        21 => x"0062B3B3", -- ADD x7, x5, x6
        22 => x"4062B3B3", -- SUB x7, x5, x6
        23 => x"0062A3B3", -- SLL x7, x5, x6
        24 => x"0062D3B3", -- SLT x7, x5, x6
        25 => x"0062F3B3", -- SLTU x7, x5, x6
        26 => x"0062E3B3", -- XOR x7, x5, x6
        27 => x"0062C3B3", -- SRL x7, x5, x6
        28 => x"4062C3B3", -- SRA x7, x5, x6
        29 => x"0062E3B3", -- OR x7, x5, x6
        30 => x"0062F3B3", -- AND x7, x5, x6
    
        -- Branch instructions (B-Type)
        31 => x"00628663", -- BEQ x5, x6, +12
        32 => x"00629663", -- BNE x5, x6, +12
        33 => x"0062C663", -- BLT x5, x6, +12
        34 => x"0062D663", -- BGE x5, x6, +12
        35 => x"0062E663", -- BLTU x5, x6, +12
        36 => x"0062F663", -- BGEU x5, x6, +12
    
        -- Padding / NOPs
        37 => x"00000013", -- NOP (ADDI x0, x0, 0)
        38 => x"00000013",
        39 => x"00000013",
    
        others => x"00000013"
    );
begin
    process(i_addr)
    begin
        o_ins <= sig_insn_mem(to_integer(unsigned(i_addr(7 downto 2))));
    end process;
end architecture;
