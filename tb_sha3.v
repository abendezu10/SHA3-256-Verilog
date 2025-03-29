`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2025 02:59:39 AM
// Design Name: 
// Module Name: tb_sha3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_sha3;

  reg clk;
  reg rst;
  reg [1087:0] data_i;
  wire [1599:0] data_o;
  reg start;

  // Instantiate the SHA3 module
  sha3 uut (
    .clk(clk),
    .resetn(rst),
    .start(start)
    .data_i(data_i),
    .data_o(data_o),
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  initial begin
    // Initialize
    clk = 0;
    rst = 0;
    data_i = 0;

    // Reset pulse
    #10;
    rst = 1;

    // Feed in test data (e.g., "abc")
   data_i = 1088'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006183;


    // Wait for a few clock cycles
    #3000;

    // Stop simulation
    $finish;
  end

endmodule
