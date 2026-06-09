`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 09:20:49 PM
// Design Name: 
// Module Name: bcd_tb
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



module bcd_tb();
reg [3:0]A,B;
reg cin;
wire [3:0]S;
wire cout;
bcd dut(A,B,cin,S,cout);
initial
begin
$monitor("value of A is %b  value of B is %b  value of cin is %b  value of S is %b  value of cout is %b",A,B,cin,S,cout);
A=3; B=6; cin=1;#10;
A=6; B=8; cin=0;#10;
A=9; B=4; cin=0;#10;
A=1; B=2; cin=1;#10;
end
endmodule

