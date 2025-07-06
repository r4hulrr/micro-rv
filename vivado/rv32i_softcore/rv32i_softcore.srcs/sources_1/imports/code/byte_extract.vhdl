library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity byte_extract is
    port(
        i_be_en     : in std_logic;                              -- Byte enable
        i_data      : in std_logic_vector(31 downto 0);          -- Data from rs2 (store) or memory (load)
        i_f3        : in std_logic_vector(2 downto 0);           -- funct3
        o_data      : out std_logic_vector(31 downto 0)          -- Output for RAM or regfile
    );
end byte_extract;

architecture byte_extract_arch of byte_extract is
begin
    process(i_be_en, i_data, i_f3)
    begin
        if i_be_en = '1' then
            case i_f3 is
                -- STORE / LOAD BYTE (sb / lb)
                when "000" =>  
                    o_data <= std_logic_vector(resize(signed(i_data(7 downto 0)), 32));  -- sign-extend byte
                -- STORE / LOAD HALFWORD (sh / lh)
                when "001" =>  
                    o_data <= std_logic_vector(resize(signed(i_data(15 downto 0)), 32)); -- sign-extend halfword
                -- STORE / LOAD WORD (sw / lw)
                when "010" =>  
                    o_data <= i_data;  -- full word
                -- LOAD BYTE UNSIGNED (lbu)
                when "100" =>
                    o_data <= std_logic_vector(resize(unsigned(i_data(7 downto 0)), 32));
                -- LOAD HALFWORD UNSIGNED (lhu)
                when "101" =>
                    o_data <= std_logic_vector(resize(unsigned(i_data(15 downto 0)), 32)); -- zero-extend halfword
                when others =>
                    o_data <= (others => '0');
            end case;
        else
            o_data <= i_data;
        end if;
    end process;
end byte_extract_arch;
