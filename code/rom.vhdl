library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
	port(
		clk: in std_logic;							-- clock
		addr: in std_logic_vector(7 downto 0);		-- address of rom to read from
		data: out std_logic_vector(31 downto 0)		-- output data from rom
	);
end rom;

architecture rom_arch of rom is
	type rom_type is array (255 downto 0) of std_logic_vector(31 downto 0);
	signal rom_array: rom_type;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			data <= rom_array(to_integer(unsigned(addr)));
		end if;
	end process;
end rom_arch;