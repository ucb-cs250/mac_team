# mac_team

This is a width-configurable MAC "block" that can calculate 4-8bit\*8bit, 2-16bit\*16-bit, or 1-32bit\*32bit MAC or multiply operations in a single cycle. The operation and operation bitwidth can be configurated at runtime.

## Block Diagram
The MAC "block" is actually designed as a cluster, where the operations are done in a distributed fashion across multiple blocks. This design was chosen as it allows the blocks to be moved around and custom placed to avoid any wire congestion, as the MAC cluster has a large number of inputs and outputs. Below is a simplified block diagram:

![block_diagram](https://github.com/ucb-cs250/mac_team/raw/master/diagrams/cluster-design.png)

## IO
In terms of IO, the whole MAC cluster has 64 bits of total input (32 bits for each input) and 128 bits of total output. As each multiply block only performs 8bit\*8bit multiplies, the input wires are divided as such. To account for larger input bitwidths (16, 32), the inputs will then be passed on to other multiply blocks via internal interconnect to calculate partial products.

The output is divided into 4 32-bit values as there will be 4 different accumulate outputs in the smallest bitwidth case. For larger bitwidths, the output will span more wires. 

Below is a table of the mapping of inputs/outputs to bitwidth configuration. The wires are specified in the above block diagram.

<table>
<thead>
  <tr>
    <th>Input Bitwidth</th>
    <th>Operation ID</th>
    <th>Input A</th>
    <th>Input B</th>
    <th>Output C</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="4">8</td>
    <td>0</td>
    <td>A0</td>
    <td>B0</td>
    <td>C0</td>
  </tr>
  <tr>
    <td>1</td>
    <td>A1</td>
    <td>B1</td>
    <td>C1</td>
  </tr>
  <tr>
    <td>2</td>
    <td>A2</td>
    <td>B2</td>
    <td>C2</td>
  </tr>
  <tr>
    <td>3</td>
    <td>A3</td>
    <td>B3</td>
    <td>C3</td>
  </tr>
  <tr>
    <td rowspan="2">16</td>
    <td>0</td>
    <td>{A1,A0}</td>
    <td>{B1,B0}</td>
    <td>{C1,C0}</td>
  </tr>
  <tr>
    <td>1</td>
    <td>{A3,A2}</td>
    <td>{B3,B2}</td>
    <td>{C3,C2}</td>
  </tr>
  <tr>
    <td>32</td>
    <td>0</td>
    <td>{A3,A2,A1,A0}</td>
    <td>{B3,B2,B1,B0}</td>
    <td>{C3,C2,C1,C0}</td>
  </tr>
</tbody>
</table>

## Configuration
The whole MAC cluster takes in 131 bits of configuration. The first 128 bits are used for initial accumulator values (4x32) and the last 3 bits are the function configuration that sets the function (MAC or multiply) and the bitwidth (8-single, 16-dual, 32-quad). The bit layout is as follows:
`{32'acc3_init, 32'acc2_init, 32'acc1_init, 32'acc0_init, 1'function, 2'bitwidth}`
For the function configuration bit, a `0` encodes multiply only and a `1` encodes multiply-accumulate. For the bitwidth, a `00` encodes an operation bitwidth of 8 (single), a `01` encodes an operation bitwidth of 16 (dual), and `10` encodes an operation bitwidth of 32 (quad).

## Testing
We also supply a testbench to verify the functionality of the MAC. 

To build, run:
`make-clean && make`

To run the testbench, run:
`./simulator-mac_test_harness +cfg=<val> +num_tests=<val>`
where cfg is the 3-bit function configuration and num_tests is the number of tests. The different configuration codes are as follows:
```
0 = 4 8x8 mults, multiply  only
1 = 2 16x16 mults, multiply only
2 = 1 32x32 mults,  multiply only
4 = 4 8x8 mults, MAC
5 = 2 16x16 mults, MAC
6 = 1 32x32 mults, MAC
```