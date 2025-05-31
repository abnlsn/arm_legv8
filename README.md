# ARM LEGv8 Implementation
This is a VHDL implementation of 5 stage pipelined ARM LEGv8 CPU as described in [Computer Organization and Design: The Hardware/
Software Interface, ARM® Edition](https://shop.elsevier.com/books/computer-organization-and-design-arm-edition/patterson/978-0-12-801733-3) (Patterson and Hennessy 2017).

# Running / Testing

The `asm` folder provides two different assembly (and corresponding machine code) programs. These programs (p1 and p2) are represented by the `imem_p1.vhd` and `imem_p2.vhd` files. These files provide two different versions of the instruction memory entity so that the cpu can run the two different programs.

Programs are run using either `make p1` or `make p2`. Running these commands will execute testbenches and output gtkwave waveforms for debugging purposes.