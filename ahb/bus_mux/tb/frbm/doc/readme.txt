// This confidential and proprietary software may be used only as
// authorised by a licensing agreement from The University of Southampton
// (c) COPYRIGHT 2010 The University of Southampton
// ALL RIGHTS RESERVED
// The entire notice above must be reproduced on all authorised
// copies and copies may only be made to the extent permitted
// by a licensing agreement from The University of Southampton.
//
// --------------------------------------------------------------------------
// Version and Release Control Information:
//
// File Name : ahb_frbm.v
//
// --------------------------------------------------------------------------
// Purpose : Generic AHB master that outputs signals based on the contesnts
//           of a command file.
// --------------------------------------------------------------------------

This is an AMBA AHB master that reads from a file and stimulates the AHB bus correctly. It supports most of the standard however does not support retry or split transactions.

Structure:
./src/ahb_frbm.v  : The bus master itself
./sim/ahb_gen_slave.v  : A generic AHB slave "memory"
./sim/tb_ahb_frbm.v : A basic testbench
./scripts/*.tic : Various example stimulus scripts

On running the testbench a master and a slave will be instantiated and the master will execute the specified *.tic script.

TIC SCRIPT Commands
-------------------

Command   Name               Description
A <addr>  Address packet     Sets the value of the HADDR bus.

W <data>  Write data         Sets the value of the HWDATA bus (must appear after an address packet) and autoincrement the address. To write to the same location repeatedly (e.g. for I/O) issue a new Address for every write.

R         Read data          Reads the current value of HRDATA and prints it to the transcript window (must appear after an address packet) and autoincrement the address.

E <data>  Expect exact data  Reads the current value of HRDATA, compares it to <data>, and prints an error to the transcript window if they are different.

M <data>  Expect Mask        Sets a mask to be applied to all data compared with the expect command which makes it possible to compare specific bits. The mask will be applied until a new mask is set (the default mask is 0xFFFFFFFF).

U         Busy               Places the bus in busy mode for a clock cycle.

I         Idle               Places the bus in idle mode for a clock cycle.

P <value> Protection         Sets the HPROT signals on the bus; <value> should be according to the AMBA specification.

B <value> Burst   			Sets the HBURST signals on the bus; <value> should be according to the AMBA specification.

L <value> Lock               Sets the HLOCK signal on the bus; <value> should be either 1 or 0.

S <value> Size               Sets the HSIZE signal on the bus; <value> should be either 0x2 for 32 bit, 0x1 for 16 bit or 0x0 for 8 bit.

X         Exit               Terminates the current simulation. 

An example TIC script:

# My example script
A 1234
W 1111
W 2222
W 3333
I
I
A 1234
R
R
R
X

This simple script should write the values 1111, 2222, and 3333 into three consecutive 32 bit words and then read them back again into the transcript window. It is also perfectly fine to use the EXPECT command (E) to verify the reads. 

Parameters:

Both the slave and the master use parameters to enable convenient use of several masters and slaves in the same system along with many other features. Consult the verilog files for more details.


