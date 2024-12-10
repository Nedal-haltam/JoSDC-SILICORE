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


create_clock -name {input_clk} -period 12.05 -waveform { 0.000 7.05 } [get_ports {input_clk}]
# 82.99 => 83.13, 0.081

#create_clock -name {input_clk} -period 12.1 -waveform { 0.000 7.1 } [get_ports {input_clk}]
# 82.64 => 83.14, 0.030

#create_clock -name {input_clk} -period 12.151 -waveform { 0.000 7.150 } [get_ports {input_clk}]
# 82.3 => 83.65, 0.081



# these are with relatively good slack

#create_clock -name {input_clk} -period 12.451 -waveform { 0.000 7.45 } [get_ports {input_clk}]
# 80. => 82. , 0.19