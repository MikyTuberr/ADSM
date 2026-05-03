`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 23:31:23
// Design Name: 
// Module Name: tb_sonar_frontend
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


module tb_sonar_frontend();

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
