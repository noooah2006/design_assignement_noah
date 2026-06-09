
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 12:35:02 PM
// Design Name: 
// Module Name: Ncoder4x2
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


module Ncoder4x2(
    input [3:0] D,
    output reg [1:0] b
);

always @(*) begin
    case(D)
        4'b0001: b = 2'b00;
        4'b0010: b = 2'b01;
        4'b0100: b = 2'b10;
        4'b1000: b = 2'b11;
        default: b = 2'b00;
    endcase
end

endmodule
