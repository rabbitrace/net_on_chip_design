library verilog;
use verilog.vl_types.all;
entity issp is
    port(
        probe           : in     vl_logic;
        source          : out    vl_logic_vector(7 downto 0)
    );
end issp;
