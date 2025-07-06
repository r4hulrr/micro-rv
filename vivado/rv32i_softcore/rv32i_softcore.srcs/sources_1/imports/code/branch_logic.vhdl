library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_logic is
    port(
        i_branch_en : in  std_logic;
        i_rs1       : in  std_logic_vector(31 downto 0);
        i_rs2       : in  std_logic_vector(31 downto 0);
        i_op        : in  std_logic_vector(6 downto 0);
        i_f3        : in  std_logic_vector(2 downto 0);
        i_imm       : in  std_logic_vector(31 downto 0);
        i_pc        : in  std_logic_vector(7 downto 0);   
        o_pc        : out std_logic_vector(7 downto 0)    
    );
end branch_logic;

architecture branch_logic_arch of branch_logic is 
begin
    process(i_branch_en, i_rs1, i_rs2, i_op, i_f3, i_imm, i_pc)
        variable var_incr : unsigned(7 downto 0); 
        variable next_pc  : unsigned(7 downto 0);
        variable imm_trunc : unsigned(7 downto 0); 
    begin
        imm_trunc := resize(unsigned(i_imm), 8); 

        if i_branch_en = '1' then
            if i_op = "1101111" then  -- jal
                next_pc := unsigned(i_pc) + imm_trunc;

            elsif i_op = "1100111" then  -- jalr
                next_pc := unsigned(i_rs1(7 downto 0)) + imm_trunc; 

            else
                case i_f3 is
                    when "000" => -- beq
                        if signed(i_rs1) = signed(i_rs2) then
                            var_incr := imm_trunc;
                        else
                            var_incr := to_unsigned(4, 8);
                        end if;
                        next_pc := unsigned(i_pc) + var_incr;

                    when "001" => -- bne
                        if signed(i_rs1) /= signed(i_rs2) then
                            var_incr := imm_trunc;
                        else
                            var_incr := to_unsigned(4, 8);
                        end if;
                        next_pc := unsigned(i_pc) + var_incr;

                    when "100" => -- blt
                        if signed(i_rs1) < signed(i_rs2) then
                            var_incr := imm_trunc;
                        else
                            var_incr := to_unsigned(4, 8);
                        end if;
                        next_pc := unsigned(i_pc) + var_incr;

                    when "101" => -- bge
                        if signed(i_rs1) >= signed(i_rs2) then
                            var_incr := imm_trunc;
                        else
                            var_incr := to_unsigned(4, 8);
                        end if;
                        next_pc := unsigned(i_pc) + var_incr;

                    when "110" => -- bltu
                        if unsigned(i_rs1) < unsigned(i_rs2) then
                            var_incr := imm_trunc;
                        else
                            var_incr := to_unsigned(4, 8);
                        end if;
                        next_pc := unsigned(i_pc) + var_incr;

                    when "111" => -- bgeu
                        if unsigned(i_rs1) >= unsigned(i_rs2) then
                            var_incr := imm_trunc;
                        else
                            var_incr := to_unsigned(4, 8);
                        end if;
                        next_pc := unsigned(i_pc) + var_incr;

                    when others =>
                        next_pc := unsigned(i_pc);
                end case;
            end if;
        else
            next_pc := unsigned(i_pc) + to_unsigned(4, 8);
        end if;
        o_pc <= std_logic_vector(next_pc);
    end process;
end branch_logic_arch;
