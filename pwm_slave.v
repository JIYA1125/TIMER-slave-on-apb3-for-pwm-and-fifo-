`timescale 1ns / 1ps

module pwm_slave (

    input wire        clk,
    input wire        rst,

    input wire        psel,
    input wire        penable,
    input wire        pwrite,

    input wire [7:0]  pwdata,

    output wire [7:0] prdata,
    output wire       pready,
    output wire       pslverr,

    output wire       pwm_start,
    input wire        pwm_enable,

    output wire       pwm_out
);

    reg [1:0] duty_select;

    reg [7:0] duty_value;

    reg [15:0] pwm_counter;


    //========================================================
    // APB
    //========================================================

    assign pready =
            psel &&
            penable;

    assign pslverr = 1'b0;

    assign prdata = {
        6'd0,
        duty_select
    };


    //========================================================
    // PWM START
    //========================================================

    assign pwm_start =
            psel &&
            penable &&
            pwrite;


    //========================================================
    // DUTY REGISTER
    //========================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            duty_select <= 2'b00;
            duty_value  <= 8'd64;

        end

        else if (psel && penable && pwrite) begin

            duty_select <= pwdata[1:0];

            case (pwdata[1:0])

                2'b00:
                    duty_value <= 8'd64;   // 25%

                2'b01:
                    duty_value <= 8'd128;  // 50%

                2'b10:
                    duty_value <= 8'd192;  // 75%

                2'b11:
                    duty_value <= 8'd255;  // 100%

                default:
                    duty_value <= 8'd64;

            endcase

        end

    end


    //========================================================
    // PWM COUNTER
    //========================================================

    always @(posedge clk or posedge rst) begin

        if (rst)

            pwm_counter <= 16'd0;

        else

            pwm_counter <= pwm_counter + 1'b1;

    end


    //========================================================
    // PWM OUTPUT
    //========================================================

    assign pwm_out =
            pwm_enable &&
            (pwm_counter[7:0] < duty_value);

endmodule
