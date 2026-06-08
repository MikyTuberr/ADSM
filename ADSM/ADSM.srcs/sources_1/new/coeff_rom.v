`timescale 1ns / 1ps

module coeff_rom_bmg #
(
    parameter ADDR_WIDTH = 13
)
(
    input  wire                     clk,
    input  wire [ADDR_WIDTH-1:0]    addr,
    output wire [31:0]              data
);

    // Nazwa modułu IP może być inna, jeśli inaczej nazwałeś Block Memory Generator.
    // Jeśli Vivado wygeneruje np. "blk_mem_gen_0", to zostaw tak jak niżej.
    blk_mem_gen_0 u_bmg (
        .clka  (clk),
        .ena   (1'b1),
        .addra (addr),
        .douta (data)
    );

endmodule