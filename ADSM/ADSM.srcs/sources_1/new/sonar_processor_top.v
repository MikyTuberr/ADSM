`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 02.05.2026 22:06:28
// Design Name: 
// Module Name: sonar_processor_top
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

module sonar_processor_top (
    input wire clk,
    input wire reset_n,
    output wire detection_hit
);

    // --- AXI4-Stream ---
    
    // Input -> Analysis
    wire [15:0] axis_fwd_tdata;
    wire        axis_fwd_tvalid, axis_fwd_tready, axis_fwd_tlast;

    // Analysis -> Matched Filter
    wire [31:0] axis_mf_tdata;
    wire [12:0] axis_mf_tuser; // xk_index
    wire        axis_mf_tvalid, axis_mf_tready, axis_mf_tlast;

    // Matched Filter -> Synthesis
    wire [31:0] axis_inv_tdata;
    wire        axis_inv_tvalid, axis_inv_tready, axis_inv_tlast;

    // Synthesis -> Envelope
    wire [31:0] axis_det_tdata;
    wire        axis_det_tvalid, axis_det_tready, axis_det_tlast;
    
    // Envelope -> CFAR
    wire [15:0] axis_cfar_tdata;
    wire        axis_cfar_tvalid, axis_cfar_tready, axis_cfar_tlast;
    wire        detection_hit;

    // --- MODULES ---

    // 1. FRONTEND
    axis_frontend_input u_input (
        .clk(clk), .reset_n(reset_n),
        .m_axis_tdata(axis_fwd_tdata), .m_axis_tvalid(axis_fwd_tvalid),
        .m_axis_tready(axis_fwd_tready), .m_axis_tlast(axis_fwd_tlast)
    );

    // 2. FFT ANALYSIS
    spectral_analysis_fwd u_analysis (
        .clk(clk), .reset_n(reset_n),
        .s_axis_tdata(axis_fwd_tdata), .s_axis_tvalid(axis_fwd_tvalid),
        .s_axis_tready(axis_fwd_tready), .s_axis_tlast(axis_fwd_tlast),
        .m_axis_tdata(axis_mf_tdata), .m_axis_tvalid(axis_mf_tvalid),
        .m_axis_tready(axis_mf_tready), .m_axis_tlast(axis_mf_tlast),
        .m_axis_tuser(axis_mf_tuser)
    );

    // 3. MATCHED FILTER
    matched_filter_core u_matched_filter (
        .clk(clk), .reset_n(reset_n),
        .s_axis_tdata(axis_mf_tdata), .s_axis_tuser(axis_mf_tuser),
        .s_axis_tvalid(axis_mf_tvalid), .s_axis_tready(axis_mf_tready),
        .s_axis_tlast(axis_mf_tlast),
        .m_axis_tdata(axis_inv_tdata), .m_axis_tvalid(axis_inv_tvalid),
        .m_axis_tready(axis_inv_tready), .m_axis_tlast(axis_inv_tlast)
    );

    // 4. FFT SYNTHESIS
    spectral_synthesis_inv u_synthesis (
        .clk(clk), .reset_n(reset_n),
        .s_axis_tdata(axis_inv_tdata), .s_axis_tvalid(axis_inv_tvalid),
        .s_axis_tready(axis_inv_tready), .s_axis_tlast(axis_inv_tlast),
        .m_axis_tdata(axis_det_tdata), .m_axis_tvalid(axis_det_tvalid),
        .m_axis_tready(axis_det_tready), .m_axis_tlast(axis_det_tlast)
    );

    // 5. ENVELOPE
    envelope_detector u_envelope (
        .clk(clk), .reset_n(reset_n),
        .s_axis_tdata(axis_det_tdata), .s_axis_tvalid(axis_det_tvalid),
        .s_axis_tready(axis_det_tready), .s_axis_tlast(axis_det_tlast),
        .m_axis_tdata(axis_cfar_tdata), .m_axis_tvalid(axis_cfar_tvalid),
        .m_axis_tready(axis_cfar_tready), .m_axis_tlast(axis_cfar_tlast)
    );

    // 6. CFAR
    cfar_detection_engine u_cfar (
        .clk(clk), .reset_n(reset_n),
        .s_axis_tdata(axis_cfar_tdata), .s_axis_tvalid(axis_cfar_tvalid),
        .s_axis_tready(axis_cfar_tready), .s_axis_tlast(axis_cfar_tlast),
        .output_trigger(detection_hit)
    );

endmodule
