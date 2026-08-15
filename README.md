# APB FIFO, Elapsed-Time Timer & PWM FPGA Project

A Verilog-based FPGA project implementing a **FIFO, APB3-style bus interface, elapsed-time timer, PWM controller, button debouncing, and multiplexed 7-segment display**.

The project demonstrates how multiple hardware peripherals can be controlled through an APB-style communication interface while interacting with physical FPGA buttons, switches, LEDs, and a 7-segment display.

---

## Features

* 8-entry × 8-bit synchronous FIFO
* APB3-style master/slave communication
* FIFO write and read operations through APB
* Elapsed-time FIFO timer
* Timer starts when FIFO data is written
* Timer counts upward from `00`
* Timer stops when FIFO data is read
* FIFO data displayed after a read
* PWM peripheral
* Multiple PWM duty-cycle selections
* Push-button debouncing
* Button edge detection
* Four-digit 7-segment display
* LED status indicators
* Modular Verilog RTL design
* Suitable for FPGA implementation and simulation

---

## Project Objective

The main objective of this project is to demonstrate a small FPGA-based peripheral system connected through an **Advanced Peripheral Bus (APB)-style interface**.

The project combines:

```text
                    +----------------------+
                    |      FPGA BOARD      |
                    |                      |
Buttons ---------->| Button Controller    |
                    |                      |
Switches ---------->| Command Generator   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |      APB MASTER      |
                    +----------+-----------+
                               |
                         APB INTERCONNECT
                               |
                  +------------+------------+
                  |                         |
                  v                         v
          +---------------+         +---------------+
          | FIFO SLAVE    |         | PWM SLAVE     |
          |               |         |               |
          | 8 x 8 FIFO    |         | PWM Control   |
          +-------+-------+         +-------+-------+
                  |                         |
                  v                         v
             FIFO TIMER                 PWM OUTPUT
                  |
                  v
          7-Segment Display
```

---

# Hardware Demonstration

The FIFO portion of the project follows this sequence:

```text
Switches
   |
   | FIFO data
   v
BTNU
   |
   v
FIFO WRITE
   |
   +----> Timer starts at 00
             |
             v
       00 → 01 → 02 → 03 → ...
             |
             |
           BTNC
             |
             v
         FIFO READ
             |
             +----> Timer stops
             |
             +----> FIFO data displayed
```

### Example

Suppose the switches are configured to enter the value:

```text
5
```

Press **BTNU**.

The FIFO receives `5` and the timer starts:

```text
00
01
02
03
04
05
...
```

After several seconds, press **BTNC**.

The FIFO value is read and the timer stops.

The display then shows:

```text
0005
```

The important point is that the timer measures the elapsed time between the **FIFO write** and **FIFO read** operations.

---

# FIFO Operation

The FIFO is:

```text
Depth : 8
Width : 8 bits
```

Therefore it can store up to eight 8-bit values.

### FIFO write

The value on the input switches is written into the FIFO when **BTNU** is pressed.

```text
SW15:SW8
   |
   v
FIFO DATA IN
   |
  BTNU
   |
   v
WRITE
```

### FIFO read

Pressing **BTNC** performs a FIFO read.

```text
FIFO DATA OUT
      |
      v
    BTNC
      |
      v
    READ
      |
      v
7-Segment Display
```

---

# FIFO Timer

The FIFO timer is an elapsed-time counter.

### Start condition

A FIFO write starts the timer:

```verilog
start = fifo_write_cmd;
```

The timer is reset to:

```text
00
```

and begins counting upward.

### Stop condition

A FIFO read stops the timer:

```verilog
stop = fifo_read_cmd;
```

The timer therefore measures:

```text
FIFO READ TIME - FIFO WRITE TIME
```

---

# Timer Example

If the following sequence occurs:

```text
BTNU
   |
   +---- FIFO WRITE
   |
   +---- Timer = 00
             |
             | 1 second
             v
            01
             |
             | 1 second
             v
            02
             |
             | 1 second
             v
            03
             |
           BTNC
             |
             +---- FIFO READ
             |
             +---- Timer STOP
```

