# Weight-Stationary Systolic Array (2×2 MAC Array)

A 2×2 weight-stationary systolic array of multiply-accumulate processing elements, written in SystemVerilog and verified in simulation. The dataflow follows the Google TPU v1 architecture: weights are loaded once and held in place, activations stream through, and partial sums accumulate as they move across the array.

**Status:** functionally verified in simulation (Icarus Verilog + GTKWave). Not synthesized, not taped out. See [Limitations](#limitations).

---

## Why a systolic array

A naive matrix multiplier fetches operands from memory for every multiply. At scale that makes memory bandwidth — not arithmetic — the bottleneck.

A systolic array removes most of those fetches. Each processing element passes its operands directly to its neighbors, so a value read from memory once is reused across an entire row or column of PEs. The array becomes a fixed pipeline that data flows through rather than a unit that data is repeatedly fetched into.

This design uses the **weight-stationary** variant: each PE holds one weight for the duration of a matrix multiply. Activations move upward through columns; partial sums move rightward along rows, accumulating one product at each PE. By the time a partial sum exits the right edge, it is a complete dot product.

## Architecture

```
                           psum_out[0]        psum_out[1]
                                ▲                  ▲
                                │                  │
                         ┌──────┴──────┐    ┌──────┴──────┐
        psum_in = 0 ────▶│    PE00     │───▶│    PE01     │───▶ result row 0
                         │   w = w00   │    │   w = w01   │
                         └──────▲──────┘    └──────▲──────┘
                                │                  │
                         ┌──────┴──────┐    ┌──────┴──────┐
        psum_in = 0 ────▶│    PE10     │───▶│    PE11     │───▶ result row 1
                         │   w = w10   │    │   w = w11   │
                         └──────▲──────┘    └──────▲──────┘
                                │                  │
                            a_col[0]           a_col[1]
                          (activations enter from below)
```

Each PE performs one operation per clock:

```
psum_out <= psum_in + (weight * activation_in)
act_out  <= activation_in          // forwarded to the PE above
```

Because every PE registers its outputs, the array is fully pipelined — one multiply-accumulate per PE per cycle, with results emerging after a fixed latency determined by the array dimensions.

> **Verify before publishing:** the port names above are illustrative. Replace them with the actual signal names from `mac.v` and `systolic_2x2.v`, and state the real operand and accumulator widths.

## Repository layout

```
rtl/
  mac.v               # single multiply-accumulate processing element
  systolic_2x2.v      # 2×2 array, instantiates four MAC PEs
tb/
  macTB.v             # unit testbench for one PE
  systolic_2x2TB.v    # array-level testbench
docs/
  waveform.png        # GTKWave capture of a verified multiply
```

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `DATA_WIDTH` | *(fill in)* | Operand width for weights and activations |
| `ACC_WIDTH` | *(fill in)* | Accumulator width; sized to avoid overflow across the accumulation chain |

The PE is parameterized on operand width and instantiated identically at all four array positions.

## Running the testbenches

```bash
# Single processing element
iverilog -g2012 -o mac_sim rtl/mac.v tb/macTB.v
vvp mac_sim

# Full 2×2 array
iverilog -g2012 -o array_sim rtl/mac.v rtl/systolic_2x2.v tb/systolic_2x2TB.v
vvp array_sim
```

To inspect waveforms:

```bash
gtkwave dump.vcd
```

> **Verify before publishing:** run both commands from a clean clone and confirm they work as written. If your testbench dumps to a different filename, correct it here. A README whose first command fails is worse than no README.

## Verification

The PE testbench exercises multiply-accumulate behavior across a range of operand values, including zero and maximum-width cases.

The array testbench drives a known input matrix pair through the array and compares the emerging partial sums against the expected matrix product, computed by hand. Correctness was confirmed by waveform inspection in GTKWave.

*(If your testbenches self-check with `$display` PASS/FAIL rather than requiring manual waveform reading, say so — that's a stronger claim and worth stating explicitly.)*

![Waveform showing a verified multiply](docs/waveform.png)

## Limitations

Stated plainly, because knowing where a design stops is part of the design:

- **Fixed 2×2.** Array dimensions are hardcoded. Scaling to N×N requires `generate` blocks — see Roadmap.
- **Simulation only.** Never run through synthesis, so there are no area, timing, or power numbers, and no guarantee every construct is synthesizable.
- **No overflow handling.** The accumulator is sized for the expected operand range rather than saturating or flagging overflow.
- **No memory interface.** Weights and activations are driven directly by the testbench; there is no bus interface, weight-load FSM, or buffering.
- **Manual verification.** Correctness is checked against hand-computed expected values rather than a generated reference model.

## Roadmap

- [ ] Parameterize to N×N using `generate` blocks
- [ ] Python/NumPy golden model to replace hand-computed expected values
- [ ] Push through Yosys/OpenLane for area and timing numbers
- [ ] AXI4-Lite wrapper so the array can be driven as an IP block
- [ ] Weight-load FSM with a serial interface under a constrained I/O budget

## References

- Jouppi et al., *In-Datacenter Performance Analysis of a Tensor Processing Unit*, ISCA 2017 — the TPU v1 paper this dataflow follows.
- Kung, *Why Systolic Architectures?*, IEEE Computer, 1982 — the original formulation.

---

*Built by Jorge Manzano — Computer Engineering, University of Utah.*
