`timescale 1ns / 1ps

module apb_fifo_slave (

    input wire        clk,
    input wire        rst,

    input wire        psel,
    input wire        penable,
    input wire        pwrite,
    input wire [7:0]  pwdata,

    output wire [7:0] prdata,
    output wire       pready,
    output wire       pslverr,

    output wire       wr_en,
    output wire       rd_en,

    input wire [7:0]  data_out,

    input wire        full,
    input wire        empty
);

    assign pready = psel && penable;

    assign wr_en =
            psel &&
            penable &&
            pwrite &&
            !full;

    assign rd_en =
            psel &&
            penable &&
            !pwrite &&
            !empty;

    assign prdata = data_out;

    assign pslverr =
            psel &&
            penable &&
            (
                (pwrite && full) ||
                (!pwrite && empty)
            );

endmodule