The timer value is approximately:

```text
03 seconds
```

The FIFO value is then displayed.

---

# APB Architecture

The project uses an APB-style architecture.

```text
             APB MASTER
                 |
                 |
       +---------+---------+
       |                   |
       v                   v
 FIFO APB SLAVE       PWM APB SLAVE
       |                   |
       v                   v
    FIFO                  PWM
```

The APB master generates:

```text
PSEL
PENABLE
PWRITE
PADDR
PWDATA
```

and receives:

```text
PRDATA
PREADY
PSLVERR
```

---

# Peripheral Address Map

The current design uses simple address decoding.

| Peripheral | Address |
| ---------- | ------: |
| FIFO       |  `0x20` |
| PWM        |  `0x30` |

These addresses can be changed in `apb3_decoder.v` and the command-generation logic.

---

# PWM Peripheral

The project also contains a PWM peripheral.

The PWM duty cycle is selected using the lower switch bits.

Example:

| `SW1:SW0` | Duty Cycle |
| --------- | ---------: |
| `00`      |        25% |
| `01`      |        50% |
| `10`      |        75% |
| `11`      |       100% |

Pressing **BTND** sends the PWM command through the APB interface.

The resulting PWM signal is available at:

```text
pwm_out
```

---

# Button Control

Three push buttons are used.

| Button | Function                 |
| ------ | ------------------------ |
| BTNU   | FIFO write / timer start |
| BTNC   | FIFO read / timer stop   |
| BTND   | PWM command              |

Buttons are passed through:

```text
Debounce
   ↓
Edge Detector
   ↓
One-clock command pulse
```

This prevents mechanical switch bounce from causing multiple operations.

---

# LED Indicators

The LEDs provide useful hardware debugging information.

| LED  | Meaning            |
| ---- | ------------------ |
| LED0 | FIFO timer running |
| LED1 | PWM timer running  |
| LED2 | FIFO full          |
| LED3 | FIFO empty         |
| LED4 | FIFO write command |
| LED5 | FIFO read command  |
| LED6 | PWM timer done     |
| LED7 | FIFO read command  |
| LED8 | PWM timer running  |
| LED9 | APB/master error   |

The exact LED assignment can be modified in `top.v`.

---

# 7-Segment Display

The four-digit 7-segment display is multiplexed.

During FIFO timing, the display shows the elapsed time:

```text
0000
0001
0002
0003
...
```

After a FIFO read, the display shows the FIFO value.

For example:

```text
FIFO value = 5
```

Display:

```text
0005
```

---

# RTL Modules

## `top.v`

Top-level integration module.

Connects:

* Buttons
* Switches
* LEDs
* 7-segment display
* APB master
* APB decoder
* FIFO
* Timer
* PWM

---

## `FIFO.v`

Implements the FIFO storage.

Configuration:

```text
Depth = 8
Width = 8 bits
```

Provides:

```text
wr_en
rd_en
data_in
data_out
full
empty
```

---

## `fifo_timer.v`

Implements the elapsed-time timer.

Behavior:

```text
start
  ↓
reset timer
  ↓
count upward
  ↓
stop
```

The timer is intended to measure the interval between FIFO write and FIFO read operations.

---

## `apb3_master.v`

Generates APB transactions.

Controls:

```text
PSEL
PENABLE
PWRITE
PADDR
PWDATA
```

and receives:

```text
PRDATA
PREADY
PSLVERR
```

---

## `apb3_decoder.v`

Decodes the APB address and selects the appropriate peripheral.

---

## `apb_fifo_slave.v`

Connects the FIFO to the APB interface.

It converts APB transactions into:

```text
FIFO WRITE
FIFO READ
```

operations.

---

## `pwm_timer.v`

Provides timing support for the PWM peripheral.

---

## `pwm_slave.v`

APB-connected PWM peripheral.

---

## `debounce.v`

Filters mechanical push-button bounce.

---

## `edge_detector.v`

Converts a button press into a one-clock-cycle pulse.

---

## `display_mux.v`

Multiplexes the four-digit 7-segment display.

