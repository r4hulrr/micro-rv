library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity byte_extract is
    port(
        i_be_en     : in std_logic;
        i_rs2       : in std_logic_vector(31 downto 0);
        i_f3        : in std_logic_vector(2 downto 0);
        o_data      : out std_logic_vector(31 downto 0)
    )
end byte_extract;

architecture byte_extract_arch is 
begin
    process(i_be_en,
            i_rs2,
            i_f3)
    begin
        if i_be_en = '1' then
            case i_f3 is
                when "000" =>
                    o_data <= x"000000" & i_rs2(7 downto 0);
                when "001" =>
                    o_data <= x"000000" & i_rs2(7 downto 0);
                when "010" =>

                when "100" =>

                when "101" =>

                when others =>
        else
            o_data <= i_rs2;
        end if;
    end process;
end byte_extract_arch;