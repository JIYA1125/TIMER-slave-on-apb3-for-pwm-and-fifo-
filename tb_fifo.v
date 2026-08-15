`timescale 1ns / 1ps

module tb_fifo;

    reg clk;
    reg rst;

    reg wr_en;
    reg rd_en;

    reg [7:0] data_in;

    wire [7:0] data_out;

    wire full;
    wire empty;


    FIFO dut (

        .clk(clk),
        .rst(rst),

        .wr_en(wr_en),
        .rd_en(rd_en),

        .data_in(data_in),

        .data_out(data_out),

        .full(full),
        .empty(empty)

    );


    // 100 MHz clock
    always #5 clk = ~clk;


    initial begin

        clk = 0;

        rst = 1;

        wr_en = 0;
        rd_en = 0;

        data_in = 0;


        #100;

        rst = 0;


        //================================================
        // WRITE 5
        //================================================

        @(posedge clk);

        data_in = 8'd5;
        wr_en = 1;

        @(posedge clk);

        wr_en = 0;


        //================================================
        // WRITE 10
        //================================================

        @(posedge clk);

        data_in = 8'd10;
        wr_en = 1;

        @(posedge clk);

        wr_en = 0;


        //================================================
        // WRITE 15
        //================================================

        @(posedge clk);

        data_in = 8'd15;
        wr_en = 1;

        @(posedge clk);

        wr_en = 0;


        #50;


        //================================================
        // READ
        //================================================

        @(posedge clk);

        rd_en = 1;

        @(posedge clk);

        rd_en = 0;


        #20;

        $display("FIFO DATA = %d", data_out);


        @(posedge clk);

        rd_en = 1;

        @(posedge clk);

        rd_en = 0;


        #20;

        $display("FIFO DATA = %d", data_out);


        @(posedge clk);

        rd_en = 1;

        @(posedge clk);

        rd_en = 0;


        #20;

        $display("FIFO DATA = %d", data_out);


        #100;

        $finish;

    end

endmodule
