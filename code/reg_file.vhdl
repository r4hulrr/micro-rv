library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
	port(
		i_clk		: in std_logic;							-- clk
		i_reset		: in std_logic;							-- reset
		i_wr_en		: in std_logic;							-- write enable
		i_rd_sel1	: in std_logic_vector (4 downto 0);		-- to choose which of the 32 registers to read/write to 
		i_rd_sel2	: in std_logic_vector (4 downto 0);
		i_wr_sel	: in std_logic_vector (4 downto 0);
		i_wr_data	: in std_logic_vector (31 downto 0);	-- data in from memory if writing to register
		o_rd1		: out std_logic_vector (31 downto 0);	-- data out from selected registers
		o_rd2		: out std_logic_vector (31 downto 0)
	);
end reg_file;

architecture reg_file_arch of reg_file is
	type reg_file_type is array (31 downto 0) of std_logic_vector (31 downto 0);	-- 32 registers
	signal reg_file: reg_file_type := (others => (others => '0'));													-- each 32 bits wide
begin
	variable var_regfile 	: reg_file_type;
	variable var_rd_sel1 	: integer;
	variable var_rd_sel2 	: integer;
	variable var_wr_sel		: integer;
	process(i_clk,
			i_reset,
			i_wr_en,
			i_rd_sel1,
			i_rd_sel2,
			i_wr_sel,
			i_wr_data)
	begin
		var_rd_sel1	:= to_integer(i_rd_sel1);
		var_rd_sel2	:= to_integer(i_rd_sel2);
		var_wr_sel	:= to_integer(i_wr_sel);
		if i_reset = '1' then
			var_regfile := (others => X"00000000");
		elsif falling_edge(i_clk) then
			if wr_en = '1' then
				var_reg_file(var_wr_sel) := i_wr_data;		-- multiplexer to select the register
			end if;
		end if;
		var_reg_file(0) := X"00000000";
		o_rd1 <= reg_file(var_rd_sel1);
		o_rd2 <= reg_file(var_rd_sel2);

		reg_file <= var_reg_file;
	end process;
end reg_file_arch;