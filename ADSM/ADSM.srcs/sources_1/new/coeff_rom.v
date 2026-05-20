`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2026 23:46:16
// Design Name: 
// Module Name: coeff_rom
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


`timescale 1ns / 1ps

module coeff_rom #
(
    parameter FFT_SIZE   = 8192,
    parameter COEFF_FILE = "matched_coeffs.mem"
)
(
    input  wire [12:0] addr,
    output wire [31:0] data
);

    reg [31:0] rom [0:FFT_SIZE-1];

    initial begin
        $readmemh(COEFF_FILE, rom);
    end

    assign data = rom[addr];

endmodule
