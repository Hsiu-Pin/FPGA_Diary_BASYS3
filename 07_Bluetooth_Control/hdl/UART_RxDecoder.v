/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.09.13 (Cambridge)
* Description:
* - This module generates decoded 8-bit UART Rx data.
* - This module requires a 10 MHz clock input for proper operation.
* - This module only supports a baud rate of 9600.
* - Supported UART format:
*   - Start  bit: 1-bit
*   - Data   bit: 8-bit
*   - Parity bit: None
*   - Stop   bit: 1-bit
******************************************************************************/

module UART_RxDecoder(
    input            clk_10Hz, // 10 MHz clock (period = 100 ns)
    input            reset,    // Active-low reset signal
    input            rx_bit,   // 1-bit serial UART input
    output reg [7:0] rx_dec    // 8-bit decoded UART data output
    );
  
// ==================================================================
// Declaration
// ==================================================================

    // FSM parameters
    localparam IDLE = 1'd0;
    localparam SAMP = 1'd1;

    // 2-stage synchronizer between the asynchronous UART and 10 MHz clock
    reg        rx_bit_sync1, rx_bit_sync2;

    reg        rx_state,     rx_state_n;  // Rx decode state
    reg [10:0] sync_cnt,     sync_cnt_n;  // Counter to synchronize with 9600 baud rate
    reg [ 7:0] samp_cnt,     samp_cnt_n;  // Counter to sample signal level to determine 1 or 0
    reg [ 3:0] bit_cnt,      bit_cnt_n;   // Counter for output bits [0] ~ [7]
    wire       is_one;                    // If "samp_cnt" is high enough, assert this flag for a 1.
    wire       stop_det;                  // Flag for stop bit detection
    reg [ 7:0] rx_dec_pre;
    
    reg [ 3:0] i;
    
// ==================================================================
// 2-Stage Syncronizer
// ==================================================================

    always@(posedge clk_10Hz)begin
        if(~reset)begin
           rx_bit_sync1  <=  1'b1;  
           rx_bit_sync2  <=  1'b1;  
        end else begin
           rx_bit_sync1  <=  rx_bit;  
           rx_bit_sync2  <=  rx_bit_sync1;  
        end
    end
   
// ==================================================================
// UART Sync Counter and its FSM
// - IDLE state:
//     - In this state, if the input bit is 0, the samp_cnt increments.
//     - If samp_cnt > 16 (any small number), it indicates that a 0 (Start bit) has been detected. 
//
// - SAMP state:
//     - Calculations:
//       9600 Baud = 9600 bits/second, cycle period = 1/9600 ≈ 104,000 ns.
//       For every input Rx bit, the sync_cnt toggles 104,000/100 = 1040 times.
//       1040 = 11'b100_0001_0000.
//     - When (sync_cnt[10] && sync_cnt[5]), 
//         1. Reset sync_cnt and sample the next bit.
//         2. Increment bit_cnt.
//
// - stop_det state:
//     - When bit_cnt == 9, it indicates the current bit should be a stop bit.
//     - If samp_cnt == 255, it indicates a 1 (stop bit).
//     - Jump to IDLE for the next round when the start bit is detected.
//      
// - Example:
// ------            ------ .........------|-------------
//      | start bit  |      data bits          stop bit
//      | bit_cnt=0  |    bit_cnt = 1~8        bit_cnt=9
//      --------------        
//       <1040 cycles>    <1040 cycles>*8     <1040 cycles>
// ==================================================================

    assign stop_det = rx_state==SAMP && bit_cnt == 4'd9 && &samp_cnt;

    always@*begin
        rx_state_n = rx_state;
        sync_cnt_n = sync_cnt;
        bit_cnt_n  = bit_cnt;
        case(rx_state)
            IDLE:begin
                rx_state_n = (samp_cnt[5]) ? SAMP : IDLE ;
                sync_cnt_n = 11'd16;
                bit_cnt_n  = 4'd0;
            end
            SAMP:begin
                if(sync_cnt[10] && sync_cnt[5])begin
                    rx_state_n = (stop_det) ? IDLE : SAMP;
                    sync_cnt_n = 11'd0;
                    bit_cnt_n  = bit_cnt + 1'd1;
                end else begin
                    rx_state_n = SAMP;
                    sync_cnt_n = sync_cnt + 1'd1;
                    bit_cnt_n  = bit_cnt;
                end
            end
        endcase
    end

// ==================================================================
// UART Sampler Counter
// - samp_cnt: 
//     - In the IDLE state: 
//       This counter increments if the input Rx bit is 0, used to detect the start bit.
//     - In the SAMP state: 
//       It accumulates based on the input Rx bit.
//       1. If samp_cnt > 255, the current bit is determined to be 1.
//       2. Reset samp_cnt to 0 after each 1040 cycles.
//
// - is_one: 
//     - When samp_cnt == 8'b1111_1111 (255), the current bit is determined to be 1.
// ==================================================================
    
    assign is_one = &samp_cnt;
    
    always@*begin
        if(rx_state==IDLE)begin
            if(samp_cnt[5] || rx_bit_sync2)
                samp_cnt_n = 8'd0;
            else
                samp_cnt_n = samp_cnt + {7'd0, ~rx_bit_sync2};
        end else if(rx_state==SAMP)begin
            if(sync_cnt[10] && sync_cnt[5]) 
                samp_cnt_n = 8'd0;
            else if(&samp_cnt) 
                samp_cnt_n = samp_cnt;
            else          
                samp_cnt_n = samp_cnt + rx_bit_sync2;
        end else begin
            samp_cnt_n = 8'd0;
        end
    end
    
// ==================================================================
// Sequential Logic
// - rx_dec: 
//     - Each bit of rx_dec is assigned based on the current value of bit_cnt.
// ==================================================================

    always@(posedge clk_10Hz)begin
        if(~reset)begin
            rx_state    <=  1'd0;
            sync_cnt    <= 11'd0;
            samp_cnt    <=  8'd0;
            bit_cnt     <=  4'd0;    
            rx_dec      <=  8'd0;
            rx_dec_pre  <=  8'd0;
        end else begin
            rx_state    <= rx_state_n;
            sync_cnt    <= sync_cnt_n;
            samp_cnt    <= samp_cnt_n;
            bit_cnt     <= bit_cnt_n;
            for(i=0;i<8;i=i+1) 
                rx_dec_pre[i] <= (bit_cnt == i+1) ? is_one : rx_dec_pre[i];
            rx_dec      <= rx_state==IDLE ? rx_dec_pre : rx_dec;
        end
    end
        
endmodule