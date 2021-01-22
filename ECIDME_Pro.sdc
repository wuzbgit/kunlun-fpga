## Generated SDC file "ECIDME_Pro.sdc"

## Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 15.0.0 Build 145 04/22/2015 SJ Full Version"

## DATE    "Sat May 30 10:43:22 2020"

##
## DEVICE  "10M08SAE144C8GES"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {CLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLK}]
#create_clock -name {I_CROSS_ZERO_FALLING} -period 1.000 -waveform { 0.000 0.500 } [get_registers {I_CROSS_ZERO_FALLING}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

#set_clock_uncertainty -rise_from [get_clocks {CLK}] -rise_to [get_clocks {CLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {CLK}] -fall_to [get_clocks {CLK}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {CLK}] -rise_to [get_clocks {I_CROSS_ZERO_FALLING}]  0.030  
#set_clock_uncertainty -rise_from [get_clocks {CLK}] -fall_to [get_clocks {I_CROSS_ZERO_FALLING}]  0.030  
#set_clock_uncertainty -fall_from [get_clocks {CLK}] -rise_to [get_clocks {CLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {CLK}] -fall_to [get_clocks {CLK}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {CLK}] -rise_to [get_clocks {I_CROSS_ZERO_FALLING}]  0.030  
#set_clock_uncertainty -fall_from [get_clocks {CLK}] -fall_to [get_clocks {I_CROSS_ZERO_FALLING}]  0.030  
#set_clock_uncertainty -rise_from [get_clocks {I_CROSS_ZERO_FALLING}] -rise_to [get_clocks {CLK}]  0.030  
#set_clock_uncertainty -rise_from [get_clocks {I_CROSS_ZERO_FALLING}] -fall_to [get_clocks {CLK}]  0.030  
#set_clock_uncertainty -fall_from [get_clocks {I_CROSS_ZERO_FALLING}] -rise_to [get_clocks {CLK}]  0.030  
#set_clock_uncertainty -fall_from [get_clocks {I_CROSS_ZERO_FALLING}] -fall_to [get_clocks {CLK}]  0.030  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

#set_false_path  -from  [get_clocks {I_CROSS_ZERO_FALLING}]  -to  [get_clocks {CLK}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

