create_clock -name clkslt -period 280 [get_ports pSltClk]
create_clock -name clk50m -period 20 [get_ports pSltClk2]
derive_pll_clocks

set_false_path -from {pSltClk} -to {pSltClk_nt}
set_false_path -from {ADACDiv[7]} -to {SDAC}

# create_generated_clock -name clkdac -source [get_nets {U2|altpll_component|_clk0}] -divide_by 256 [get_nets {ADACDiv[7]}]
# create_generated_clock -name clksdac -source [get_nets {U2|altpll_component|_clk0}] -divide_by 256 [get_nets {SDAC}]
# set_false_path  -from  [get_clocks {U2|altpll_component|pll|clk[0]}]  -to  [get_clocks {clkslt}]
