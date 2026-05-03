`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 11:30:03
// Design Name: 
// Module Name: envelope_detector
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


module envelope_detector (
    input  wire        clk,
    input  wire        reset_n,
    // Slave Interface
    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    // Master Interface
    output wire [15:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast
);
    assign s_axis_tready = m_axis_tready;
    assign m_axis_tdata  = 0;
    assign m_axis_tvalid = 0;
    assign m_axis_tlast  = 0;
endmodule
