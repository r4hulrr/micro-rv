library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	port(
		clk,wr_en,rd_en: in std_logic;				-- clk, read enable and write enable
		addr: in std_logic_vector(9 downto 0);		-- address in ram to read/write
		data_in: in std_logic_vector(31 downto 0);	-- data to write to register
		data_out: out std_logic_vector(31 downto 0)	-- data read from register
	);
end ram;

architecture ram_arch of ram is
	type ram_type is array (1023 downto 0) of std_logic_vector(31 downto 0);	--4kB of RAM
	signal ram_array: ram_type;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rd_en = '1' then
				data_out <= ram_array(to_integer(unsigned(addr)));
			elsif wr_en = '1' then
				ram_array(to_integer(unsigned(addr))) <= data_in;
			end if;
		end if;
	end process;
end ram_arch;