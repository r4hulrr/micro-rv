library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	port(
		i_clk	: in std_logic;				-- clk, reset and write enable
		i_reset	: in std_logic;
		i_wr_en	: in std_logic;
		i_addr	: in std_logic_vector(9 downto 0);		-- address in ram to read/write
		i_data	: in std_logic_vector(31 downto 0);	-- data to write to register
		o_data	: out std_logic_vector(31 downto 0)	-- data read from register
	);
end ram;

architecture ram_arch of ram is
	type ram_type is array (1023 downto 0) of std_logic_vector(31 downto 0);	--4kB of RAM
	signal sig_ram_array: ram_type;
begin
	process(i_clk, 
			i_reset,
			i_wr_en,
			i_addr,
			i_wr_en) 
		variable var_ram_array	: ram_type;
		variable var_ram_addr	: integer;
	begin
		variable var_ram_addr := to_integer(i_addr);
		if i_reset = '1' then
			var_ram_array => (others => (others=> "0"));
		elsif falling_edge(i_clk) then
			if wr_en = '1' then
				var_ram_array(var_ram_addr) := i_data;
			end if;
		end if;
		o_data <= var_ram_array(var_ram_addr);

		sig_ram_array <= var_ram_array;
	end process;
end ram_arch;