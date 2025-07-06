library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2to1_1b is
    port(
        mux_select : in std_logic;
        data_a     : in std_logic;
        data_b     : in std_logic;
        data_y     : out std_logic
    );
end mux_2to1_1b;

architecture mux_2to1_1b_arch of mux_2to1_1b is
begin
    data_y <= data_a when mux_select = '0' else
              data_b when mux_select = '1' else 
              'X'; -- undefined
end mux_2to1_1b_arch;
