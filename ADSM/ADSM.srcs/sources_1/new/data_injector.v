`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 02.05.2026 22:28:09
// Design Name: 
// Module Name: data_injector
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


module data_injector (
    input  wire        clk,
    input  wire        reset_n,
    output wire [15:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    output wire        m_axis_tlast,
    input  wire        m_axis_tready
);

    reg [11:0] test_mem [0:8191];
    reg [13:0] address_counter;

    integer i;

    initial begin
        $readmemh("HFM_50ms.mem", test_mem);
    end

    always @(posedge clk) begin
        if (!reset_n) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            m_axis_tvalid <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if (!reset_n) begin
            address_counter <= 14'd0;
        end else if (m_axis_tvalid && m_axis_tready) begin
            if (address_counter >= 14'd8191) begin
                address_counter <= 14'd0;
            end else begin
                address_counter <= address_counter + 14'd1;
            end
        end
    end

    assign m_axis_tdata = { {4{test_mem[address_counter][11]}}, test_mem[address_counter] };
    assign m_axis_tlast = (address_counter == 14'd8191) ? 1'b1 : 1'b0;

endmodule
