# micro-rv: RV32I Softcore CPU in VHDL

This is a softcore CPU that implements the base RV32I instruction set. I built everything from scratch in VHDL to better understand CPU design and to test it on an FPGA.

## What it does

- Implements the full RV32I instruction set (excluding ECALL, EBREAK, FENCE)
- Single-cycle architecture
- All components are modular (ALU, reg file, control unit, memory)
- Designed to be synthesizable on real hardware

## Folder structure
```
micro-rv/
├── code/ -- VHDL source files for each component
├── docs/ -- Architecture diagrams and explanation
├── vivado/rv32i_softcore/ -- Top-level wrapper and Vivado project
├── LICENSE
└── README.md
```
## Supported instructions

All RV32I base instructions:
- Arithmetic/logical: ADD, SUB, XOR, AND, OR, SLL, SRL, SRA
- Immediate: ADDI, XORI, ANDI, ORI, SLLI, SRLI, SRAI
- Branch: BEQ, BNE, BLT, BGE
- Jump: JAL, JALR
- Load/store: LW, SW
- U-type: LUI, AUIPC

Not implemented: FENCE, ECALL, EBREAK

## Testing

The ROM contains a hand-written test program that goes through each instruction to check:
- ALU correctness
- Register write-back
- Branching and jump behavior

## Running it

1. Open the Vivado project in `vivado/rv32i_softcore`
2. ROM is already filled with test code, but you can swap it out to run your own programs
3. You can synthesize and deploy to an FPGA (tested on Arty A7, but should work on others)

## Tools

- Vivado 2020.2+
- Any FPGA with enough logic

## License

MIT License
