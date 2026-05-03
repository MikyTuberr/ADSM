`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 11:30:20
// Design Name: 
// Module Name: cfar_detection_engine
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


module cfar_detection_engine (
    input  wire        clk,
    input  wire        reset_n,
    // Slave Interface
    input  wire [15:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    // Detection Output
    output wire        output_trigger
);
    assign s_axis_tready = 1'b1;
    assign output_trigger = 1'b0;
endmodule
