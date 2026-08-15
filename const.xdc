# ============================================================

# Nexys A7-100T

# APB FIFO + Elapsed Timer + PWM Project

#

# Top-level ports:

#

# clk

# rst

# btnU

# btnC

# btnD

# sw[15:0]

# led[9:0]

# an[3:0]

# seg[6:0]

# pwm_out

#

# ============================================================

# ============================================================

# 100 MHz SYSTEM CLOCK

# ============================================================

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]

create_clock -add -name sys_clk_pin 
-period 10.00 
-waveform {0 5} 
[get_ports clk]

# ============================================================

# PUSH BUTTONS

# ============================================================

# BTNC = FIFO READ / TIMER STOP

set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports btnC]

# BTNU = FIFO WRITE / TIMER START

set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports btnU]

# BTND = PWM

set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports btnD]

# BTNR = RESET

set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports rst]

# ============================================================

# SWITCHES

#

# SW15:SW8 = FIFO DATA

# SW1:SW0  = PWM DUTY

#

# ============================================================

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]

set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]

# SW8 and SW9 are 1.8 V I/O on Nexys A7

set_property -dict {PACKAGE_PIN T8 IOSTANDARD LVCMOS18} [get_ports {sw[8]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS18} [get_ports {sw[9]}]

set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {sw[10]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {sw[11]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {sw[12]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {sw[13]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {sw[14]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {sw[15]}]

# ============================================================

# LEDS

#

# LED0 = FIFO timer running

# LED1 = PWM timer running

# LED2 = FIFO full

# LED3 = FIFO empty

# LED4 = FIFO write command

# LED5 = FIFO read command

# LED6 = PWM timer done

# LED7 = FIFO read indication

# LED8 = PWM running

# LED9 = APB error

#

# ============================================================

set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {led[8]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {led[9]}]

# ============================================================

# 7-SEGMENT DISPLAY

#

# seg[0] = A

# seg[1] = B

# seg[2] = C

# seg[3] = D

# seg[4] = E

# seg[5] = F

# seg[6] = G

#

# ============================================================

set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {seg[6]}]

# ============================================================

# 7-SEGMENT DIGIT ENABLES

#

# an[0] = rightmost digit

# an[1]

# an[2]

# an[3] = leftmost digit

#

# ============================================================

set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {an[0]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {an[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {an[2]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {an[3]}]

# ============================================================

# PWM OUTPUT

#

# PWM is routed to Pmod JA pin 1.

#

# Connect an oscilloscope / logic analyzer / external circuit

# to the corresponding Pmod JA pin if required.

#

# ============================================================

set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports pwm_out]

# ============================================================

# OPTIONAL: DRIVE STRENGTH / SLEW

# ============================================================

set_property DRIVE 12 [get_ports pwm_out]
set_property SLEW SLOW [get_ports pwm_out]
