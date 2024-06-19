create_clock -name CLKINTOP_125_P -period 8.000 [get_ports {clk}]
derive_pll_clocks 
derive_clock_uncertainty


set_false_path -from [get_ports {signal_in}]

set_false_path -from detect_signal:detect_signal_inst|* -to memory:memory_inst|*
set_false_path -from detect_signal:detect_signal_inst|* -to memory:memory_inst|*