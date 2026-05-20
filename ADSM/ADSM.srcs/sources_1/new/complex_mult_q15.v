`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2026 23:41:42
// Design Name: 
// Module Name: complex_mult_q15
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


`timescale 1ns / 1ps

module complex_mult_q15
(
    input  wire signed [15:0] a_re,
    input  wire signed [15:0] a_im,

    input  wire signed [15:0] b_re,
    input  wire signed [15:0] b_im,

    output wire signed [31:0] p_re,
    output wire signed [31:0] p_im
);

    wire signed [31:0] ac;
    wire signed [31:0] bd;
    wire signed [31:0] ad;
    wire signed [31:0] bc;

    assign ac = a_re * b_re;
    assign bd = a_im * b_im;

    assign ad = a_re * b_im;
    assign bc = a_im * b_re;

    // Q1.15 scaling

    assign p_re = (ac - bd) >>> 15;
    assign p_im = (ad + bc) >>> 15;

endmodule
