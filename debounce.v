`timescale 1ns / 1ps

module debounce (

    input  wire clk,
    input  wire rst,
    input  wire btn,

    output reg  btn_db
);

    parameter CLK_FREQ = 100_000_000;
    parameter DEBOUNCE_MS = 1;

    localparam integer COUNT_MAX =
        (CLK_FREQ / 1000) * DEBOUNCE_MS;

    reg sync1;
    reg sync2;

    reg [31:0] count;

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            sync1  <= 1'b0;
            sync2  <= 1'b0;

            btn_db <= 1'b0;

            count  <= 32'd0;

        end

        else begin

            // Synchronizer
            sync1 <= btn;
            sync2 <= sync1;


            // Button changed
            if (sync2 != btn_db) begin

                if (count >= COUNT_MAX - 1) begin

                    btn_db <= sync2;
                    count  <= 32'd0;

                end

                else begin

                    count <= count + 1'b1;

                end

            end

            else begin

                count <= 32'd0;

            end

        end

    end

endmodule
