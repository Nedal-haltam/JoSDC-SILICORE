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

#set_time_format -unit ns -decimal_places 10


# create_clock -name {input_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {input_clk}]

create_clock -name {input_clk} -period 15.2 -waveform { 0.000 10.511 } [get_ports {input_clk}]




# create_clock -name {input_clk} -period 15.1 -waveform { 0.000 10.311 } [get_ports {input_clk}]
# Fmax = 66.35
# setup slack: +0.02



# create_clock -name {input_clk} -period 15.2 -waveform { 0.000 10.511 } [get_ports {input_clk}]
# Fmax = 67.63
# setup slack: +0.159



# create_clock -name {input_clk} -period 15.4 -waveform { 0.000 10.311 } [get_ports {input_clk}]
# Fmax = 66.93
# setup slack: +0.307

# create_clock -name {input_clk} -period 15.6 -waveform { 0.000 10.111 } [get_ports {input_clk}]
# Fmax = 65.33
# setup slack : +0.191
