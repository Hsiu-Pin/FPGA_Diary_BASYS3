`timescale 1ns / 1ps
/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.08.22
******************************************************************************/

module DisplayDecoder(
input clk,
input reset,
input [3:0] an_in,
input [7:0] dig_0_in,
input [7:0] dig_1_in,
input [7:0] dig_2_in,
input [7:0] dig_3_in,
output reg [3:0] an_out,
output reg [7:0] sg_out
    );
    
// 7-Seg
//                GFE_DCBA
parameter N0 = 7'b100_0000;  // 0
parameter N1 = 7'b111_1001;  // 1
parameter N2 = 7'b010_0100;  // 2 
parameter N3 = 7'b011_0000;  // 3
parameter N4 = 7'b001_1001;  // 4
parameter N5 = 7'b001_0010;  // 5
parameter N6 = 7'b000_0010;  // 6
parameter N7 = 7'b111_1000;  // 7
parameter N8 = 7'b000_0000;  // 8
parameter N9 = 7'b001_0000;  // 9

reg [7:0] dig_0_dec;
reg [7:0] dig_1_dec;
reg [7:0] dig_2_dec;
reg [7:0] dig_3_dec;

// ===============================================
// Digits Decoder
// ===============================================

// Digit 0 decoder
always@*begin
    case(dig_0_in)
        8'd0: dig_0_dec = {1'd1, N0};
        8'd1: dig_0_dec = {1'd1, N1};
        8'd2: dig_0_dec = {1'd1, N2};
        8'd3: dig_0_dec = {1'd1, N3};
        8'd4: dig_0_dec = {1'd1, N4};
        8'd5: dig_0_dec = {1'd1, N5};
        8'd6: dig_0_dec = {1'd1, N6};
        8'd7: dig_0_dec = {1'd1, N7};
        8'd8: dig_0_dec = {1'd1, N8};
        8'd9: dig_0_dec = {1'd1, N9};
        default: dig_0_dec = 8'b1111_1111;
    endcase
end

// Digit 1 decoder
always@*begin
    case(dig_1_in)
        8'd0: dig_1_dec = {1'd1, N0};
        8'd1: dig_1_dec = {1'd1, N1};
        8'd2: dig_1_dec = {1'd1, N2};
        8'd3: dig_1_dec = {1'd1, N3};
        8'd4: dig_1_dec = {1'd1, N4};
        8'd5: dig_1_dec = {1'd1, N5};
        8'd6: dig_1_dec = {1'd1, N6};
        8'd7: dig_1_dec = {1'd1, N7};
        8'd8: dig_1_dec = {1'd1, N8};
        8'd9: dig_1_dec = {1'd1, N9};
        default: dig_1_dec = 8'b1111_1111;
    endcase
end

// Digit 2 decoder
always@*begin
    case(dig_2_in)
        8'd0: dig_2_dec = {1'd1, N0};
        8'd1: dig_2_dec = {1'd1, N1};
        8'd2: dig_2_dec = {1'd1, N2};
        8'd3: dig_2_dec = {1'd1, N3};
        8'd4: dig_2_dec = {1'd1, N4};
        8'd5: dig_2_dec = {1'd1, N5};
        8'd6: dig_2_dec = {1'd1, N6};
        8'd7: dig_2_dec = {1'd1, N7};
        8'd8: dig_2_dec = {1'd1, N8};
        8'd9: dig_2_dec = {1'd1, N9};
        default: dig_2_dec = 8'b1111_1111;
    endcase
end

// Digit 3 decoder
always@*begin
    case(dig_3_in)
        8'd0: dig_3_dec = {1'd1, N0};
        8'd1: dig_3_dec = {1'd1, N1};
        8'd2: dig_3_dec = {1'd1, N2};
        8'd3: dig_3_dec = {1'd1, N3};
        8'd4: dig_3_dec = {1'd1, N4};
        8'd5: dig_3_dec = {1'd1, N5};
        8'd6: dig_3_dec = {1'd1, N6};
        8'd7: dig_3_dec = {1'd1, N7};
        8'd8: dig_3_dec = {1'd1, N8};
        8'd9: dig_3_dec = {1'd1, N9};
        default: dig_3_dec = 8'b1111_1111;
    endcase
end

// ===============================================
// Anodes Control
// ===============================================

// Counter counts 0~3
reg [11:0] cnt100K; // 100K

always@(posedge clk)          
  if (reset == 1'b0) cnt100K <= 12'd0;
  else               cnt100K <= cnt100K + 1'd1;
  
// Alternate Anodes 
always@(posedge clk)begin          
  if (reset == 1'b0)begin                       
    an_out <= 4'b1111;
  end else begin
    case(cnt100K[11:10])
      0: an_out <= an_in & 4'b1110;
      1: an_out <= an_in & 4'b1101;
      2: an_out <= an_in & 4'b1011;
      3: an_out <= an_in & 4'b0111;
      default: an_out <= an_in & 4'b1110;
    endcase
  end
end 

// Alternate Digits
always@(posedge clk)begin          
  if (reset == 1'b0)begin                       
    sg_out <= 8'b1111_1111;
  end else begin
    case(cnt100K[11:10])
      0: sg_out <= dig_0_dec;
      1: sg_out <= dig_1_dec;
      2: sg_out <= dig_2_dec;
      3: sg_out <= dig_3_dec;
      default: sg_out <= dig_0_dec;
    endcase
  end
end 

endmodule