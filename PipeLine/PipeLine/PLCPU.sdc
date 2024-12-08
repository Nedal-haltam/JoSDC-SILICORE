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

create_clock -name {input_clk} -period 12.38 -waveform { 0.000 7.215 } [get_ports {input_clk}]



# create_clock -name {input_clk} -period 12.38 -waveform { 0.000 7.215 } [get_ports {input_clk}]
# clk = 80.78
# Fmax = 80.91
# 0.009
# 0.404

# create_clock -name {input_clk} -period 12.603 -waveform { 0.000 7.215 } [get_ports {input_clk}]
# clk = 79.35
# Fmax = 80.78
# 0.096
# 0.403


