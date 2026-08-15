`timescale 1ns / 1ps

module edge_detector (

    input  wire clk,
    input  wire rst,

    input  wire signal_in,

    output wire pulse
);

    reg signal_d;

    always @(posedge clk or posedge rst) begin

        if (rst)
            signal_d <= 1'b0;

        else
            signal_d <= signal_in;

    end

    assign pulse = signal_in & ~signal_d;

endmodule
