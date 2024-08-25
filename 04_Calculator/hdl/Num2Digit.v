`timescale 1ns / 1ps
/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.08.24
******************************************************************************/

module Num2Digit(
input        clk,
input        reset,
input [27:0] cal_ans,
input        cal_done,
output reg [7:0] dig_0_ans,
output reg [7:0] dig_1_ans,
output reg [7:0] dig_2_ans,
output reg [7:0] dig_3_ans
    );

reg  [16+28-1:0] shift_reg, shift_reg_n;
wire [16+28-1:0] shift_tmp;
reg  [1:0]       double_dabble_state, double_dabble_state_n;
reg  [4:0]       shift_cnt, shift_cnt_n;

wire [3:0]       digit_3_plus3;
wire [3:0]       digit_2_plus3;
wire [3:0]       digit_1_plus3;
wire [3:0]       digit_0_plus3;

localparam IDLE = 2'd0;
localparam SHFT = 2'd1;
localparam ADD3 = 2'd2;
localparam OUTP = 2'd3;

assign digit_3_plus3 = shift_reg[43:40] + 4'd3;
assign digit_2_plus3 = shift_reg[39:36] + 4'd3;
assign digit_1_plus3 = shift_reg[35:32] + 4'd3;
assign digit_0_plus3 = shift_reg[31:28] + 4'd3;

assign shift_tmp[43:40] = (shift_reg[43:40] > 4'd4) ? digit_3_plus3 : shift_reg[43:40];
assign shift_tmp[39:36] = (shift_reg[39:36] > 4'd4) ? digit_2_plus3 : shift_reg[39:36];
assign shift_tmp[35:32] = (shift_reg[35:32] > 4'd4) ? digit_1_plus3 : shift_reg[35:32];
assign shift_tmp[31:28] = (shift_reg[31:28] > 4'd4) ? digit_0_plus3 : shift_reg[31:28];
assign shift_tmp[27:0]  = shift_reg[27:0];

// Double Dabble Algoritm
always@*begin
    shift_cnt_n = shift_cnt;
    shift_reg_n = shift_reg;
    double_dabble_state_n = double_dabble_state;
    case(double_dabble_state)
        IDLE: begin
            shift_cnt_n = 5'd28;
            shift_reg_n = {4'd0, 4'd0, 4'd0, 4'd0, cal_ans};
            double_dabble_state_n = cal_done ? SHFT : IDLE;
        end
        SHFT: begin
            if(shift_cnt==5'd0)begin
                shift_cnt_n = 5'd0;
                shift_reg_n = shift_reg;
                double_dabble_state_n = OUTP;
            end else begin
                shift_cnt_n = shift_cnt - 3'd1;
                shift_reg_n = shift_tmp <<< 1'd1;
                double_dabble_state_n = SHFT;
            end
        end
        OUTP: double_dabble_state_n = cal_done == 1'd0 ? IDLE : OUTP;
    endcase
end

always@(posedge clk)begin
    if(~reset)begin
        dig_3_ans            <=  8'd0;
        dig_2_ans            <=  8'd0;
        dig_1_ans            <=  8'd0;
        dig_0_ans            <=  8'd0;
        shift_cnt            <=  5'd0;
        shift_reg            <= 44'd0;
        double_dabble_state  <=  4'd0;
    end else begin
        dig_3_ans            <= {4'd0, shift_reg[43:40]};
        dig_2_ans            <= {4'd0, shift_reg[39:36]};
        dig_1_ans            <= {4'd0, shift_reg[35:32]};
        dig_0_ans            <= {4'd0, shift_reg[31:28]};
        shift_cnt            <= shift_cnt_n;
        shift_reg            <= shift_reg_n;
        double_dabble_state  <= double_dabble_state_n;
    end
end

    
endmodule
