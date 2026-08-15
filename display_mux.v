`timescale 1ns / 1ps

module display_mux (

    input wire        clk,
    input wire [11:0] value,

    output reg [3:0]  an,
    output wire [6:0] seg
);

    reg [16:0] refresh_counter;
    reg [3:0] digit;

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1'b1;
    end

    always @(*) begin

        case (refresh_counter[16:15])

            2'b00: begin
                an = 4'b1110;
                digit = value % 10;
            end

            2'b01: begin
                an = 4'b1101;
                digit = (value / 10) % 10;
            end

            2'b10: begin
                an = 4'b1011;
                digit = (value / 100) % 10;
            end

            2'b11: begin
                an = 4'b0111;
                digit = (value / 1000) % 10;
            end

            default: begin
                an = 4'b1111;
                digit = 4'd0;
            end

        endcase

    end

    hex_to_7seg decoder (

        .hex(digit),
        .seg(seg)

    );

endmodule
