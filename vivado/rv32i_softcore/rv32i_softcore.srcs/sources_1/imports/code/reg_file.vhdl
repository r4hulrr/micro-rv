library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
    port(
        i_clk      : in  std_logic;
        i_reset    : in  std_logic;
        i_wr_en    : in  std_logic;
        i_rd_sel1  : in  std_logic_vector(4 downto 0);
        i_rd_sel2  : in  std_logic_vector(4 downto 0);
        i_wr_sel   : in  std_logic_vector(4 downto 0);
        i_wr_data  : in  std_logic_vector(31 downto 0);
        o_rd1      : out std_logic_vector(31 downto 0);
        o_rd2      : out std_logic_vector(31 downto 0)
    );
end reg_file;

architecture reg_file_arch of reg_file is
    type reg_file_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_file : reg_file_type := (others => (others => '0'));
begin

    -- Write logic
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                reg_file <= (others => (others => '0'));
            elsif i_wr_en = '1' and i_wr_sel /= "00000" then
                reg_file(to_integer(unsigned(i_wr_sel))) <= i_wr_data;
            end if;
        end if;
    end process;

    -- Read logic
    process(i_rd_sel1, i_rd_sel2, reg_file)
    begin
        if i_rd_sel1 = "00000" then
            o_rd1 <= (others => '0');
        else
            o_rd1 <= reg_file(to_integer(unsigned(i_rd_sel1)));
        end if;

        if i_rd_sel2 = "00000" then
            o_rd2 <= (others => '0');
        else
            o_rd2 <= reg_file(to_integer(unsigned(i_rd_sel2)));
        end if;
    end process;

end reg_file_arch;
