`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 11:29:35
// Design Name: 
// Module Name: matched_filter_core
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


module matched_filter_core #
(
    parameter DATA_WIDTH = 16,
    parameter FFT_SIZE   = 8192,
    parameter COEFF_FILE = "matched_coeffs.mem"
)
(
    input  wire        clk,
    input  wire        reset_n,

    // =========================
    // Slave AXIS
    // =========================
    input  wire [31:0] s_axis_tdata,
    input  wire [12:0] s_axis_tuser,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,

    // =========================
    // Master AXIS
    // =========================
    output reg  [31:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready,
    output reg         m_axis_tlast
);

    // =====================================================
    // AXIS handshake
    // =====================================================

    assign s_axis_tready = m_axis_tready || !m_axis_tvalid;

    // =====================================================
    // Input split
    // =====================================================

    wire signed [15:0] in_re;
    wire signed [15:0] in_im;

    assign in_re = s_axis_tdata[31:16];
    assign in_im = s_axis_tdata[15:0];

    // =====================================================
    // Coefficient ROM
    // =====================================================

    wire [31:0] coeff_word;

    coeff_rom #
    (
        .FFT_SIZE(FFT_SIZE),
        .COEFF_FILE(COEFF_FILE)
    )
    u_coeff_rom
    (
        .addr(s_axis_tuser),
        .data(coeff_word)
    );

    wire signed [15:0] coeff_re;
    wire signed [15:0] coeff_im;

    assign coeff_re = coeff_word[31:16];
    assign coeff_im = coeff_word[15:0];

    // =====================================================
    // Complex multiply
    // =====================================================

    wire signed [31:0] mult_re;
    wire signed [31:0] mult_im;

    complex_mult_q15 u_complex_mult
    (
        .a_re(in_re),
        .a_im(in_im),

        .b_re(coeff_re),
        .b_im(coeff_im),

        .p_re(mult_re),
        .p_im(mult_im)
    );

    // =====================================================
    // AXIS output register
    // =====================================================

    always @(posedge clk) begin

        if (!reset_n) begin

            m_axis_tdata  <= 32'd0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;

        end
        else begin

            if (s_axis_tvalid && s_axis_tready) begin

                m_axis_tdata <= {
                    mult_re[15:0],
                    mult_im[15:0]
                };

                m_axis_tvalid <= 1'b1;
                m_axis_tlast  <= s_axis_tlast;

            end
            else if (m_axis_tready) begin

                m_axis_tvalid <= 1'b0;

            end
        end
    end

endmodule
