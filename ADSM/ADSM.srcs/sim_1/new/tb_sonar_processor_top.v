`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.06.2026 20:04:56
// Design Name: 
// Module Name: tb_sonar_processor_top
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


module tb_sonar_processor_top();

    reg clk;
    reg reset_n;
    
    wire detection_hit;

    sonar_processor_top uut (
        .clk(clk),
        .reset_n(reset_n),
        .detection_hit(detection_hit)
    );

    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    initial begin
        reset_n = 1'b0;
        
        #100;
        
        reset_n = 1'b1;
        
        #2000000;
        
        $display("Symulacja zakończona. Sprawdź wykresy!");
        $finish;
    end

endmodule
