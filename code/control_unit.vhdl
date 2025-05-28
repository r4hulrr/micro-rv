library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_unit is 
    port(
        clk: in std_logic;
        opcode: in std_logic_vector(6 downto 0);
        rs1,rs2,rd: in std_logic_vector(4 downto 0);
        f3: in std_logic_vector(2 downto 0);
        f7: in std_logic_vector(6 downto 0);
        imm: in std_logic_vector(31 downto 0);
        alu_op: out std_logic_vector (3 downto 0);
        alu_a, alu_b: out std_logic_vector(31 downto 0)		-- alu operands
    );
end ctrl_unit;

architecture ctrl_unit_arch of ctrl_unit is
    -- signals for the register file
    signal rf_wr_en: std_logic;										            -- clk, write enable signals
    signal rf_rd_sel1, rf_rd_sel2, rf_rw_sel: std_logic_vector (4 downto 0);	-- to choose which of the 32 registers to read/write to 
    signal rf_data_in: std_logic_vector (31 downto 0);						    -- data in from memory if writing to register
    signal rf_rd1, rf_rd2: std_logic_vector (31 downto 0);					    -- data out from selected registers

    -- signals for the program counter
    signal pc_op: std_logic;
    signal pc_addr_in: std_logic_vector(7 downto 0); 
    signal pc_addr: std_logic_vector(7 downto 0);
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
    
    -- instantiate the program counter
    program_counter: entity work.pc(pc_arch)
        port map(
            clk=>clk,
            pc_op=>pc_op,
            addr_in=>pc_addr_in,
            addr=>pc_addr
        );
    
    -- process for jump instructions
    jump_decode: process (opcode,rs1,rs2,rd,f3,f7,imm)
    begin 
        if opcode = "1101111" then      -- jal
            alu_a <= pc_addr;           -- passes pc address and the value of 4 to
            alu_b <= "0x0004";          -- alu to increment the program counter by a word
            alu_op <= "0000";
        elsif opcode = "1100111" then   -- jalr
            alu_a <= pc_addr;           -- passes pc address and the value of 4 to
            alu_b <= "0x0004";          -- alu to increment the program counter by a word
            alu_op <= "0000";
            rf_rd_sel1 <= rs1;          -- gets the value in rs1 as this needs to be added to immediate later 
        end if;
    end process jump_decode;

    -- process for branch instructions
    branch_decode: process (opcode,rs1,rs2,rd,f3,f7,imm)
    begin   
        if opcode = "1100011" then      
            rf_rd_sel1 <= rs1;          -- gets the value of the two registers to compare
            rf_rd_sel2 <= rs2;
        end if;
    end process branch_decode;

    -- process for memory store and load instructions
    mem_decode: process (opcode,rs1,rs2,rd,f3,f7,imm)
    begin
        if opcode = "0000011" or opcode = "0100011" then  
            alu_op <= "0000";           -- add as the value in rs1 should be added to immediate
            rf_rd_sel1 <= rs1;          -- to get the value of rs1 register from register file
        end if;
    end process mem_decode;

    -- process for register-register instructions and register-immediate instructions 
    alu_decode: process(opcode,rs1,rs2,rd,f3,f7,imm)
    begin
        if opcode = "0110011" or opcode = "0010011" then
            rf_rd_sel1 <= rs1;          -- to get the value of rs1 register from register file
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
        end if;
    end process alu_decode;
end ctrl_unit_arch;