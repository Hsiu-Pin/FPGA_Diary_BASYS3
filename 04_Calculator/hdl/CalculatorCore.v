`timescale 1ns / 1ps
/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.08.24
******************************************************************************/

module CalculatorCore(
input             clk,
input             reset,
input      [ 2:0] operation,

input      [ 7:0] dig_0_in,
input      [ 7:0] dig_1_in,
input      [ 7:0] dig_2_in,
input      [ 7:0] dig_3_in,

output reg        cal_done,
output reg [27:0] cal_ans
    );
    
wire [13:0] tmp;
reg  [27:0] cal_ans_n;
reg  [ 1:0] cal_state, cal_state_n;
reg  [ 2:0] operation_store;

localparam IDLE = 2'd0;
localparam WAIT = 2'd1;
localparam CALC = 2'd2;
localparam OUTP = 2'd3;

localparam ENTER = 3'd1;
localparam PLUS  = 3'd2;
localparam MINUS = 3'd3;
localparam MULT  = 3'd4;
localparam DIV   = 3'd5;
localparam ESC   = 3'd6;

// 1: Enter
// 2: + 
// 3: - 
// 4: * 
// 5: /
// 6: ESC

always@*begin
    cal_state_n = cal_state;
    case(cal_state)
        IDLE: begin
            if     (operation == ENTER) cal_state_n = IDLE;
            else if(operation == ESC)   cal_state_n = IDLE;
            else if(operation != 3'd0)  cal_state_n = WAIT;
        end
        WAIT: begin
            if     (operation == ENTER) cal_state_n = CALC;
            else if(operation == ESC)   cal_state_n = IDLE;
            else                        cal_state_n = WAIT;
        end
        CALC: cal_state_n = OUTP;
        OUTP: cal_state_n = (operation == ESC) ? IDLE : OUTP;
    endcase
end

// From 4-digit to 1 Number
assign tmp = dig_0_in + (dig_1_in*10) + (dig_2_in*100) + (dig_3_in*1000);

always@*begin 
    cal_ans_n = cal_ans; // IDLE                       
    if(cal_state == IDLE)begin
        cal_ans_n = {14'd0, tmp}; // IDLE
    end else if(cal_state == CALC)begin
        case(operation_store)
            3'd2: cal_ans_n = cal_ans + tmp;
            3'd3: cal_ans_n = cal_ans - tmp;
            3'd4: cal_ans_n = cal_ans * tmp; // huge circuit
            3'd5: cal_ans_n = cal_ans / tmp; // huge circuit
            default: cal_ans_n = {14'd0, tmp};
        endcase
    end 
end

always@(posedge clk)begin
    if(~reset)begin
        operation_store <= 3'd0;
        cal_state       <= 2'd0;
        cal_done        <= 1'd0;
        cal_ans         <= 28'd0;
    end else begin
        operation_store <= cal_state == IDLE ? operation : operation_store;
        cal_state       <= cal_state_n;
        cal_done        <= (cal_state == OUTP);
        cal_ans         <= cal_ans_n;
    end
end
    
    
endmodule
