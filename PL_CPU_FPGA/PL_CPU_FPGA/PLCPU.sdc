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


 create_clock -name {input_clk} -period 15.9 -waveform { 0.000 9.76 } [get_ports {input_clk}]

 
# create_clock -name {input_clk} -period 16.676 -waveform { 0.000 9.846 } [get_ports {input_clk}]
# and this leads to a max clock of 62.62
# setup slack : +0.418
# hold  slack : +0.4..
 
 
# create_clock -name {input_clk} -period 15.5 -waveform { 0.000 9.5 } [get_ports {input_clk}]
# and this leads to a max clock of 63.78
# setup slack : -0.110
# hold  slack : +0.408


# create_clock -name {input_clk} -period 16.130 -waveform { 0.000 9.5 } [get_ports {input_clk}]
# and this leads to a max clock of 62.64
# setup slack : +0.098
# hold  slack : +0.409


# create_clock -name {input_clk} -period 16.000 -waveform { 0.000 9.63 } [get_ports {input_clk}]
# and this leads to a max clock of 64.15
# setup slack : +0.248
# hold  slack : +0.408





















