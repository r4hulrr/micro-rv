library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
    port(
        data: in std_logic_vector(31 downto 0);
        opcode: out std_logic_vector(6 downto 0);
        rs1, rs2, rd: out std_logic_vector(4 downto 0);
        f3: out std_logic_vector(2 downto 0);
        f7: out std_logic_vector(6 downto 0)
    );
end decoder;

architecture decoder_arch of decoder is
begin
    opcode <= data(6 downto 0);
    rd <= data(11 downto 7);
    f3 <= data(14 downto 12);
    rs1 <= data(19 downto 15);
    rs2 <= data(24 downto 20);
    f7 <= data(31 downto 25);
end decoder_arch;