library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
	port (
		clk, rd_en, wr_en: in std_logic;				-- clk, read_enable, write_enable
		data_in: in std_logic_vector(31 downto 0);		-- data from RAM
		data_out: out std_logic_vector(31 downto 0)		-- data sent to control unit
	);
end reg;

architecture reg_arch of reg is
	signal reg_data: std_logic_vector(31 downto 0);		-- data held in register
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if wr_en = '1' then
				reg_data <= data_in;
			elsif rd_en = '1' then
				data_out <= reg_data;
			end if;
		end if;
	end process;
end reg_arch;
