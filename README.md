# 🔢 Sequence Detector FSM — 1100

A Verilog implementation of a **finite state machine (FSM) based sequence detector** for detecting the binary sequence **`1100`**.
This project includes both **Mealy** and **Moore** FSM implementations along with a common testbench for simulation and waveform analysis.

---

## 📌 Project Overview

The objective of this project is to design and simulate a sequential circuit that detects the bit pattern:

```text
1100
```

Whenever the complete sequence is detected, the output `out` becomes `1`.

Two FSM architectures are implemented:

* **Mealy FSM** — output depends on the **present state and current input**
* **Moore FSM** — output depends only on the **present state**

The detector supports **continuous input streams** and is designed to work with overlapping sequence detection where applicable.

---

## 🧠 FSM Concept

The detector keeps track of how much of the target sequence `1100` has been matched so far.

### State Meaning

| State | Meaning                          |
| ----- | -------------------------------- |
| `S0`  | No bits of `1100` matched        |
| `S1`  | `1` matched                      |
| `S2`  | `11` matched                     |
| `S3`  | `110` matched                    |
| `S4`  | `1100` detected — **Moore only** |

The state transitions are based on the incoming bit.

---

# 🔵 Moore FSM

### File

```text
seqDetector_moore.v
```

In a Moore FSM, the output depends **only on the current state**.

```text
output = f(present_state)
```

The Moore implementation therefore uses an additional detection state:

```text
S4 = 1100 detected
```

### State Encoding

```verilog
S0 = 3'b000
S1 = 3'b001
S2 = 3'b010
S3 = 3'b011
S4 = 3'b100
```

Three flip-flops are required because five states are used.



The output is asserted while the FSM is in `S4`.

```verilog
always @(state) begin
    case (state)
        S4: out = 1;
        default: out = 0;
    endcase
end
```

### Important Characteristic

The output changes according to the **state**, so detection occurs after entering `S4`.

---

# 🟢 Mealy FSM

### File

```text
seqDetector_mealy.v
```

In a Mealy FSM, the output depends on both:

```text
output = f(present_state, input)
```

Therefore, an additional detection state is not required.

### State Encoding

```verilog
S0 = 2'b00
S1 = 2'b01
S2 = 2'b10
S3 = 2'b11
```

Only four states are required, so **two flip-flops** are sufficient.

### Mealy State Meaning

```text
S0 → Nothing matched
S1 → 1 matched
S2 → 11 matched
S3 → 110 matched
```

When the FSM is in `S3` and receives `0`:

```text
S3 + 0 → 1100 detected
```

and:

```verilog
out = 1;
```

The implementation evaluates the output on the falling edge of the clock:

```verilog
always @(negedge clk) begin
    case (state)
        S3: out = in ? 0 : 1;
        default: out = 0;
    endcase
end
```

This separates the output evaluation from the positive-edge state update used by the FSM.

---

# ⚖️ Mealy vs Moore

| Feature           | Mealy FSM                     | Moore FSM            |
| ----------------- | ----------------------------- | -------------------- |
| Output depends on | State + Input                 | State only           |
| States required   | 4                             | 5                    |
| Flip-flops        | 2                             | 3                    |
| Detection state   | Not required                  | Required             |
| Output response   | Can respond directly to input | Changes with state   |
| Design complexity | Lower state count             | Simpler output logic |
| Output timing     | Input/state dependent         | State dependent      |

### In this project

```text
Mealy  → 4 states → 2 flip-flops
Moore  → 5 states → 3 flip-flops
```

This demonstrates the main practical difference between the two FSM architectures.

---

# 🧪 Testbench

### File

```text
seqDetector_tb.v
```

The testbench supplies the following input sequence:

```text
0110011001011001001
```

The target sequence is:

```text
1100
```

The testbench:

1. Generates a clock with a **10 time-unit period**
2. Applies the clear/reset signal
3. Feeds the input bits sequentially
4. Displays the input and output
5. Generates a VCD waveform file
6. Ends the simulation automatically

### Clock

```verilog
clk = 1'b0;

forever #5 clk = ~clk;
```

Therefore:

```text
Clock period = 10 time units
```

---

# 📊 Expected Detection

For the input stream:

```text
0110011001011001001
```

the detector should assert `out` whenever the sequence:

```text
1100
```

is detected.

The waveform can be used to verify the relationship between:

```text
Input → State → Output
```

For the Moore FSM, the output becomes active when the detector reaches the `S4` detection state.

For the Mealy FSM, the output is asserted when the FSM is in `S3` (`110`) and the incoming bit is `0`.

---

# 📁 Project Structure

```text
my-alu-project/
├── rtl/
│   └── seqDetector_mealy.v      
│   └── seqDetector_moore.v       
├── tb/
│   └── alu_tb.v        
├── sim/        
└── README.md
```

### File Description

| File                  | Purpose                       |
| --------------------- | ----------------------------- |
| `seqDetector_mealy.v` | Mealy FSM implementation      |
| `seqDetector_moore.v` | Moore FSM implementation      |
| `seqDetector_tb.v`    | Simulation testbench          |
| `sim/`                | Contains simulation waveform  |
| `README.md`           | Project documentation         |

---

# 🛠️ Simulation

The design can be simulated using tools such as:

* **Icarus Verilog**
* **GTKWave**
* **ModelSim / Questa**
* Other Verilog-compatible simulators

### Using Icarus Verilog

Compile the design:

```bash
iverilog -o .\sim\simulation.vvp .\rtl\seqDetector_mealy.v .\tb\seqDetector_tb.v
```

Run:

```bash
vvp .\sim\simulation.vvp
```

For the Moore implementation:

```bash
iverilog -o .\sim\simulation.vvp .\rtl\seqDetector_moore.v .\tb\seqDetector_tb.v

vvp .\sim\simulation.vvp
```

The testbench generates:

```text
sim/waveform.vcd
```

which can be opened using GTKWave.

---

# 📈 Viewing the Waveform

Using GTKWave:

```bash
gtkwave sim/waveform.vcd
```

Useful signals to inspect are:

```text
clk
clear
in
out
DUT.state
DUT.next_state
```

For the Moore FSM, observing `state` is particularly useful because `S4` represents successful detection.

---


## ⭐ Summary

This project implements a binary **`1100` sequence detector** using both **Mealy and Moore FSM architectures**.

The key comparison is:

```text
             MEALY              MOORE
              │                   │
        4 states             5 states
              │                   │
       2 flip-flops          3 flip-flops
              │                   │
   Output = State + Input    Output = State
```

It provides a compact example of how the same digital system can be designed using two different FSM architectures and verified through Verilog simulation and waveform analysis.
