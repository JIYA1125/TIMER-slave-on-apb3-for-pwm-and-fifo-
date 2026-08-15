`timescale 1ns / 1ps

module FIFO (

    input wire       clk,
    input wire       rst,

    input wire       wr_en,
    input wire       rd_en,

    input wire [7:0] data_in,

    output wire [7:0] data_out,

    output wire       full,
    output wire       empty
);

    reg [7:0] mem [0:7];

    reg [2:0] wr_ptr;
    reg [2:0] rd_ptr;

    reg [3:0] count;

    integer i;

    // Current FIFO front item
    assign data_out = empty ? 8'd0 : mem[rd_ptr];

    assign full  = (count == 4'd8);
    assign empty = (count == 4'd0);


    always @(posedge clk or posedge rst) begin

        if (rst) begin

            wr_ptr <= 3'd0;
            rd_ptr <= 3'd0;
            count  <= 4'd0;

            for (i = 0; i < 8; i = i + 1)
                mem[i] <= 8'd0;

        end

        else begin

            // WRITE
            if (wr_en && !full) begin

                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;

            end


            // READ
            if (rd_en && !empty) begin

                rd_ptr <= rd_ptr + 1'b1;

            end


            // COUNT
            case ({wr_en && !full, rd_en && !empty})

                2'b10:
                    count <= count + 1'b1;

                2'b01:
                    count <= count - 1'b1;

                default:
                    count <= count;

            endcase

        end

    end

endmodule
