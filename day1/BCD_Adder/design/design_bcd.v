`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 09:12:20 PM
// Design Name: 
// Module Name: bcd
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


module bcd(
    input [3:0] A,
    input [3:0] B,
    input cin,
    output [3:0] S,
    output cout
);

wire w1, w2, w3, w4;
wire [3:0] S1;
wire [3:0] corr;

ripplecarryadder R1(
    .A(A),
    .B(B),
    .cin(cin),
    .S(S1),
    .cout(w1)
);

and(w2, S1[1], S1[3]);
and(w3, S1[2], S1[3]);
or(w4, w2, w3, w1);

assign corr = {1'b0, w4, w4, 1'b0};

ripplecarryadder R2(
    .A(S1),
    .B(corr),
    .cin(1'b0),
    .S(S),
    .cout(cout)
);

endmodule
