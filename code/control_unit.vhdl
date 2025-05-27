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
        ram_addr: out std_logic_vector(9 downto 0)		-- address in ram to read/write
    );
end ctrl_unit;

architecture ctrl_unit_arch of ctrl_unit is
begin
    register_file: entity work.reg_file(reg_file_arch)
        port map(clk=>clk,wr_en=>alu_wr_en)
    -- process to decode the address to input to 
    mem_decode: process (opcode,rs1,rs2,rd,f3,f7,imm)
    begin
        if opcode = "0000011" then
            case f3 is 
                when "000" =>
                    
            end case;
        end if;
    end process mem_decode;
    -- process to decode the alu opcode required as input to the alu
    alu_decode: process(opcode,rs1,rs2,rd,f3,f7,imm)
    begin
        if opcode = "0110011" or opcode = "0010011" then
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