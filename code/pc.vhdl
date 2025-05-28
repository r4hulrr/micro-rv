library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
    port(
        clk, reset: in std_logic;
        pc_op: in std_logic_vector(1 downto 0);            
        addr_in: in std_logic_vector(7 downto 0); 
        addr: out std_logic_vector(7 downto 0)
    );
end pc;

architecture pc_arch of pc is
    signal pc_addr: std_logic_vector(7 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pc_addr <= x"00";
        elsif rising_edge(clk) then
            if pc_op = "01" then
                pc_addr <= std_logic_vector(unsigned(pc_addr)+1);
            elsif pc_op = "10" then
                pc_addr <= addr_in;
            end if;
        end if;
    end process;
    addr <= pc_addr;
end pc_arch;