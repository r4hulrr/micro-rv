library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_logic is
    port(
        i_branch_en : std_logic;
        i_rs1       : std_logic_vector(31 downto 0);
        i_rs2       : std_logic_vector(31 downto 0);
        i_f3        : std_logic_vector(2 downto 0);
        i_imm       : std_logic_vector(31 downto 0);
        i_pc        : std_logic_vector(7 downto 0);
        o_pc      : std_logic_vector(31 downto 0)
    )
end branch_logic;

architecture branch_logic_arch is 
begin
    variable var_incr: unsigned(31 downto 0);
    process(i_branch_en, 
            i_rs1,
            i_rs2,
            i_f3,
            i_imm)
    begin
        if (i_branch_en = '1') then
            case i_f3 is
                when "000"=>                                -- beq
                    if signed(i_rs1) = signed(i_rs2) then -- compares values stored in rs1 and rs2     
                        var_incr := i_imm;
                        o_pc <= i_pc + var_incr;
                    else
                        var_incr := X"00000004";
                        o_pc <= i_pc + var_incr;
                    end if;
                when "001"=>                                -- bne
                    if signed(i_rs1) /= signed(i_rs2) then
                        var_incr := i_imm;                -- if not equal PC:= PC + imm;
                        o_pc <= i_pc + var_incr;
                    else
                        var_incr := X"00000004";                      -- if equal PC = PC + 4;
                        o_pc <= i_pc + var_incr;
                    end if;
                when "100"=>                                -- blt
                    if signed(i_rs1) < signed(i_rs2) then
                        var_incr := i_imm;        -- if less than  PC:= PC + imm;
                        o_pc <= i_pc + var_incr;
                    else
                        var_incr := X"00000004";                      -- if not less than PC = PC + 4;
                        o_pc <= i_pc + var_incr;
                    end if;
                when "101"=>                                -- bge
                    if signed(i_rs1) > signed(i_rs2) or signed(i_rs1) = signed(i_rs2) then
                        var_incr := i_imm;                -- if greater than or equal PC:= PC + imm;
                        o_pc <= i_pc + var_incr;
                    else
                        var_incr := X"00000004";                       -- if less than PC = PC + 4;
                        o_pc <= i_pc + var_incr;
                    end if;
                when "110"=>                                -- bltu
                    if unsigned(i_rs1) < unsigned(i_rs2) then
                        var_incr := i_imm;                -- if less than  PC:= PC + imm;
                        o_pc <= i_pc + var_incr;
                    else
                        var_incr := X"00000004";                      -- if not less than PC = PC + 4;
                        o_pc <= i_pc + var_incr;
                    end if;
                when "111"=>                                -- bgeu
                    if unsigned(i_rs1) > unsigned(i_rs2) or unsigned(i_rs1) = unsigned(i_rs2) then
                        var_incr := i_imm;               -- if greater than or equal PC:= PC + imm;
                        o_pc <= i_pc + var_incr;
                    else
                        var_incr := X"00000004";                       -- if less than PC = PC + 4;
                        o_pc <= i_pc + var_incr;
                    end if;
                when others =>                              -- jalr
                    var_incr := unsigned(i_rs1) + unsigned(imm); 
                    o_pc <= i_pc + var_incr;
            end case;
        else
            var_incr := X"00000004";
        end if;
    end process;
end branch_logic_arch;