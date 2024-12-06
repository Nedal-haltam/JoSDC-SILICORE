#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

# Create Clock
#create_clock -period "10.0 MHz" [get_ports ADC_CLK_10]
#create_clock -period "50.0 MHz" [get_ports MAX10_CLK1_50]
#create_clock -period "50.0 MHz" [get_ports MAX10_CLK2_50]
#
#derive_pll_clocks
#derive_clock_uncertainty

set_time_format -unit ns -decimal_places 10


# create_clock -name {input_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {input_clk}]

create_clock -name {input_clk} -period 15.45 -waveform { 0.000 10.7 } [get_ports {input_clk}]


#create_clock -name {input_clk} -period 15.9 -waveform { 0.000 11.3 } [get_ports {input_clk}]

