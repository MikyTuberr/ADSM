`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2026 09:35:36
// Design Name: 
// Module Name: tb_frontend_analysis
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


module tb_frontend_analysis();

    reg clk;
    reg reset_n;

    wire detection_hit;

    sonar_processor_top u_dut (
        .clk(clk),
        .reset_n(reset_n),
        .detection_hit(detection_hit)
    );

    always #5 clk = ~clk;

    initial begin
        $display("--- ROZPOCZĘCIE SYMULACJI SONARU ---");
        
        clk = 0;
        reset_n = 0;
        
        #100;
        
        reset_n = 1;
        $display("Czas: %0t ns | System wybudzony, injector zaczyna wysyłać dane...", $time);
        
        #200000;
        
        $display("Czas: %0t ns | Zakończenie testu.", $time);
        $finish;
    end

endmodule

