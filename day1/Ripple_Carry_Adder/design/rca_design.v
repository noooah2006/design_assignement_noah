`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 09:05:03 PM
// Design Name: 
// Module Name: ripplecarryadder
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
////////////////////////////////////////////////////////////////////////////    );
`timescale 1ns / 1ps

module ripplecarryadder(
    input [3:0] A,
    input [3:0] B,
    input cin,
    output [3:0] S,
    output cout
);

wire c1, c2, c3;

assign S[0] = A[0] ^ B[0] ^ cin;
assign c1   = (A[0] & B[0]) | (cin & (A[0] ^ B[0]));

assign S[1] = A[1] ^ B[1] ^ c1;
assign c2   = (A[1] & B[1]) | (c1 & (A[1] ^ B[1]));

assign S[2] = A[2] ^ B[2] ^ c2;
assign c3   = (A[2] & B[2]) | (c2 & (A[2] ^ B[2]));

assign S[3] = A[3] ^ B[3] ^ c3;
assign cout = (A[3] & B[3]) | (c3 & (A[3] ^ B[3]));

endmodule
