`timescale 1ns / 1ps

module fifo_timer (

    input  wire       clk,
    input  wire       rst,

    input  wire       start,
    input  wire       stop,

    output reg        running,
    output reg [6:0]  seconds
);

    parameter CLK_FREQ = 100_000_000;

    reg [26:0] clk_count;

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            clk_count <= 27'd0;
            seconds   <= 7'd0;
            running   <= 1'b0;
        end

        else begin

            // WRITE starts/restarts the elapsed timer
            if (start) begin

                clk_count <= 27'd0;
                seconds   <= 7'd0;
                running   <= 1'b1;

            end

            // READ stops the timer
            else if (stop) begin

                running <= 1'b0;

            end

            // Timer running
            else if (running) begin

                if (clk_count == CLK_FREQ - 1) begin

                    clk_count <= 27'd0;

                    // Maximum display value = 99 seconds
                    if (seconds < 7'd99)
                        seconds <= seconds + 1'b1;

                end

                else begin

                    clk_count <= clk_count + 1'b1;

                end

            end

        end

    end

endmodule
