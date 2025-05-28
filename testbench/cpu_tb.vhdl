library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end entity;

architecture testbench of cpu_tb is

    -- Clock signal
    signal clk,reset : std_logic := '0';

    -- Instantiate the cpu
    component cpu
        port (
            clk,reset : in std_logic
        );
    end component;

begin

    -- Clock generation process: 10ns period = 100 MHz
    clock_process : process
    begin
        reset <= '1';
        wait for 5 ns;
        reset <= '0';
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
            clk => clk,
            reset=>reset
        );

end architecture;
