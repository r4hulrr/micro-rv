library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity alu is
	port(
		alu_op	: in std_logic_vector(3 downto 0);		-- ALU op code from control logic
		a,b		: in std_logic_vector(31 downto 0);		-- Operands
		d 		: out std_logic_vector(31 downto 0)		-- Output 32 bit value from ALU
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
	process(a,b,alu_op)
	begin
		case alu_op is
			when ALU_ADD =>
				d <= std_logic_vector(signed(a) + signed(b));
			when ALU_SUB =>
				d <= std_logic_vector(signed(a) - signed(b));
			when ALU_SHL =>
				d <= std_logic_vector(shift_left(unsigned(a),to_integer(unsigned(b))));
			when ALU_SLT =>
				if (signed(a)<signed(b)) then
					d <= (31 downto 1 => '0') & '1';
				else
					d <= (31 downto 0 => '0');
				end if;
			when ALU_SLTU =>
				if (unsigned(a)<unsigned(b)) then
					d <= (31 downto 1 => '0') & '1';
				else
					d <= (31 downto 0 => '0');
				end if;
			when ALU_XOR =>
				d <= a xor b;
			when ALU_SRL =>
				d <= std_logic_vector(shift_right(unsigned(a),to_integer(unsigned(b))));
			when ALU_SRA =>
				d <= std_logic_vector(shift_right(signed(a),to_integer(unsigned(b))));
			when ALU_OR =>
				d <= a or b;
			when ALU_AND =>
				d <= a and b; 
			when others =>
				d <= (31 downto 0 => '0'); 
		end case;
	end process;
end alu_arch;
