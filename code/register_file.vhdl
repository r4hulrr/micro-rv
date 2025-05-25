library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
	port(
		clk, wr_en: in std_logic;										-- clk, write enable signals
		rd_sel1, rd_sel2, rw_sel: in std_logic_vector (4 downto 0);		-- to choose which of the 32 registers to read/write to 
		data_in: in std_logic_vector (31 downto 0);						-- data in from memory if writing to register
		rd1, rd2: out std_logic_vector (31 downto 0)					-- data out from selected registers
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
				reg_file(to_integer(unsigned(rw_sel))) <= data_in;		-- multiplexer to select the register
			end if;
		end if;
	end process;
	rd1 <= reg_file(to_integer(unsigned(rd_sel1)));
	rd2 <= reg_file(to_integer(unsigned(rd_sel2)));
end reg_file_arch;