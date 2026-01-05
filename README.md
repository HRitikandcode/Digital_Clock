# Digital_Clock
Verilog 12-Hour Digital Clock with Edit &amp; Stop Modes A synthesizable RTL implementation of a digital clock featuring an FSM-controlled logic for Running, Editing, and Stopping. Includes a parameterized clock divider and a testbench for verification.

# Verilog Digital Clock with FSM Control
This project is a synthesizable 12-hour digital clock implemented in Verilog. Unlike a simple counter, this design uses a Finite State Machine (FSM) to handle different modes of operation, allowing the user to pause the time or manually set (edit) the clock values.

# Key Features
Parameterized Frequency: The CLK_FRQ parameter allows the design to be adapted to any FPGA board oscillator (defaults to 100MHz).

State-Driven Logic: Dedicated states for Idle, Run, Edit, and Stop.

Precise Rollover: Logic handles the transitions from 59 seconds to minutes, and 59 minutes to hours accurately.

Synchronous Design: Uses non-blocking assignments and synchronous resets to ensure reliable hardware synthesis.

# Block-by-Block Explanation
## 1. Port Definitions & Parameters
The module uses a parameter CLK_FRQ to define how many clock cycles equal one second.

Inputs: Includes standard control signals like start, stop, and edit, along with 5 or 6-bit buses (e_sec, e_min, e_hour) to load external data into the clock.

Outputs: Provides the current time registers and three status flags (idle_mode, run_mode, edit_mode) to drive external LEDs or display logic.

### 2. State Machine (FSM)
The core of the design is the state register. I used a 2-bit state encoding to manage four distinct behaviors:

-> idle_state: The reset/default state. The system waits for a start or edit command.

-> run_state: The active counting state. The internal count register increments on every clk edge until it reaches the CLK_FRQ threshold, at which point it triggers the second increment.

->edit_state: An asynchronous-style load state. While in this state, the time registers (hour, minute, second) directly follow the input pins (e_hour, etc.), allowing for instant time setting.

-> stop_state: Effectively a "Pause." The clock stops incrementing and holds its current values until the start signal moves it back to the Run state.

## 3. Time Management Logic
Nested within the run_state, the rollover logic follows the hierarchy of time:

Clock Divider: Compares the count register against the CLK_FRQ. This is the "heartbeat" of the clock.

Second/Minute Counters: When the divider resets, second increments. If second == 59, it resets to 0 and carries over to the minute.

Hour Counter: Optimized for a 12-hour format. When minute reaches 59 and second reaches 59, the hour increments. If hour reaches 12, it wraps back to 1.

## 4. Continuous Assignments (Status Flags)
Instead of assigning the mode outputs inside the always block (which can cause latches or timing issues), the status flags are driven by assign statements. This ensures that as soon as the state changes, the corresponding _mode output updates instantly.

## Simulation & Verification
The provided testbench (Clock_tb.v) is designed for fast verification.

Parameter Overriding: The CLK_FRQ is overridden to 10 in the testbench. Without this, you would have to simulate 100,000,000 cycles just to see the second register change.

Test Sequence: The testbench sets the time to 12:59:55 via the Edit mode, enters Run mode, and observes the double-rollover into a new hour.

<img width="1920" height="1080" alt="Screenshot (1798)" src="https://github.com/user-attachments/assets/099a2d9e-d78e-4f0c-9c36-f0373e99bc71" />

