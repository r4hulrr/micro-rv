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
	with alu_op select
		d <= a + b						when "0000",	-- add
			a - b 						when "0001",	-- subtract
			shift_left(unsigned(a),b) 	when "0010",	-- shift left
			a xor b 					when "0101",	-- xor
			shift_right(unsigned(a),b)	when "0110",	-- shift-right (logical)
			shift_right(signed(a),b)	when "0111",	-- shift-right (arithmetic)
			a or b						when "1000",	-- or
			a and b						when "1001",	-- and
			"0"							when others;
end alu_arch;
