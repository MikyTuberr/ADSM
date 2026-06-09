`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 11:29:48
// Design Name: 
// Module Name: spectral_synthesis_inv
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


module spectral_synthesis_inv (
    input  wire        clk,
    input  wire        reset_n,
    // Slave Interface
    // Slave Interface (from matched_filter_core)
    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    // Master Interface
    // Master Interface (to envelope_detector)
    output wire [31:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast
);

    wire [7:0] fft_config_tdata  = 8'h00;
    wire        fft_config_tvalid = 1'b1;

    // ---------------------------------------------------------------------
    // FFT IP Core instance (configured as IFFT)
    // ---------------------------------------------------------------------
    fft_8192_synthesis u_ifft (
        .aclk    (clk),
        .aresetn (reset_n),

        // S_AXIS_CONFIG
        .s_axis_config_tdata  (fft_config_tdata),
        .s_axis_config_tvalid (fft_config_tvalid),
//      .s_axis_config_tready (), 

        // S_AXIS_DATA -- 32-bit complex from matched filter
        .s_axis_data_tdata  (s_axis_tdata),
        .s_axis_data_tvalid (s_axis_tvalid),
        .s_axis_data_tready (s_axis_tready),
        .s_axis_data_tlast  (s_axis_tlast),

        // M_AXIS_DATA -- 32-bit complex time-domain output
        .m_axis_data_tdata  (m_axis_tdata),
        .m_axis_data_tvalid (m_axis_tvalid),
//      .m_axis_data_tready (m_axis_tready),  
        .m_axis_data_tlast  (m_axis_tlast),
//      .m_axis_data_tuser  (),

        .event_frame_started       (),
        .event_tlast_unexpected    (),
        .event_tlast_missing       (),
        .event_data_in_channel_halt()
    );

endmodule