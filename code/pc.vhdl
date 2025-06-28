library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
    port(
        i_clk, i_reset  : in std_logic;        
        i_addr          : in std_logic_vector(7 downto 0); 
        o_addr          : out std_logic_vector(7 downto 0)
    );
end pc;

architecture pc_arch of pc is
begin
    process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            o_addr <= (others => '0');
        elsif rising_edge(i_clk) then
            o_addr <= i_addr;
        end if;
    end process;
end pc_arch;