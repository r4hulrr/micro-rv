library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        i_clk   : in std_logic;
        i_reset : in std_logic;
        i_addr  : in std_logic_vector(7 downto 0); -- 8-bit address
        o_ins   : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rom_arch of rom is
    type rom_type is array(0 to 255) of std_logic_vector(31 downto 0); -- 256 x 32-bit = 1 KB ROM
    signal sig_insn_mem : rom_type := (
        0 => x"00A00113", -- addi x2, x0, 10
        1 => x"002081B3", -- add x3, x1, x2
        2 => x"00028183", -- lw x3, 0(x5)
        3 => x"00A28223", -- sw x10, 0(x5)
        4 => x"00010293", -- addi x5, x2, 0
        5 => x"0041A463", -- beq x3, x4, 8
        6 => x"00000293", -- addi x5, x0, 0
        7 => x"FF5FF06F", -- jal x0, -8 (infinite loop)
        others => x"00000013" -- default: NOP
    );
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            o_ins <= sig_insn_mem(to_integer(unsigned(i_addr)));
        end if;
    end process;
end architecture;
