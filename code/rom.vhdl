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
	type rom_type is array (10 downto 0) of std_logic_vector(31 downto 0);
	signal rom_array: rom_type := (
		0  => x"00500093",  -- addi x1, x0, 5
		1  => x"00A00113",  -- addi x2, x0, 10
		2  => x"002081B3",  -- add x3, x1, x2
		3  => x"00302023",  -- sw x3, 0(x0)
		4  => x"00002283",  -- lw x4, 0(x0)
		5  => x"0041A463",  -- beq x3, x4, 8
		6  => x"00100293",  -- addi x5, x0, 1
		7  => x"FF5FF06F",  -- jal x0, -8 (infinite loop)
		others => x"00000000"
	);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			data <= rom_array(to_integer(unsigned(addr)));
		end if;
	end process;
end rom_arch;