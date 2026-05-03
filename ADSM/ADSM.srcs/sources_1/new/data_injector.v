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
    input wire clk,
    input wire reset_n,
    
    output reg [15:0] m_axis_tdata,
    output reg        m_axis_tvalid,
    output reg        m_axis_tlast,
    input wire        m_axis_tready
);

    reg [11:0] test_mem [0:8191];
    integer address_counter;

    initial begin
        $readmemh("sonar_signals.txt", test_mem);
    end

    always @(posedge clk) begin
        if (!reset_n) begin
            address_counter    <= 0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;    // Reset TLAST
            m_axis_tdata  <= 16'd0;
        end else begin
            if (m_axis_tready) begin
                m_axis_tvalid <= 1'b1;
                
                // Sign Extension
                m_axis_tdata <= { {4{test_mem[address_counter][11]}}, test_mem[address_counter] };
                
                // Generowanie TLAST na ostatniej próbce (8191)
                if (address_counter == 8191) begin
                    m_axis_tlast <= 1'b1;
                    address_counter   <= 0;
                end else begin
                    m_axis_tlast <= 1'b0;
                    address_counter   <= address_counter + 1;
                end
            end
        end
    end

endmodule
