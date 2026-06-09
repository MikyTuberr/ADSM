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


module envelope(
    input  wire        clk,
    input  wire        reset_n,

    // Slave Interface
    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,

    // Master Interface
    output reg  [15:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready,
    output reg         m_axis_tlast
);

    wire signed [15:0] I = s_axis_tdata[31:16];
    wire signed [15:0] Q = s_axis_tdata[15:0];

    wire [15:0] abs_I = (I[15]) ? -I : I;
    wire [15:0] abs_Q = (Q[15]) ? -Q : Q;

    wire [15:0] max_val = (abs_I > abs_Q) ? abs_I : abs_Q;
    wire [15:0] min_val = (abs_I > abs_Q) ? abs_Q : abs_I;
    
    wire [16:0] env_calc = max_val + (min_val >> 2); 
    wire [15:0] env_sat  = (env_calc > 16'hFFFF) ? 16'hFFFF : env_calc[15:0];

    assign s_axis_tready = m_axis_tready;

    always @(posedge clk) begin
        if (!reset_n) begin
            m_axis_tdata  <= 0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
        end 
        else if (m_axis_tready) begin
            m_axis_tvalid <= s_axis_tvalid;
            
            if (s_axis_tvalid) begin
                m_axis_tdata <= env_sat;
                m_axis_tlast <= s_axis_tlast;
            end
        end
    end
endmodule
