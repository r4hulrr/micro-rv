library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imm_gen is
    port(
        i_ins: in std_logic_vector(31 downto 0);
        o_imm: out std_logic_vector(31 downto 0)
    );
end entity;

architecture imm_gen_arch of imm_gen is
begin
    process(i_ins)
        variable opcode : std_logic_vector(6 downto 0);
        variable f3     : std_logic_vector(2 downto 0);
    begin
        opcode  := i_ins(6 downto 0);
        f3      := i_ins(14 downto 12);
        case opcode is
            when "0110111"|"0010111" =>
                o_imm <= i_ins(31 downto 12) & (11 downto 0 => '0');
            when "1101111" =>
                o_imm <= std_logic_vector(resize(signed((
                    i_ins(31)                    -- imm[20]
                    & i_ins(19 downto 12)        -- imm[19:12] 
                    & i_ins(20)                  -- imm[11]
                    & i_ins(30 downto 21)        -- imm[10:1]
                    & '0'                       -- imm[0]
                    )),32));
            when "1100011" =>
                o_imm <= std_logic_vector(resize(signed((
                    i_ins(31)                    -- imm[12]
                    & i_ins(7)                   -- imm[11] 
                    & i_ins(30 downto 25)        -- imm[10:5]
                    & i_ins(11 downto 8)         -- imm[4:1]
                    & '0'                       -- imm[0]
                    )),32));
            when "1100111"|"0000011" =>
                o_imm <= std_logic_vector(resize(signed((
                    i_ins(31 downto 20)          -- imm[11:0]
                    )),32));
            when "0010011" =>
                case f3 is
                    when "001" | "101" =>
                        o_imm <= std_logic_vector(resize(unsigned((
                            i_ins(24 downto 20)          -- shamt
                            )),32));
                    when others =>
                        o_imm <= std_logic_vector(resize(signed((
                            i_ins(31 downto 20)          -- imm[11:0]
                            )),32));
                end case;
            when "0100011" =>
                o_imm <= std_logic_vector(resize(signed((
                    i_ins(31 downto 25)          -- imm[11:5]
                    & i_ins(11 downto 7)         -- imm[4:0] 
                    )),32));    
            when others =>
                o_imm <= (31 downto 0 => '0');
        end case;
    end process;
end imm_gen_arch;