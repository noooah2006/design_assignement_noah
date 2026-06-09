`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 08:58:35 PM
// Design Name: 
// Module Name: ripplecarryadder_tb
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



module ripplecarryadder_tb();

reg [3:0] A_tb, B_tb;
reg cin_tb;
wire [3:0] S_tb;
wire cout_tb;

ripplecarryadder dut(
    A_tb,
    B_tb,
    cin_tb,
    S_tb,
    cout_tb
);

initial
begin
    {A_tb, B_tb, cin_tb} = 0;
end

initial
begin
    A_tb = 4'b0000; B_tb = 4'b0000; cin_tb = 1'b0;
    #1;
    A_tb = 4'b0011; B_tb = 4'b0101; cin_tb = 1'b0;
    #1;
    A_tb = 4'b0111; B_tb = 4'b0001; cin_tb = 1'b0;
    #1;
    A_tb = 4'b1111; B_tb = 4'b0001; cin_tb = 1'b0;
    #1;
    A_tb = 4'b1010; B_tb = 4'b0101; cin_tb = 1'b1;
    #1;
    A_tb = 4'b1111; B_tb = 4'b1111; cin_tb = 1'b1;
    #1;
    $finish;
end

endmodule

