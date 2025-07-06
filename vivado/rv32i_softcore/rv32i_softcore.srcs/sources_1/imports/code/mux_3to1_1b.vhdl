library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_3to1_1b is
    port(
        mux_select : in std_logic_vector(1 downto 0);
        data_a     : in std_logic;
        data_b     : in std_logic;
        data_c     : in std_logic;
        data_y     : out std_logic
    );
end mux_3to1_1b;

architecture mux_3to1_1b_arch of mux_3to1_1b is
begin
    data_y <= data_a when mux_select = "00" else
              data_b when mux_select = "01" else
              data_c when mux_select = "10" else
              'X'; -- undefined
end mux_3to1_1b_arch;
