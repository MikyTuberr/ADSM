`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 15:19:56
// Design Name: 
// Module Name: discard
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


module discard #(
    parameter DISCARD_SAMPLES = 2
)(
    input  wire        clk,
    input  wire        reset_n,

    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,

    output wire [31:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast
);

    reg [15:0] sample_count;
    
    wire is_discarding = (sample_count < DISCARD_SAMPLES);

    assign m_axis_tdata  = s_axis_tdata;
    assign m_axis_tlast  = s_axis_tlast;
    
    assign m_axis_tvalid = s_axis_tvalid && !is_discarding;
    
    assign s_axis_tready = m_axis_tready || is_discarding;

    always @(posedge clk) begin
        if (!reset_n) begin
            sample_count <= 0;
        end 
        else if (s_axis_tvalid && s_axis_tready) begin
            if (s_axis_tlast) begin
                sample_count <= 0;
            end 
            else if (is_discarding) begin
                sample_count <= sample_count + 1;
            end
        end
    end
endmodule
