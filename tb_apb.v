`timescale 1ns / 1ps

module tb_apb;

    reg clk;
    reg rst;

    reg start;
    reg rw;

    reg [15:0] command_data;

    wire pready;
    wire pslverr;

    wire [7:0] prdata;

    wire psel;
    wire penable;
    wire pwrite;

    wire [7:0] paddr;
    wire [7:0] pwdata;

    wire [7:0] read_data;

    wire done;
    wire error;


    reg slave_ready;
    reg [7:0] slave_data;


    apb3_master dut (

        .clk(clk),
        .rst(rst),

        .start(start),
        .rw(rw),

        .command_data(command_data),

        .pready(pready),
        .pslverr(pslverr),
        .prdata(prdata),

        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),

        .paddr(paddr),
        .pwdata(pwdata),

        .read_data(read_data),

        .done(done),
        .error(error)

    );


    assign pready = slave_ready;

    assign prdata = slave_data;

    assign pslverr = 1'b0;


    always #5 clk = ~clk;


    initial begin

        clk = 0;

        rst = 1;

        start = 0;
        rw = 1;

        command_data = 16'd0;

        slave_ready = 0;
        slave_data = 8'd0;


        #30;

        rst = 0;


        //================================================
        // APB WRITE
        // Address = 20h
        // Data    = 5
        //================================================

        @(posedge clk);

        command_data = {8'd5, 8'h20};

        rw = 1;

        start = 1;

        @(posedge clk);

        start = 0;


        #30;

        slave_ready = 1;


        @(posedge clk);

        slave_ready = 0;


        #30;


        //================================================
        // APB READ
        //================================================

        @(posedge clk);

        command_data = {8'd0, 8'h20};

        rw = 0;

        start = 1;

        @(posedge clk);

        start = 0;


        #30;

        slave_data = 8'd5;

        slave_ready = 1;


        @(posedge clk);

        slave_ready = 0;


        #50;


        $display(
            "APB READ DATA = %d",
            read_data
        );


        $finish;

    end

endmodule
