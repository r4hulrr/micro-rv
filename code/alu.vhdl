library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity alu is
	port(
		i_alu_op	: in std_logic_vector(3 downto 0);		-- ALU op code from control logic
		i_a			: in std_logic_vector(31 downto 0);		-- Operands
		i_b			: in std_logic_vector(31 downto 0);
		o_d 		: out std_logic_vector(31 downto 0)		-- Output 32 bit value from ALU
	);
end alu;

architecture alu_arch of alu is
	constant ALU_ADD	: 	std_logic_vector(3 downto 0) := "0000";	-- add
	constant ALU_SUB	: 	std_logic_vector(3 downto 0) := "0001";	-- subtract
	constant ALU_SHL	: 	std_logic_vector(3 downto 0) := "0010";	-- shift-left
	constant ALU_SLT	: 	std_logic_vector(3 downto 0) := "0011"; -- set less than
	constant ALU_SLTU	: 	std_logic_vector(3 downto 0) := "0100"; -- set less than unsigned
	constant ALU_XOR	: 	std_logic_vector(3 downto 0) := "0101";	-- xor
	constant ALU_SRL	: 	std_logic_vector(3 downto 0) := "0110";	-- shift-right (logical)
	constant ALU_SRA	: 	std_logic_vector(3 downto 0) := "0111"; -- shift-right (arithmetic)
	constant ALU_OR		: 	std_logic_vector(3 downto 0) := "1000"; -- or
	constant ALU_AND	: 	std_logic_vector(3 downto 0) := "1001"; -- and
begin
	process(i_a,i_b,i_alu_op)
	begin
		case i_alu_op is
			when ALU_ADD =>
				o_d <= std_logic_vector(signed(i_a) + signed(i_b));
			when ALU_SUB =>
				o_d <= std_logic_vector(signed(i_a) - signed(i_b));
			when ALU_SHL =>
				o_d <= std_logic_vector(shift_left(unsigned(i_a),to_integer(unsigned(i_b))));
			when ALU_SLT =>
				if (signed(i_a)<signed(i_b)) then
					o_d <= (31 downto 1 => '0') & '1';
				else
					o_d <= (31 downto 0 => '0');
				end if;
			when ALU_SLTU =>
				if (unsigned(i_a)<unsigned(i_b)) then
					o_d <= (31 downto 1 => '0') & '1';
				else
					o_d <= (31 downto 0 => '0');
				end if;
			when ALU_XOR =>
				o_d <= i_a xor i_b;
			when ALU_SRL =>
				o_d <= std_logic_vector(shift_right(unsigned(i_a),to_integer(unsigned(i_b))));
			when ALU_SRA =>
				o_d <= std_logic_vector(shift_right(signed(i_a),to_integer(unsigned(i_b))));
			when ALU_OR =>
				o_d <= i_a or i_b;
			when ALU_AND =>
				o_d <= i_a and i_b; 
			when others =>
				o_d <= (31 downto 0 => '0'); 
		end case;
	end process;
end alu_arch;
