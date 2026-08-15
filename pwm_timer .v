`timescale 1ns / 1ps

module pwm_timer (

    input wire clk,
    input wire rst,

    input wire start,

    output reg running,
    output reg done
);

    parameter CLK_FREQ = 100_000_000;
    parameter RUN_TIME_SECONDS = 5;

    localparam integer MAX_COUNT =
        CLK_FREQ * RUN_TIME_SECONDS;

    reg [31:0] count;

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            count   <= 32'd0;
            running <= 1'b0;
            done    <= 1'b0;

        end

        else begin

            done <= 1'b0;

            if (start) begin

                count   <= 32'd0;
                running <= 1'b1;
                done    <= 1'b0;

            end

            else if (running) begin

                if (count >= MAX_COUNT - 1) begin

                    count   <= 32'd0;
                    running <= 1'b0;
                    done    <= 1'b1;

                end

                else begin

                    count <= count + 1'b1;

                end

            end

        end

    end

endmodule
