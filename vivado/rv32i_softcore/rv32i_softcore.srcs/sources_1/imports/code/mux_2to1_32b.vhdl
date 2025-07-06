library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2to1_32b is
    port(
        mux_select : in std_logic;
        data_a     : in std_logic_vector(31 downto 0);
        data_b     : in std_logic_vector(31 downto 0);
        data_y     : out std_logic_vector(31 downto 0)
    );
end mux_2to1_32b;

architecture mux_2to1_32b_arch of mux_2to1_32b is
    component mux_2to1_1b is
        port(
            mux_select : in std_logic;
            data_a     : in std_logic;
            data_b     : in std_logic;
            data_y     : out std_logic
        );
    end component;
begin
    muxes: for i in 31 downto 0 generate
        bit_mux: mux_2to1_1b
        port map (
            mux_select => mux_select,
            data_a     => data_a(i),
            data_b     => data_b(i),
            data_y     => data_y(i)
        );
    end generate muxes;
end mux_2to1_32b_arch;
