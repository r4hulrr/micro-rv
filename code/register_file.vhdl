library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
	port(
		clk, rd_en, wr_en: in std_logic_vector;			-- clk, read enable and write enable signals
		sel: in std_logic_vector (4 downto 0);			-- to choose which of the 32 registers to read/write to 
		data_in: in std_logic_vector (31 downto 0);		-- data from memory if writing to register
		data_out: out std_logic_vector (31 downto 0)	-- data from one particular register
	);
end reg_file;

architecture reg_file_arch of reg_file is
	type reg_file_type is array (31 downto 0) of std_logic_vector (31 downto 0);	-- 32 registers
	signal reg_file: reg_file_type;													-- each 32 bits wide
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if wr_en = '1' then
				reg_file(to_integer(unsigned(sel))) <= data_in;
			elsif rd_en = '1' then
				data_out <= reg_file(to_integer(unsigned(sel)));
			end if;
		end if;
	end process;
end reg_file_arch;