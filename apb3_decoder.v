`timescale 1ns / 1ps

module apb3_decoder (

    input  wire       psel,
    input  wire [7:0] paddr,

    output wire       fifo_sel,
    output wire       pwm_sel
);

    assign fifo_sel =
            psel &&
            (paddr == 8'h20);

    assign pwm_sel =
            psel &&
            (paddr == 8'h30);

endmodule
