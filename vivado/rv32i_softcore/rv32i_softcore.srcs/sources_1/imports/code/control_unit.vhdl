library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_unit is 
    port(
        clk,state: in std_logic;
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
    -- ram signals 
    signal ram_wr_en,ram_rd_en: std_logic;				-- read enable and write enable
	signal ram_addr: std_logic_vector(9 downto 0);		-- address in ram to read/write
	signal ram_data_in: std_logic_vector(31 downto 0);	-- data to write to register
	signal ram_data_out: std_logic_vector(31 downto 0);	-- data read from register
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

    -- instantiate the ram
    ram: entity work.ram(ram_arch)
        port map(
            clk=>clk,
            wr_en=>ram_wr_en,
            rd_en=>ram_rd_en,
            addr=>ram_addr,
            data_in=>ram_data_in,
            data_out=>ram_data_out
        );

    -- process for loading immediates into registers
    process (opcode,rs1,rs2,rd,f3,f7,imm)
    begin
        if state = '0' then
            case opcode is
                -- u type instructions
                when "0110111" =>                                   -- lui 
                    rf_rw_sel <= rd;                                -- writes the immediate into register rd
                    rf_data_in <= imm;
                when "0010111" =>                                               -- auipc
                    alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32)); -- process imm + pc in alu 
                    alu_b <= imm;                                               -- and writes into register rd
                    alu_op <= "0000";
                    rf_wr_en <= '1';
                    rf_rw_sel <= rd;                                
                    rf_data_in <= alu_output;

                -- j type instruction and some i type instructions
                when "1101111" =>                                                   -- jal or jalr
                    alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));     -- passes pc address and the value of 4 to
                    alu_b <= x"00000004";                                           -- alu to increment the program counter by a word
                    alu_op <= "0000";                                               -- stores PC + 4 into rd
                    rf_wr_en <= '1';
                    rf_rw_sel <= rd;
                    rf_data_in <= alu_output;

                -- b type instructions
                when "1100011" =>                                   -- branch instructions
                    rf_rd_sel1 <= rs1;                              -- gets the value of the two registers to compare
                    rf_rd_sel2 <= rs2;
                    case f3 is
                        when "000"=>                                -- beq
                            if signed(rf_rd1) = signed(rf_rd2) then -- compares values stored in rs1 and rs2     
                                alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));                -- if equal PC:= PC + imm;
                                alu_b <= imm;
                                alu_op <= "0000";
                                pc_op <= "10";
                                pc_addr_out <= alu_output(7 downto 0);
                            else
                                pc_op <= "01";                      -- if not equal PC = PC + 4;
                            end if;
                        when "001"=>                                -- bne
                            if signed(rf_rd1) /= signed(rf_rd2) then
                                alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));                -- if not equal PC:= PC + imm;
                                alu_b <= imm;
                                alu_op <= "0000";
                                pc_op <= "10";
                                pc_addr_out <= alu_output(7 downto 0);
                            else
                                pc_op <= "01";                      -- if equal PC = PC + 4;
                            end if;
                        when "100"=>                                -- blt
                            if signed(rf_rd1) < signed(rf_rd2) then
                                alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));                -- if less than  PC:= PC + imm;
                                alu_b <= imm;
                                alu_op <= "0000";
                                pc_op <= "10";
                                pc_addr_out <= alu_output(7 downto 0);
                            else
                                pc_op <= "01";                      -- if not less than PC = PC + 4;
                            end if;
                        when "101"=>                                -- bge
                            if signed(rf_rd1) > signed(rf_rd2) or signed(rf_rd1) = signed(rf_rd2) then
                                alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));                -- if greater than or equal PC:= PC + imm;
                                alu_b <= imm;
                                alu_op <= "0000";
                                pc_op <= "10";
                                pc_addr_out <= alu_output(7 downto 0);
                            else
                                pc_op <= "01";                      -- if less than PC = PC + 4;
                            end if;
                        when "110"=>                                -- bltu
                            if unsigned(rf_rd1) < unsigned(rf_rd2) then
                                alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));                -- if less than  PC:= PC + imm;
                                alu_b <= imm;
                                alu_op <= "0000";
                                pc_op <= "10";
                                pc_addr_out <= alu_output(7 downto 0);
                            else
                                pc_op <= "01";                      -- if not less than PC = PC + 4;
                            end if;
                        when "111"=>                                -- bgeu
                            if unsigned(rf_rd1) > unsigned(rf_rd2) or unsigned(rf_rd1) = unsigned(rf_rd2) then
                                alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));                -- if greater than or equal PC:= PC + imm;
                                alu_b <= imm;
                                alu_op <= "0000";
                                pc_op <= "10";
                                pc_addr_out <= alu_output(7 downto 0);
                            else
                                pc_op <= "01";                      -- if less than PC = PC + 4;
                            end if;
                        when others =>
                            pc_op <= "00";
                    end case;

                -- some i type instructions
                when "0000011" =>               -- memory load instructions
                    rf_rd_sel1 <= rs1;          -- to get the value of rs1 register from register file
                    alu_a <= rf_rd1;
                    alu_b <= imm;
                    alu_op <= "0000";           -- add as the value in rs1 should be added to immediate
                    ram_rd_en <= '1';
                    ram_addr <= alu_output(9 downto 0);     -- this value should be passed onto the ram to get data
                
                -- s type instructions
                when "0100011" =>               -- memory store instructions
                    rf_rd_sel1 <= rs1;          -- to get the value of rs1 and rs2 registers from register file
                    rf_rd_sel2 <= rs2;
                    alu_a <= rf_rd1;
                    alu_b <= imm;
                    alu_op <= "0000";           -- add as the value in rs1 should be added to immediate
                    ram_wr_en <= '1';           -- the value stored in rs2 should be written to ram address which
                    ram_addr <= alu_output(9 downto 0);     -- is the calculated value
                    case f3 is 
                        when "000" =>           -- sb
                            ram_data_in <= std_logic_vector(resize(signed(rf_rd2(7 downto 0)), 32));
                        when "001" =>           -- sh
                            ram_data_in <= std_logic_vector(resize(signed(rf_rd2(15 downto 0)), 32));
                        when "010" =>           -- sw
                            ram_data_in <= std_logic_vector(resize(signed(rf_rd2(31 downto 0)), 32));
                        when others =>
                            pc_op <= "00";
                    end case;
                    
                -- r type instructions and some i type instructions
                when "0110011"|"0010011" =>                       
                    rf_rd_sel1 <= rs1;                  -- to get the value of rs1 and rs2 register from register file
                    rf_rd_sel2 <= rs2;
                    alu_a <= rf_rd1;
                    if opcode = "0010011" then          -- get immediate if i type here
                        alu_b <= imm;
                    elsif opcode = "0110011" then       -- else r2 to alu
                        alu_b <= rf_rd2;
                    end if;
                    rf_wr_en <= '1';
                    rf_rw_sel <= rd;
                    rf_data_in <= alu_output;
                    case f3 is
                        when "000" =>
                            if opcode = "0110011" then 
                                if f7 = "0100000" then
                                    alu_op <= "0001";           -- SUB
                                elsif f7 = "0000000" then
                                    alu_op <= "0000";           -- ADD
                                end if;
                            elsif opcode = "0010011" then
                                alu_op <= "0000";               -- ADD as i type does not have sub
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
                when others => 
                    pc_op <= "00";
            end case;
        elsif state = '1' then
            case opcode is 
                -- b type instructions
                when "1100011" =>                                   -- branch instructions
                    pc_op <= "00";                                  -- program counter should not change further in this stage
                -- j type instruction
                when "1101111" =>                                                   -- jal
                    alu_a <= std_logic_vector(resize(unsigned(pc_addr_in),32));     -- passes pc address and the imm to
                    alu_b <= x"00000004";                                           -- alu to increment the program counter by imm
                    alu_op <= "0000";                                               -- stores PC + im into PC
                    pc_op <= "10";
                    pc_addr_out <= alu_output(7 downto 0);
                    rf_wr_en <= '0';
                -- i type instructions
                when "1100111" =>                                                   -- jalr
                    rf_rd_sel1 <= rs1;
                    alu_a <= rf_rd1;                                            -- passes rs1 and the imm to
                    alu_b <= x"00000004";                                           -- alu for addition and the result is 
                    alu_op <= "0000";                                               -- stored into PC
                    pc_op <= "10";
                    pc_addr_out <= alu_output(7 downto 0);
                    rf_wr_en <= '0';
                when "0000011" =>               -- memory load instructions
                    rf_rw_sel <= rd;            -- to load the ram address value into rd
                    rf_wr_en <= '1';
                    ram_rd_en <= '0';
                    case f3 is
                        when "000" =>           -- lb
                            rf_data_in <= std_logic_vector(resize(signed(ram_data_out(7 downto 0)), 32));
                        when "001" =>           -- lh
                            rf_data_in <= std_logic_vector(resize(signed(ram_data_out(15 downto 0)), 32));
                        when "010" =>           -- lw
                            rf_data_in <= std_logic_vector(resize(signed(ram_data_out(31 downto 0)), 32));
                        when "100" =>           -- lbu
                            rf_data_in <= std_logic_vector(resize(unsigned(ram_data_out(7 downto 0)), 32));
                        when "101" =>           -- lhu
                            rf_data_in <= std_logic_vector(resize(unsigned(ram_data_out(15 downto 0)), 32));
                        when others =>
                            pc_op <= "00";
                    end case;
                when others => 
                    pc_op <= "00";
            end case;
        end if;
    end process;
end ctrl_unit_arch;