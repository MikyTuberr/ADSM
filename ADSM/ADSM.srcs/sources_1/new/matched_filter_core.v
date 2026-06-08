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
    wire pipe_en = m_axis_tready || !m_axis_tvalid;
    assign s_axis_tready = pipe_en;
    
    // ---------------------------------------------------------
    // Coefficient ROM IP (Block Memory Generator)
    // ---------------------------------------------------------
    wire [31:0] coeff_word;
    coef_rom coef_rom (
        .clka  (clk),
        .ena   (pipe_en),
        .addra (s_axis_tuser),
        .douta (coeff_word)
    );
    
    wire signed [15:0] coeff_re = coeff_word[31:16];
    wire signed [15:0] coeff_im = coeff_word[15:0];
    
    // ---------------------------------------------------------
    // Input split
    // ---------------------------------------------------------
    wire signed [DATA_WIDTH-1:0] in_re;
    wire signed [DATA_WIDTH-1:0] in_im;
    
    
    // ---------------------------------------------------------
    // STAGE 1: Data alignment registers (alignment to ROM latency = 1)
    // ---------------------------------------------------------
    reg signed [DATA_WIDTH-1:0] in_re_d1;
    reg signed [DATA_WIDTH-1:0] in_im_d1;
    reg                         tlast_d1;
    reg                         tvalid_d1;
    
    always @(posedge clk) begin
        if (!reset_n) begin
            in_re_d1  <= {DATA_WIDTH{1'b0}};
            in_im_d1  <= {DATA_WIDTH{1'b0}};
            tvalid_d1 <= 1'b0;
            tlast_d1  <= 1'b0;
        end else if (pipe_en) begin
            in_re_d1  <= s_axis_tdata[31:16];
            in_im_d1  <= s_axis_tdata[15:0];
            tvalid_d1 <= s_axis_tvalid;
            tlast_d1  <= s_axis_tlast;
        end
    end   
    
    // ---------------------------------------------------------
    // STAGE 2: Complex Multiplier Instance Q15
    // ---------------------------------------------------------
    wire signed [DATA_WIDTH-1:0] mult_re;
    wire signed [DATA_WIDTH-1:0] mult_im;

    complex_mult_q15 #
    (
        .DATA_WIDTH(DATA_WIDTH)
    )
    u_complex_mult
    (
        .a_re(in_re_d1),
        .a_im(in_im_d1),
        .b_re(coeff_re),
        .b_im(coeff_im),
        .p_re(mult_re),
        .p_im(mult_im)
    );
    
    // ---------------------------------------------------------
    // STAGE 3: Output register (AXI-Stream master)
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (!reset_n) begin
            m_axis_tdata  <= 32'd0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
        end else if (pipe_en) begin
            m_axis_tdata  <= {mult_re, mult_im};
            m_axis_tvalid <= tvalid_d1;
            m_axis_tlast  <= tlast_d1;
        end
    end


endmodule