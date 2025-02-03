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

create_clock -name {input_clk} -period 18.313 -waveform { 0.0 9.068 } [get_ports {input_clk}]


