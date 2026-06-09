`timescale 1ns / 1ps

module envelope_detector #(
    parameter DISCARD_SAMPLES = 2
)(
    input  wire        clk,
    input  wire        reset_n,

    // Slave 
    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,

    // Master
    output wire [15:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast
);
    wire [31:0] int_tdata;
    wire        int_tvalid;
    wire        int_tready;
    wire        int_tlast;

    discard #(
        .DISCARD_SAMPLES(DISCARD_SAMPLES)
    ) u_discard (
        .clk           (clk),
        .reset_n       (reset_n),
        
        .s_axis_tdata  (s_axis_tdata),
        .s_axis_tvalid (s_axis_tvalid),
        .s_axis_tready (s_axis_tready),
        .s_axis_tlast  (s_axis_tlast),
        
        .m_axis_tdata  (int_tdata),
        .m_axis_tvalid (int_tvalid),
        .m_axis_tready (int_tready),
        .m_axis_tlast  (int_tlast)
    );

    envelope u_core (
        .clk           (clk),
        .reset_n       (reset_n),
        
        .s_axis_tdata  (int_tdata),
        .s_axis_tvalid (int_tvalid),
        .s_axis_tready (int_tready),
        .s_axis_tlast  (int_tlast),
        
        .m_axis_tdata  (m_axis_tdata),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tready (m_axis_tready),
        .m_axis_tlast  (m_axis_tlast)
    );

endmodule