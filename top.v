`timescale 1ns / 1ps

module top (

    input wire        clk,
    input wire        rst,

    input wire        btnU,
    input wire        btnC,
    input wire        btnD,

    input wire [15:0] sw,

    output wire [9:0] led,

    output wire [3:0] an,
    output wire [6:0] seg,

    output wire       pwm_out
);

    //========================================================
    // BUTTON DEBOUNCE
    //========================================================

    wire btnU_db;
    wire btnC_db;
    wire btnD_db;

    debounce db_U (
        .clk(clk),
        .rst(rst),
        .btn(btnU),
        .btn_db(btnU_db)
    );

    debounce db_C (
        .clk(clk),
        .rst(rst),
        .btn(btnC),
        .btn_db(btnC_db)
    );

    debounce db_D (
        .clk(clk),
        .rst(rst),
        .btn(btnD),
        .btn_db(btnD_db)
    );


    //========================================================
    // EDGE DETECTORS
    //========================================================

    wire fifo_write_cmd;
    wire fifo_read_cmd;
    wire pwm_cmd;

    edge_detector ed_U (
        .clk(clk),
        .rst(rst),
        .signal_in(btnU_db),
        .pulse(fifo_write_cmd)
    );

    edge_detector ed_C (
        .clk(clk),
        .rst(rst),
        .signal_in(btnC_db),
        .pulse(fifo_read_cmd)
    );

    edge_detector ed_D (
        .clk(clk),
        .rst(rst),
        .signal_in(btnD_db),
        .pulse(pwm_cmd)
    );


    //========================================================
    // APB MASTER COMMAND
    //========================================================

    reg [15:0] command_data;
    reg        master_rw;

    wire master_start;

    assign master_start =
            fifo_write_cmd |
            fifo_read_cmd  |
            pwm_cmd;


    always @(*) begin

        command_data = 16'h0000;
        master_rw = 1'b1;

        // FIFO WRITE
        if (fifo_write_cmd) begin

            command_data[15:8] = sw[15:8];
            command_data[7:0]  = 8'h20;

            master_rw = 1'b1;

        end

        // FIFO READ
        else if (fifo_read_cmd) begin

            command_data[15:8] = 8'h00;
            command_data[7:0]  = 8'h20;

            master_rw = 1'b0;

        end

        // PWM
        else if (pwm_cmd) begin

            command_data[15:8] = {6'b000000, sw[1:0]};
            command_data[7:0]  = 8'h30;

            master_rw = 1'b1;

        end

    end


    //========================================================
    // APB MASTER
    //========================================================

    wire       psel;
    wire       penable;
    wire       pwrite;

    wire [7:0] paddr;
    wire [7:0] pwdata;

    wire [7:0] prdata;
    wire       pready;
    wire       pslverr;

    wire [7:0] master_read_data;
    wire       master_done;
    wire       master_error;


    apb3_master master_inst (

        .clk(clk),
        .rst(rst),

        .start(master_start),
        .rw(master_rw),

        .command_data(command_data),

        .pready(pready),
        .pslverr(pslverr),
        .prdata(prdata),

        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),

        .paddr(paddr),
        .pwdata(pwdata),

        .read_data(master_read_data),

        .done(master_done),
        .error(master_error)

    );


    //========================================================
    // DECODER
    //========================================================

    wire fifo_sel;
    wire pwm_sel;

    apb3_decoder decoder_inst (

        .psel(psel),
        .paddr(paddr),

        .fifo_sel(fifo_sel),
        .pwm_sel(pwm_sel)

    );


    //========================================================
    // FIFO
    //========================================================

    wire [7:0] fifo_prdata;

    wire fifo_pready;
    wire fifo_pslverr;

    wire fifo_wr_en;
    wire fifo_rd_en;

    wire [7:0] fifo_data_out;

    wire fifo_full;
    wire fifo_empty;


    apb_fifo_slave fifo_slave_inst (

        .clk(clk),
        .rst(rst),

        .psel(fifo_sel),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),

        .prdata(fifo_prdata),
        .pready(fifo_pready),
        .pslverr(fifo_pslverr),

        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),

        .data_out(fifo_data_out),

        .full(fifo_full),
        .empty(fifo_empty)

    );


    FIFO fifo_inst (

        .clk(clk),
        .rst(rst),

        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),

        .data_in(pwdata),

        .data_out(fifo_data_out),

        .full(fifo_full),
        .empty(fifo_empty)

    );


    //========================================================
    // FIFO TIMER
    //
    // BTNU = START / RESET TIMER
    // BTNC = STOP TIMER
    //========================================================

    wire fifo_timer_running;
    wire [6:0] fifo_seconds;


    fifo_timer fifo_timer_inst (

        .clk(clk),
        .rst(rst),

        .start(fifo_write_cmd),
        .stop(fifo_read_cmd),

        .running(fifo_timer_running),
        .seconds(fifo_seconds)

    );


    //========================================================
    // PWM
    //========================================================

    wire [7:0] pwm_prdata;

    wire pwm_pready;
    wire pwm_pslverr;

    wire pwm_start;

    wire pwm_timer_running;
    wire pwm_timer_done;


    pwm_timer pwm_timer_inst (

        .clk(clk),
        .rst(rst),

        .start(pwm_start),

        .running(pwm_timer_running),

        .done(pwm_timer_done)

    );


    pwm_slave pwm_inst (

        .clk(clk),
        .rst(rst),

        .psel(pwm_sel),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),

        .prdata(pwm_prdata),
        .pready(pwm_pready),
        .pslverr(pwm_pslverr),

        .pwm_start(pwm_start),

        .pwm_enable(pwm_timer_running),

        .pwm_out(pwm_out)

    );


    //========================================================
    // APB RESPONSE
    //========================================================

    assign pready =
            fifo_sel ? fifo_pready :
            pwm_sel  ? pwm_pready :
            1'b0;

    assign pslverr =
            fifo_sel ? fifo_pslverr :
            pwm_sel  ? pwm_pslverr :
            1'b0;

    assign prdata =
            fifo_sel ? fifo_prdata :
            pwm_sel  ? pwm_prdata :
            8'h00;


    //========================================================
    // DISPLAY CONTROL
    //========================================================

    reg [11:0] display_value;

    reg [7:0] last_read_value;

    reg [11:0] last_pwm_value;


    always @(posedge clk or posedge rst) begin

        if (rst) begin

            display_value  <= 12'd0;
            last_read_value <= 8'd0;
            last_pwm_value <= 12'd0;

        end

        else begin

            // Save FIFO value being read
            if (fifo_read_cmd && !fifo_empty) begin

                last_read_value <= fifo_data_out;

            end

            // Save PWM selected duty
            if (pwm_cmd) begin

                case (sw[1:0])

                    2'b00:
                        last_pwm_value <= 12'd25;

                    2'b01:
                        last_pwm_value <= 12'd50;

                    2'b10:
                        last_pwm_value <= 12'd75;

                    2'b11:
                        last_pwm_value <= 12'd100;

                    default:
                        last_pwm_value <= 12'd0;

                endcase

            end


            //================================================
            // DISPLAY PRIORITY
            //================================================

            // FIFO timer running
            if (fifo_timer_running) begin

                display_value <=
                    {5'd0, fifo_seconds};

            end

            // When READ occurs, show the FIFO value
            else if (fifo_read_cmd && !fifo_empty) begin

                display_value <=
                    {4'd0, fifo_data_out};

            end

            // PWM timer running
            else if (pwm_timer_running) begin

                display_value <=
                    {8'd0, pwm_timer_running};

            end

            // PWM selected value
            else if (pwm_cmd) begin

                case (sw[1:0])

                    2'b00:
                        display_value <= 12'd25;

                    2'b01:
                        display_value <= 12'd50;

                    2'b10:
                        display_value <= 12'd75;

                    2'b11:
                        display_value <= 12'd100;

                    default:
                        display_value <= 12'd0;

                endcase

            end

        end

    end


    //========================================================
    // DISPLAY
    //========================================================

    display_mux display_inst (

        .clk(clk),

        .value(display_value),

        .an(an),

        .seg(seg)

    );


    //========================================================
    // LED STATUS
    //========================================================

    assign led[0] = fifo_timer_running;
    assign led[1] = pwm_timer_running;

    assign led[2] = fifo_full;
    assign led[3] = fifo_empty;

    assign led[4] = fifo_write_cmd;
    assign led[5] = fifo_read_cmd;

    assign led[6] = pwm_timer_done;

    // LED7 = timer stopped after read
    assign led[7] = fifo_read_cmd;

    assign led[8] = pwm_timer_running;

    assign led[9] = master_error;

endmodule
