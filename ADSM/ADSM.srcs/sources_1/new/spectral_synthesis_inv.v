`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: spectral_synthesis_inv
// Description: Inverse FFT (IFFT, N=8192) wrapper around Xilinx FFT IP Core.
//              Mirror of spectral_analysis_fwd, configured for inverse transform.
//
//              Pipeline position:
//                matched_filter_core -> [spectral_synthesis_inv] -> envelope_detector
//
// AXI4-Stream:
//   Slave  (in):  [31:0] tdata = {XK_IM[15:0], XK_RE[15:0]} from matched filter
//   Master (out): [31:0] tdata = {XN_IM[15:0], XN_RE[15:0]} time-domain samples
//
// IP Core requirement (create in IP Catalog):
//   Name: fft_8192_synthesis
//   Use the SAME settings as fft_8192_analysis:
//     - Transform Length    : 8192
//     - Transform Type      : Forward and Inverse (run-time configurable)
//     - Architecture        : Pipelined, Streaming I/O
//     - Data Format         : Fixed Point
//     - Input  Data Width   : 16
//     - Phase Factor Width  : 16
//     - Output Ordering     : Natural Order
//     - Scaling             : Unscaled
//     - Rounding            : Truncation
//     - Throttle Scheme     : Realtime
//     - Optional Output     : XK_INDEX (tuser) enabled (kept consistent w/ analysis)
//   The only difference vs. analysis is the runtime config word below (8'h00 = IFFT).
//////////////////////////////////////////////////////////////////////////////////


module spectral_synthesis_inv (
    input  wire        clk,
    input  wire        reset_n,
    // Slave Interface (from matched_filter_core)
    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    // Master Interface (to envelope_detector)
    output wire [31:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast
);

    // ---------------------------------------------------------------------
    // FFT runtime config:
    //   bit[0] = 0  -> Inverse FFT (IFFT)
    //   bit[0] = 1  -> Forward FFT
    // spectral_analysis_fwd uses 8'h01 (FWD); here we use 8'h00 (INV).
    // ---------------------------------------------------------------------
    wire [7:0] fft_config_tdata  = 8'h00;
    wire       fft_config_tvalid = 1'b1;

    // ---------------------------------------------------------------------
    // FFT IP Core instance (configured as IFFT)
    // ---------------------------------------------------------------------
    fft_8192_synthesis u_ifft (
        .aclk    (clk),
        .aresetn (reset_n),

        // S_AXIS_CONFIG -- pick IFFT
        .s_axis_config_tdata  (fft_config_tdata),
        .s_axis_config_tvalid (fft_config_tvalid),
//      .s_axis_config_tready (),                  // not used (matches analysis)

        // S_AXIS_DATA -- 32-bit complex from matched filter
        .s_axis_data_tdata  (s_axis_tdata),
        .s_axis_data_tvalid (s_axis_tvalid),
        .s_axis_data_tready (s_axis_tready),
        .s_axis_data_tlast  (s_axis_tlast),

        // M_AXIS_DATA -- 32-bit complex time-domain output
        .m_axis_data_tdata  (m_axis_tdata),
        .m_axis_data_tvalid (m_axis_tvalid),
//      .m_axis_data_tready (m_axis_tready),       // IP is realtime: no backpressure
        .m_axis_data_tlast  (m_axis_tlast),
//      .m_axis_data_tuser  (),                    // xk_index not propagated downstream

        // Events (tied off, same as analysis)
        .event_frame_started       (),
        .event_tlast_unexpected    (),
        .event_tlast_missing       (),
        .event_data_in_channel_halt()
    );

endmodule