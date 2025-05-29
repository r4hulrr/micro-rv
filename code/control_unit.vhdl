library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_unit is 
    port(
        clk,reset: in std_logic;
        opcode: in std_logic_vector(6 downto 0);
        rs1,rs2,rd: in std_logic_vector(4 downto 0);
        f3: in std_logic_vector(2 downto 0);
        f7: in std_logic_vector(6 downto 0);
        imm: in std_logic_vector(31 downto 0);
        pc_addr_in: in std_logic_vector(7 downto 0);           -- current pc address
        pc_op: out std_logic_vector(1 downto 0);            -- pc opcode and address to change to 
        pc_addr_out: out std_logic_vector(7 downto 0)        -- if required
    );
end ctrl_unit;

architecture ctrl_unit_arch of ctrl_unit is
    -- signals for the register file
    signal rf_wr_en: std_logic;										            -- clk, write enable signals
    signal rf_rd_sel1, rf_rd_sel2, rf_rw_sel: std_logic_vector (4 downto 0);	-- to choose which of the 32 registers to read/write to 
    signal rf_data_in: std_logic_vector (31 downto 0);						    -- data in from memory if writing to register
    signal rf_rd1, rf_rd2: std_logic_vector (31 downto 0);					    -- data out from selected registers
    -- alu signals
    signal alu_op: std_logic_vector(3 downto 0);
    signal alu_a, alu_b: std_logic_vector(31 downto 0);
    signal alu_output: std_logic_vector(31 downto 0);
begin
    -- instantiate the register file
    register_file: entity work.reg_file(reg_file_arch)
        port map(
            clk=>clk,
            wr_en=>rf_wr_en,
            rd_sel1=>rf_rd_sel1,
            rd_sel2=>rf_rd_sel2,
            rw_sel=>rf_rw_sel,
            data_in=>rf_data_in,
            rd1=>rf_rd1,
            rd2=>rf_rd2
            );
    
    -- instantiate the alu
    alu: entity work.alu(alu_arch)
        port map(
            alu_op=>alu_op,
            a=>alu_a,
            b=>alu_b,
            d=>alu_output
        );

    -- process for loading immediates into registers
    process (opcode,rs1,rs2,rd,f3,f7,imm)
    begin
        case opcode is
            when "0110111" =>                                   -- lui 
                rf_rw_sel <= rd;                                -- writes the immediate into register rd
                rf_data_in <= imm;
            when "0010111" =>                                   -- auipc
                alu_a <= pc_addr_in;                            -- process imm + pc in alu 
                alu_b <= imm;                                   -- and writes into register rd
                alu_op <= "0000";
                rf_rw_sel <= rd;                                
                rf_data_in <= alu_output;
            when "1100011" =>                                   -- branch instructions
                rf_rd_sel1 <= rs1;                              -- gets the value of the two registers to compare
                rf_rd_sel2 <= rs2;
                case f3 is
                    when "000"=>                                -- beq
                        if signed(rf_rd1) = signed(rf_rd2) then -- compares values stored in rs1 and rs2     
                            alu_a <= pc_addr_in;                -- if equal PC:= PC + imm;
                            alu_b <= imm;
                            alu_op <= "0000";
                            pc_op <= "10";
                            pc_addr_out <= alu_output;
                        else
                            pc_op <= "01";                      -- if not equal PC = PC + 4;
                        end if;
                    when "001"=>                                -- bne
                        if signed(rf_rd1) /= signed(rf_rd2) then
                            alu_a <= pc_addr_in;                -- if not equal PC:= PC + imm;
                            alu_b <= imm;
                            alu_op <= "0000";
                            pc_op <= "10";
                            pc_addr_out <= alu_output;
                        else
                            pc_op <= "01";                      -- if equal PC = PC + 4;
                        end if;
                    when "100"=>                                -- blt
                        if signed(rf_rd1) < signed(rf_rd2) then
                            alu_a <= pc_addr_in;                -- if less than  PC:= PC + imm;
                            alu_b <= imm;
                            alu_op <= "0000";
                            pc_op <= "10";
                            pc_addr_out <= alu_output;
                        else
                            pc_op <= "01";                      -- if not less than PC = PC + 4;
                        end if;
                    when "101"=>                                -- bge
                        if signed(rf_rd1) > signed(rf_rd2) or signed(rf_rd1) = signed(rf_rd2) then
                            alu_a <= pc_addr_in;                -- if greater than or equal PC:= PC + imm;
                            alu_b <= imm;
                            alu_op <= "0000";
                            pc_op <= "10";
                            pc_addr_out <= alu_output;
                        else
                            pc_op <= "01";                      -- if less than PC = PC + 4;
                        end if;
                    when "110"=>                                -- bltu
                        if unsigned(rf_rd1) < unsigned(rf_rd2) then
                            alu_a <= pc_addr_in;                -- if less than  PC:= PC + imm;
                            alu_b <= imm;
                            alu_op <= "0000";
                            pc_op <= "10";
                            pc_addr_out <= alu_output;
                        else
                            pc_op <= "01";                      -- if not less than PC = PC + 4;
                        end if;
                    when "111"=>                                -- bgeu
                        if unsigned(rf_rd1) > unsigned(rf_rd2) or unsigned(rf_rd1) = unsigned(rf_rd2) then
                            alu_a <= pc_addr_in;                -- if greater than or equal PC:= PC + imm;
                            alu_b <= imm;
                            alu_op <= "0000";
                            pc_op <= "10";
                            pc_addr_out <= alu_output;
                        else
                            pc_op <= "01";                      -- if less than PC = PC + 4;
                        end if;
                end case;
            when "1101111" =>                                               -- jal
                alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));    -- passes pc address and the value of 4 to
                alu_b <= x"00000004";                                       -- alu to increment the program counter by a word
                alu_op <= "0000";
            when "1100111" =>                                               -- jalr
                alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));    -- passes pc address and the value of 4 to
                alu_b <= x"00000004";                                       -- alu to increment the program counter by a word
                alu_op <= "0000";
                rf_rd_sel1 <= rs1;                      -- to get the value of rs1 register from register file
            when "0000011" | "0100011" =>   -- memory store and load instructions
                alu_op <= "0000";           -- add as the value in rs1 should be added to immediate
                rf_rd_sel1 <= rs1;          -- to get the value of rs1 register from register file
            when "0110011" | "0010011" =>           -- register-register instructions and register-immediate instructions
                rf_rd_sel1 <= rs1;                  -- to get the value of rs1 register from register file
                case f3 is
                    when "000" =>
                        if f7 = "0100000" then
                            alu_op <= "0001";           -- SUB
                        elsif f7 = "0000000" then
                            alu_op <= "0000";           -- ADD
                        end if;
                    when "001" =>
                        alu_op <= "0010";               -- SLL
                    when "010" =>
                        alu_op <= "0011";               -- SLT
                    when  "011" =>
                        alu_op <= "0100";               -- SLTU
                    when "100" =>
                        alu_op <= "0101";               -- XOR
                    when "101" =>
                        if f7 = "0100000" then
                            alu_op <= "0111";           -- SRA
                        elsif f7 = "0000000" then
                            alu_op <= "0110";           -- SRL
                        end if;
                    when "110" =>
                        alu_op <= "1000";               -- OR
                    when "111" =>
                        alu_op <= "1001";               -- AND
                    when others =>
                        alu_op <= (others => '0');
                end case;
        end case;
    end process;
end ctrl_unit_arch;