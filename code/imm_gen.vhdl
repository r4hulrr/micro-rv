library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imm_gen is
    port(
        data: in std_logic_vector(31 downto 0);
        opcode: in std_logic_vector(7 downto 0);
        f3: in std_logic_vector(2 downto 0);
        imm: out std_logic_vector(31 downto 0)
    );
end entity;

architecture imm_gen_arch of imm_gen is
begin
    process(opcode,data,f3)
    begin
        case opcode is
            when "0110111"|"0010111" =>
                imm <= data(31 downto 12) & (11 downto 0 => '0');
            when "1101111" =>
                imm <= std_logic_vector(resize(signed((
                    data(31)                    -- imm[20]
                    & data(19 downto 12)        -- imm[19:12] 
                    & data(20)                  -- imm[11]
                    & data(30 downto 21)        -- imm[10:1]
                    & '0'                       -- imm[0]
                    )),32));
            when "1100011" =>
                imm <= std_logic_vector(resize(signed((
                    data(31)                    -- imm[12]
                    & data(7)                   -- imm[11] 
                    & data(30 downto 25)        -- imm[10:5]
                    & data(11 downto 8)         -- imm[4:1]
                    & '0'                       -- imm[0]
                    )),32));
            when "1100111"|"0000011" =>
                imm <= std_logic_vector(resize(signed((
                    data(31 downto 20)          -- imm[11:0]
                    )),32));
            when "0010011" =>
                case f3 is
                    when "001" | "101" =>
                        imm <= std_logic_vector(resize(unsigned((
                            data(24 downto 20)          -- shamt
                            )),32));
                    when others =>
                        imm <= std_logic_vector(resize(signed((
                            data(31 downto 20)          -- imm[11:0]
                            )),32));
                end case;
            when "0100011" =>
                imm <= std_logic_vector(resize(signed((
                    data(31 downto 25)          -- imm[11:5]
                    & data(11 downto 7)         -- imm[4:0] 
                    )),32));    
            when others =>
                imm <= (31 downto 0 => 0);
        end case;
    end process;
end imm_gen_arch;