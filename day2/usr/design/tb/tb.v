`timescale 1ns / 1ps

module tb_universal_shift_register;

    
    reg clk;
    reg rst;
    reg [1:0] mode;
    reg serial_in;
    reg [3:0] parallel_in;

    
    wire serial_out;
    wire [3:0] parallel_out;

    
    universal_shift_register uut (
        .clk(clk), 
        .rst(rst), 
        .mode(mode), 
        .serial_in(serial_in), 
        .parallel_in(parallel_in), 
        .serial_out(serial_out), 
        .parallel_out(parallel_out)
    );
    always #5 clk = ~clk;

    initial begin
        
        clk = 0;
        rst = 1;
        mode = 2'b00;
        serial_in = 0;
        parallel_in = 4'b0000;

        
        $monitor("Time=%0dns | Reset=%b | Mode=%b | SerialIn=%b | ParallelIn=%b | SerialOut=%b | ParallelOut=%b", 
                 $time, rst, mode, serial_in, parallel_in, serial_out, parallel_out);

        
        #15;
        rst = 0;
        #5;

        
        $display("\n--- Testing PIPO Mode (11) ---");
        mode = 2'b11;
        parallel_in = 4'b1011; 
        #10;
        
        parallel_in = 4'b0101; 
        #10;

        
        $display("\n--- Testing PISO Mode (10) ---");
      
        mode = 2'b10; 
        #10; 
        #10; 
        #10;
        #10; 
        $display("\n--- Testing SISO Mode (00) ---");
        mode = 2'b00;
        
        serial_in = 1; #10; 
        serial_in = 1; #10; 
        serial_in = 0; #10; 
        serial_in = 1; #10; 
        
       
        serial_in = 0; #10; 
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;
        $display("\n--- Testing SIPO Mode (01) ---");
        mode = 2'b01;
        
        serial_in = 1; #10; 
        serial_in = 0; #10;
        serial_in = 1; #10;
        serial_in = 0; #10; 

        
        $display("\n--- Simulation Finished ---");
        $finish;
    end
      
endmodule
