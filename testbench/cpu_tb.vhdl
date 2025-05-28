library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end entity;

architecture testbench of cpu_tb is

    -- Clock signal
    signal clk : std_logic := '0';

    -- Instantiate the cpu
    component cpu
        port (
            clk : in std_logic
        );
    end component;

begin

    -- Clock generation process: 10ns period = 100 MHz
    clock_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Instantiate CPU
    uut: cpu
        port map (
            clk => clk
        );

end architecture;
