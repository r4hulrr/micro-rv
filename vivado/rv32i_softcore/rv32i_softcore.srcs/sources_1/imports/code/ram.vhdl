library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	port(
		i_clk   : in  std_logic;
		i_reset : in  std_logic;
		i_wr_en : in  std_logic;
		i_addr  : in  std_logic_vector(9 downto 0);  -- 10-bit address for 1K words
		i_data  : in  std_logic_vector(31 downto 0);
		o_data  : out std_logic_vector(31 downto 0)
	);
end ram;

architecture ram_arch of ram is
	type ram_type is array (0 to 1023) of std_logic_vector(31 downto 0);  -- 1K words = 4KB
	signal sig_ram_array : ram_type := (others => (others => '0'));
	signal sig_read_addr : integer range 0 to 1023;
begin
	process(i_clk)
	begin
		if rising_edge(i_clk) then
			sig_read_addr <= to_integer(unsigned(i_addr));
			if i_wr_en = '1' then
				sig_ram_array(to_integer(unsigned(i_addr))) <= i_data;
			end if;
		end if;
	end process;

	o_data <= sig_ram_array(sig_read_addr);

end ram_arch;
