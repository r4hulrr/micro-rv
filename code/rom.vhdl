library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
	port(
		i_clk, i_reset	: in std_logic;							-- clock
		i_addr			: in std_logic_vector(7 downto 0);		-- address of rom to read from
		o_ins			: out std_logic_vector(31 downto 0)		-- output data from rom
	);
end rom;

architecture rom_arch of rom is
	type mem_array is array (255 downto 0) of std_logic_vector(31 downto 0);
	signal sig_insn_mem: mem_array;
begin
	process(i_clk,i_reset,i_addr)
		variable var_mem	: mem_array;
		variable var_addr	: integer;
	begin
		if i_reset = '1' then
			var_mem(0) := x"00500093"; 	-- addi x1, x0, 5
			var_mem(1) := x"00A00113";	-- addi x2, x0, 10
			var_mem(2) := x"002081B3";	-- add x3, x1, x2
			var_mem(3) := x"00302023";	-- sw x3, 0(x0)
			var_mem(4) := x"00002283";	-- lw x4, 0(x0)
			var_mem(5) := x"0041A463";	-- beq x3, x4, 8
			var_mem(6) := x"00100293";	-- addi x5, x0, 1
			var_mem(7) := x"FF5FF06F";	-- jal x0, -8 (infinite loop)
		elsif rising_edge(clk) then
			var_addr	:= to_integer(i_addr);
			o_addr 		<= var_mem(var_addr);
		end if;
		sig_insn_mem <= var_mem;
	end process;
end rom_arch;