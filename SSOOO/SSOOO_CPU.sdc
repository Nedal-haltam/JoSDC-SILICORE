#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
#create_clock -period "10.0 MHz" [get_ports ADC_CLK_10]
#create_clock -period "50.0 MHz" [get_ports MAX10_CLK1_50]
#create_clock -period "50.0 MHz" [get_ports MAX10_CLK2_50]

#**************************************************************
# Create Generated Clock
#**************************************************************
#derive_pll_clocks
#derive_clock_uncertainty


set_time_format -unit ns -decimal_places 3

create_clock -name {input_clk} -period 15.9 -waveform { 0.0 8.7 } [get_ports {input_clk}]



set_clock_uncertainty -rise_from [get_clocks {input_clk}] -rise_to [get_clocks {input_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {input_clk}] -fall_to [get_clocks {input_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {input_clk}] -rise_to [get_clocks {input_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {input_clk}] -fall_to [get_clocks {input_clk}]  0.020  