---

## `hex_to_7seg.v`

Converts hexadecimal digit values to 7-segment patterns.

---

# Repository Structure

```text
apb-fifo-timer-pwm/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── rtl/
│   ├── top.v
│   ├── FIFO.v
│   ├── fifo_timer.v
│   ├── apb3_master.v
│   ├── apb3_decoder.v
│   ├── apb_fifo_slave.v
│   ├── pwm_timer.v
│   ├── pwm_slave.v
│   ├── debounce.v
│   ├── edge_detector.v
│   ├── display_mux.v
│   └── hex_to_7seg.v
│
├── constraints/
│   └── top.xdc
│
├── sim/
│   ├── tb_fifo.v
│   ├── tb_fifo_timer.v
│   ├── tb_apb.v
│   └── tb_top.v
│
├── docs/
│   ├── architecture.md
│   ├── fifo.md
│   ├── apb.md
│   ├── timer.md
│   └── pwm.md
│
└── images/
    ├── block_diagram.png
    ├── simulation.png
    └── hardware_demo.png
```

---

# Simulation

The RTL can be simulated using a Verilog/SystemVerilog simulator such as:

* Xilinx Vivado Simulator
* Icarus Verilog
* Verilator
* ModelSim/Questa

Recommended simulation order:

```text
1. FIFO
2. Timer
3. APB
4. PWM
5. Top-level integration
```

---

# Vivado Setup

1. Create a new Vivado RTL project.
2. Add all files from `rtl/`.
3. Add the appropriate `.xdc` constraint file.
4. Select the target FPGA board/device.
5. Set `top.v` as the top module.
6. Run synthesis.
7. Run implementation.
8. Generate the bitstream.
9. Program the FPGA.
10. Test the buttons, switches, LEDs, and display.

---

# Hardware Requirements

The design assumes an FPGA development board providing:

* FPGA fabric
* 100 MHz system clock
* Three push buttons
* 16 or more switches
* Four-digit 7-segment display
* At least 10 LEDs

The RTL is written generically, but the `.xdc` file must be modified for the specific FPGA board being used.

---

# Clock

The timer currently assumes:

```text
Clock frequency = 100 MHz
```

The timer therefore uses:

```verilog
parameter CLK_FREQ = 100_000_000;
```

If a different clock frequency is used, update the parameter accordingly.

For example:

```text
50 MHz  → 50_000_000
100 MHz → 100_000_000
125 MHz → 125_000_000
```

---

# Important Design Notes

## FIFO timer relationship

The timer is intentionally controlled by FIFO commands:

```text
FIFO WRITE → TIMER START

FIFO READ  → TIMER STOP
```

This makes the timer an elapsed-time measurement between FIFO operations.

---

## FIFO full condition

A write is ignored when:

```text
FIFO FULL = 1
```

---

## FIFO empty condition

A read is ignored when:

```text
FIFO EMPTY = 1
```

---

## Timer range

The current timer implementation displays:

```text
00 to 99 seconds
```

After reaching `99`, the timer remains at `99`.

The timer can easily be extended to a larger range if required.

---

# Future Improvements

Possible extensions include:

* Increase FIFO depth
* Increase FIFO data width
* Add FIFO occupancy display
* Add programmable timer resolution
* Add milliseconds instead of seconds
* Add timer overflow indication
* Add APB register map
* Add interrupt support
* Add UART output
* Add AXI/APB bridge
* Add SystemVerilog assertions
* Add automated simulation tests
* Add formal verification
* Add configurable PWM frequency
* Add programmable PWM duty cycle
* Add FIFO write/read counters
* Add error/status registers

---

# Learning Objectives

This project demonstrates several important RTL and FPGA concepts:

* Synchronous FIFO design
* APB-style peripheral communication
* Memory-mapped peripherals
* FSM-based bus transactions
* Clock-cycle timing
* Button debouncing
* Edge detection
* Timer design
* PWM generation
* 7-segment multiplexing
* Hardware/software-style peripheral architecture
* FPGA synthesis and implementation

---

# Author

**Your Name**
JIYA MULLA
