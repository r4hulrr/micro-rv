library ieee;
use ieee.std_logic_1164.all;
entity alu is
	port(
		opcode: in std_logic_vector(6 downto 0);
		a,b : in std_logic_vector(31 downto 0)
	);
end alu;

architecture alu_arch of alu is
begin

end alu_arch;
