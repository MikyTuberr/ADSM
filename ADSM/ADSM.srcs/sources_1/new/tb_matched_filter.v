`timescale 1ns / 1ps

module tb_matched_filter;

    reg clk = 0;
    always #5 clk = ~clk;   // 100 MHz

    reg reset_n = 0;

    reg  [31:0] s_axis_tdata;
    reg  [12:0] s_axis_tuser;
    reg         s_axis_tvalid;
    reg         s_axis_tlast;
    wire        s_axis_tready;

    wire [31:0] m_axis_tdata;
    wire        m_axis_tvalid;
    wire        m_axis_tlast;
    reg         m_axis_tready = 1;

    matched_filter_core dut (
        .clk(clk),
        .reset_n(reset_n),

        .s_axis_tdata(s_axis_tdata),
        .s_axis_tuser(s_axis_tuser),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );

    initial begin
        s_axis_tdata  = 0;
        s_axis_tuser  = 0;
        s_axis_tvalid = 0;
        s_axis_tlast  = 0;

        #100;
        reset_n = 1;
        #20;

        // 0.5 + j0 w Q1.15
        s_axis_tdata  = {16'sd16384, 16'sd0};
        s_axis_tuser  = 0;
        s_axis_tvalid = 1;
        s_axis_tlast  = 1;

        #10;
        s_axis_tvalid = 0;

        #200;
        $finish;
    end

endmodule