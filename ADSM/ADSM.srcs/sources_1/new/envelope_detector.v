`timescale 1ns / 1ps

module envelope_detector(
    input wire aclk,
    input wire aresetn,

    input wire [31:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire s_axis_tlast,

    output reg [15:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input wire m_axis_tready,
    output reg m_axis_tlast
);

// Parametry DISCARD
parameter DISCARD_SAMPLES = 2;

// Licznik próbek
reg [15:0] sample_count;

// Rozdzielenie I/Q
wire signed [15:0] I;
wire signed [15:0] Q;

assign I = s_axis_tdata[31:16];
assign Q = s_axis_tdata[15:0];

// Wartości bezwzględne
wire [15:0] abs_I;
wire [15:0] abs_Q;

assign abs_I = (I < 0) ? -I : I;
assign abs_Q = (Q < 0) ? -Q : Q;

// Envelope
wire [16:0] env;
assign env = abs_I + abs_Q;

assign s_axis_tready = m_axis_tready;

// Główna logika
always @(posedge aclk) begin
    if (!aresetn) begin
        sample_count <= 0;

        m_axis_tdata <= 0;
        m_axis_tvalid <= 0;
        m_axis_tlast <= 0;
    end
    else begin
        if (s_axis_tvalid && s_axis_tready) begin

            sample_count <= sample_count + 1;


            if (sample_count >= DISCARD_SAMPLES) begin
                m_axis_tdata <= env[15:0];
                m_axis_tvalid <= 1;
                m_axis_tlast <= s_axis_tlast;
            end
            else begin
                m_axis_tvalid <= 0;
            end
        end
        else begin
            m_axis_tvalid <= 0;
        end
    end
end
endmodule