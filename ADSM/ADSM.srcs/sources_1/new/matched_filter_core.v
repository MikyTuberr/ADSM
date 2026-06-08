`timescale 1ns / 1ps

module matched_filter_core #
(
    parameter DATA_WIDTH = 16,
    parameter FFT_SIZE   = 8192,
    parameter ADDR_WIDTH = 13   // dla FFT_SIZE=8192
)
(
    input  wire                     clk,
    input  wire                     reset_n,

    // =========================
    // Slave AXIS from FFT IP
    // =========================
    input  wire [31:0]             s_axis_tdata,   // [31:16]=REAL, [15:0]=IMAG
    input  wire [ADDR_WIDTH-1:0]   s_axis_tuser,   // bin index z FFT IP
    input  wire                    s_axis_tvalid,
    output wire                    s_axis_tready,
    input  wire                    s_axis_tlast,

    // =========================
    // Master AXIS to IFFT IP
    // =========================
    output reg  [31:0]             m_axis_tdata,   // [31:16]=REAL, [15:0]=IMAG
    output reg                     m_axis_tvalid,
    input  wire                    m_axis_tready,
    output reg                     m_axis_tlast
);

    // ---------------------------------------------------------
    // AXI handshaking
    // ---------------------------------------------------------
    assign s_axis_tready = m_axis_tready || !m_axis_tvalid;

    // ---------------------------------------------------------
    // Input split
    // ---------------------------------------------------------
    wire signed [DATA_WIDTH-1:0] in_re;
    wire signed [DATA_WIDTH-1:0] in_im;

    assign in_re = s_axis_tdata[31:16];
    assign in_im = s_axis_tdata[15:0];

    // ---------------------------------------------------------
    // Coefficient ROM IP (Block Memory Generator)
    // ---------------------------------------------------------
    wire [31:0] coeff_word;

    coeff_rom_bmg #
    (
        .ADDR_WIDTH(ADDR_WIDTH)
    )
    u_coeff_rom
    (
        .clk  (clk),
        .addr (s_axis_tuser),
        .data (coeff_word)
    );

    wire signed [DATA_WIDTH-1:0] coeff_re;
    wire signed [DATA_WIDTH-1:0] coeff_im;

    assign coeff_re = coeff_word[31:16];
    assign coeff_im = coeff_word[15:0];

    // ---------------------------------------------------------
    // Complex multiply
    // ---------------------------------------------------------
    wire signed [DATA_WIDTH-1:0] mult_re;
    wire signed [DATA_WIDTH-1:0] mult_im;

    complex_mult_q15 #
    (
        .DATA_WIDTH(DATA_WIDTH)
    )
    u_complex_mult
    (
        .a_re(in_re),
        .a_im(in_im),
        .b_re(coeff_re),
        .b_im(coeff_im),
        .p_re(mult_re),
        .p_im(mult_im)
    );

    // ---------------------------------------------------------
    // 1-cycle register stage for output
    // ---------------------------------------------------------
    reg signed [DATA_WIDTH-1:0] in_re_d1;
    reg signed [DATA_WIDTH-1:0] in_im_d1;
    reg                         tlast_d1;
    reg                         valid_d1;

    always @(posedge clk) begin
        if (!reset_n) begin
            in_re_d1      <= {DATA_WIDTH{1'b0}};
            in_im_d1      <= {DATA_WIDTH{1'b0}};
            tlast_d1      <= 1'b0;
            valid_d1      <= 1'b0;

            m_axis_tdata  <= 32'd0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
        end
        else begin
            // input capture
            if (s_axis_tvalid && s_axis_tready) begin
                in_re_d1 <= in_re;
                in_im_d1 <= in_im;
                tlast_d1 <= s_axis_tlast;
                valid_d1 <= 1'b1;
            end
            else if (m_axis_tready && m_axis_tvalid) begin
                valid_d1 <= 1'b0;
            end

            // output capture
            if (valid_d1 && (m_axis_tready || !m_axis_tvalid)) begin
                m_axis_tdata  <= {mult_re, mult_im};
                m_axis_tvalid <= 1'b1;
                m_axis_tlast  <= tlast_d1;
            end
            else if (m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end

endmodule