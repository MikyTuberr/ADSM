`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2026 21:56:50
// Design Name: 
// Module Name: test
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


module test(
    input wire [1:0] btn,     // Dwa przyciski
    output wire [1:0] led,    // Dwie zielone diody
    output wire led_rgb_r,    // RGB Czerwony
    output wire led_rgb_g,    // RGB Zielony
    output wire led_rgb_b     // RGB Niebieski
);

    // Przycisk 0 zapala obie zielone diody
    assign led = {btn[0], btn[0]};

    // Przycisk 1 zapala diodę RGB na biało (wszystkie 3 kolory naraz)
    assign led_rgb_r = btn[1];
    assign led_rgb_g = btn[1];
    assign led_rgb_b = btn[1];

endmodule
