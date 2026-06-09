
`timescale 1ns / 1ps

module universal_shift_register (
    input clk,                  
    input rst,                  
    input [1:0] mode,           
    input serial_in,            
    input [3:0] parallel_in,    
    output reg serial_out,      
    output reg [3:0] parallel_out 
);

    
    reg [3:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg    <= 4'b0000;
            serial_out   <= 1'b0;
            parallel_out <= 4'b0000;
        end
        else begin
            case (mode)
                
                2'b00: begin
                    shift_reg  <= {shift_reg[2:0], serial_in}; 
                    serial_out <= shift_reg[3];               
                end

                
                2'b01: begin
                    shift_reg    <= {shift_reg[2:0], serial_in}; 
                    parallel_out <= {shift_reg[2:0], serial_in}; 
                end


                2'b10: begin
                    serial_out <= shift_reg[3];               
                    shift_reg  <= {shift_reg[2:0], 1'b0};    
                end
                2'b11: begin
                    shift_reg    <= parallel_in; 
                    parallel_out <= parallel_in; 
                end
                
                default: begin
                    shift_reg    <= shift_reg;
                end
            endcase
        end
    end

endmodule
