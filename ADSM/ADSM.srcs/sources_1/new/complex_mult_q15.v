`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2026 11:40:09
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


module complex_mult_q15 #
(
    parameter DATA_WIDTH = 16
)
(
    input  wire signed [DATA_WIDTH-1:0] a_re,
    input  wire signed [DATA_WIDTH-1:0] a_im,
    input  wire signed [DATA_WIDTH-1:0] b_re,
    input  wire signed [DATA_WIDTH-1:0] b_im,

    output wire signed [DATA_WIDTH-1:0] p_re,
    output wire signed [DATA_WIDTH-1:0] p_im
);

    localparam PROD_WIDTH = 2*DATA_WIDTH;

    wire signed [PROD_WIDTH-1:0] ac;
    wire signed [PROD_WIDTH-1:0] bd;
    wire signed [PROD_WIDTH-1:0] ad;
    wire signed [PROD_WIDTH-1:0] bc;

    assign ac = a_re * b_re;
    assign bd = a_im * b_im;
    assign ad = a_re * b_im;
    assign bc = a_im * b_re;

    wire signed [PROD_WIDTH-1:0] re_scaled;
    wire signed [PROD_WIDTH-1:0] im_scaled;

    assign re_scaled = (ac - bd) >>> (DATA_WIDTH-1);
    assign im_scaled = (ad + bc) >>> (DATA_WIDTH-1);

    function signed [DATA_WIDTH-1:0] sat16;
        input signed [PROD_WIDTH-1:0] x;
        begin
            if (x > 32'sd32767)
                sat16 = 16'sd32767;
            else if (x < -32'sd32768)
                sat16 = -16'sd32768;
            else
                sat16 = x[DATA_WIDTH-1:0];
        end
    endfunction

    assign p_re = sat16(re_scaled);
    assign p_im = sat16(im_scaled);

endmodule
