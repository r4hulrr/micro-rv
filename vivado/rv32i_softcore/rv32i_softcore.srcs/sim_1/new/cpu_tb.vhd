library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end entity;

architecture sim of cpu_tb is
    signal i_clk   : std_logic := '0';
    signal i_reset : std_logic := '1';

    component cpu is
        port(
            i_clk   : in std_logic;
            i_reset : in std_logic
        );
    end component;

begin

    -- Instantiate the CPU
    uut: cpu
        port map(
            i_clk   => i_clk,
            i_reset => i_reset
        );

    -- Clock generation: 100ns period (10 MHz)
    clk_proc: process
    begin
        while true loop
            i_clk <= '0';
            wait for 50 ns;
            i_clk <= '1';
            wait for 50 ns;
        end loop;
    end process;

    -- Reset and simulation control
    stim_proc: process
    begin
        -- Hold reset high for 100 ns
        wait for 100 ns;
        i_reset <= '0';

        -- Let CPU run for some time
        wait for 2000 ns;

        -- End simulation
        assert false report "Simulation complete" severity failure;
    end process;

end architecture;
