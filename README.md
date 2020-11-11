# mac_team

This is a width-configurable MAC "block" that can calculate 4-8bit\*8bit, 2-16bit\*16-bit, or 1-32bit\*32bit MAC or multiply operations in a single cycle. The operation and operation bitwidth can be configurated at runtime.

## Basic Block Diagram and IO
Below is a basic block diagram of the inputs and outputs of the MAC from an external point of view. More a closer look at the MAC, please refer to the section [MAC Cluster Block Diagram](#MAC-Cluster-Block-Diagram).

![block_diagram](https://github.com/ucb-cs250/mac_team/raw/master/diagrams/basic-block-diagram.png)

For IO, the whole MAC has 64 bits of total input (32 bits for each input) and 128 bits of total output. As the smallest input bitwidth is 8, the input wires are divided as such. To account for larger input bitwidths (16, 32), the inputs will span more wires. Similarly, the output is divided into 4 32-bit values as there will be 4 different accumulate outputs in the smallest bitwidth case. For larger bitwidths, the output will span more wires. 

Below is a table of the mapping of inputs/outputs to bitwidth configuration. The wires are specified in the above block diagram.

<table>
<thead>
  <tr>
    <th>Input Bitwidth</th>
    <th>Operation ID</th>
    <th>Input A</th>
    <th>Input B</th>
    <th>Output</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="4">8</td>
    <td>0</td>
    <td>A0</td>
    <td>B0</td>
    <td>out0</td>
  </tr>
  <tr>
    <td>1</td>
    <td>A1</td>
    <td>B1</td>
    <td>out1</td>
  </tr>
  <tr>
    <td>2</td>
    <td>A2</td>
    <td>B2</td>
    <td>out2</td>
  </tr>
  <tr>
    <td>3</td>
    <td>A3</td>
    <td>B3</td>
    <td>out3</td>
  </tr>
  <tr>
    <td rowspan="2">16</td>
    <td>0</td>
    <td>{A1,A0}</td>
    <td>{B1,B0}</td>
    <td>{out1,out0}</td>
  </tr>
  <tr>
    <td>1</td>
    <td>{A3,A2}</td>
    <td>{B3,B2}</td>
    <td>{out3,out2}</td>
  </tr>
  <tr>
    <td>32</td>
    <td>0</td>
    <td>{A3,A2,A1,A0}</td>
    <td>{B3,B2,B1,B0}</td>
    <td>{out3,out2,out1,out0}</td>
  </tr>
</tbody>
</table>

## Configuration
The whole MAC cluster takes in 132 bits of configuration. The first 128 bits are used for initial accumulator values (4x32) and the last 4 bits are the function configuration that sets the signed operation (unsigned or signed), function (MAC or multiply) and the bitwidth (8-single, 16-dual, 32-quad). The bit layout is as follows:
`{32'acc3_init, 32'acc2_init, 32'acc1_init, 32'acc0_init, 1'signed, 1'function, 2'bitwidth}`
For the signed operation configuration bit, a `0` encodes unsigned while a `1` encodes signed operations. For the function configuration bit, a `0` encodes multiply only and a `1` encodes multiply-accumulate. For the bitwidth, a `00` encodes an operation bitwidth of 8 (single), a `01` encodes an operation bitwidth of 16 (dual), and `10` encodes an operation bitwidth of 32 (quad).

## Testing
We also supply a testbench to verify the functionality of the MAC. 

To build, run:
`make-clean && make`

To run the testbench, run:
`./simulator-mac_test_harness +cfg=<val> +num_tests=<val>`
where cfg is the 3-bit function configuration and num_tests is the number of tests. The different configuration codes are as follows:
```
0 = 4 8x8 mults, multiply  only   (unsigned)
1 = 2 16x16 mults, multiply only  (unsigned)
2 = 1 32x32 mult,  multiply only  (unsigned)
4 = 4 8x8 mults, MAC              (unsigned)
5 = 2 16x16 mults, MAC            (unsigned)
6 = 1 32x32 mult, MAC             (unsigned)

8 = 4 8x8 mults, multiply  only   (signed)
9 = 2 16x16 mults, multiply only  (signed)
10 = 1 32x32 mult,  multiply only (signed)
12 = 4 8x8 mults, MAC             (signed)
13 = 2 16x16 mults, MAC           (signed)
14 = 1 32x32 mult, MAC            (signed)
```

## MAC Cluster Block Diagram
For those who are interested in the design of the MAC, the below diagram briefly details the different components. The MAC "block" is actually designed as a cluster, where the operations are done in a distributed fashion across multiple blocks. This design was chosen as it allows the blocks to be moved around and custom placed to avoid any wire congestion, as the MAC cluster has a large number of inputs and outputs.

![cluster_block_diagram](https://github.com/ucb-cs250/mac_team/raw/master/diagrams/cluster-design.png)

Regarding the main components, the multiply, combiner, and accumulator blocks provide the MAC cluster's core functionality. Each multiply block preforms unsigned 8x8 multiply operations with up to 4 parallel multiplies at a time. For the single width (8-bit) configuration, each multiply block performs their own independent 8x8 multiply. For larger configurations such as the 16 and 32-bit inputs, the multiply blocks perform multiple operations in parallel to compute the cross-products to multiply larger bitwidths. The combiner block then takes those cross-products and assembles them into the correct result. Once the inputs have been properly multiplied, they are then passed into the accumulator which will then accumulate the values or forward the values depending on the configured function.

For the MAC to support signed operations, negator blocks are cleverly used to manipulate the sign of the multiplication inputs and outputs such that we can re-use the unsigned multipliers to avoid extra hardware. The first negator block will take the absolute value of all inputs to allow for unsigned multiplication, while the second negator will assign the correct sign after the multiplication has completed. This double negation layer strategy allows us to properly multiply signed inputs without having the need for signed multipliers.

For more exact block diagrams of each component, you can check out the ![diagrams directory](https://github.com/ucb-cs250/mac_team/tree/master/diagrams).