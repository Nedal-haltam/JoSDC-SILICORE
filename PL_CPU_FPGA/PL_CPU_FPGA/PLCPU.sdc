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


 create_clock -name {input_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {input_clk}]

# create_clock -name {input_clk} -period 15.8 -waveform { 0.000 9.9 } [get_ports {input_clk}]
# and this leads to a max clock of 64.23
# setup slack : +0.145
# hold  slack : +0.407


# create_clock -name {input_clk} -period 15.9 -waveform { 0.000 9.76 } [get_ports {input_clk}]
# and this leads to a max clock of 64.42
# setup slack : +0.231
# hold  slack : +0.407


# create_clock -name {input_clk} -period 15.5 -waveform { 0.000 10.111 } [get_ports {input_clk}]
# and this leads to a max clock of 64.57
# setup slack : +0.008
# hold  slack : +0.409


# create_clock -name {input_clk} -period 15.6 -waveform { 0.000 10.111 } [get_ports {input_clk}]
# and this leads to a max clock of 65.33
# setup slack : +0.191
# hold  slack : +0.407

















