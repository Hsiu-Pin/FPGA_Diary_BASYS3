/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.09.14 (Cambridge, Makespace)
* Description:
* - This module generates serial 1-bit UART Tx data.
* - This module requires a 10 MHz clock input for proper operation.
* - This module only supports a baud rate of 9600.
* - Supported UART format:
*   - Start  bit: 1-bit
*   - Data   bit: 8-bit
*   - Parity bit: None
*   - Stop   bit: 1-bit
******************************************************************************/

module UART_TxEncoder(
    input            clk_10Hz, // 10 MHz clock (period = 100 ns)
    input            reset,    // Active-low reset signal
    input            tx_valid, // Indicating to send the current 8-bit data
    input      [7:0] tx_enc,   // 8-bit encoded UART data input
    output reg       tx_bit    // 1-bit serial UART output
    );

// ==================================================================
// Declaration
// ==================================================================

    // FSM parameters
    localparam IDLE = 1'd0;
    localparam SEND = 1'd1;

    reg        tx_state,     tx_state_n;  // Tx encode state
    reg [10:0] sync_cnt,     sync_cnt_n;  // Counter to synchronize with 9600 baud rate
    reg [ 3:0] bit_cnt,      bit_cnt_n;   // Counter for output bits [0] ~ [7]
    reg        tx_bit_n;
    reg [ 7:0] tx_enc_store;              // Stored the target tx data to be transmitted
    

// ==================================================================
// UART Sync Counter and its FSM
// - IDLE state:
//     - In this state, if the tx_valid is asserted, it starts a tx transaction.
//
// - SEND state:
//     - Calculations:
//       9600 Baud = 9600 bits/second, cycle period = 1/9600 ≈ 104,000 ns.
//       For every input Tx bit, the sync_cnt toggles 104,000/100 = 1040 times.
//       1040 = 11'b100_0001_0000.
//     - When (sync_cnt[10] && sync_cnt[5]), 
//         1. Reset sync_cnt and send the next bit.
//         2. Increment bit_cnt.
//      
// - Example:
// ------            ------ .........------|-------------
//      | start bit  |      data bits          stop bit
//      | bit_cnt=0  |    bit_cnt = 1~8        bit_cnt=9
//      --------------        
//       <1040 cycles>    <1040 cycles>*8     <1040 cycles>*2
// ==================================================================

    always@*begin
        tx_state_n = tx_state;
        sync_cnt_n = sync_cnt;
        bit_cnt_n  = bit_cnt;
        case(tx_state)
            IDLE:begin
                tx_state_n = (tx_valid) ? SEND : IDLE ;
                sync_cnt_n = 11'd0;
                bit_cnt_n  = 4'd0;
            end
            SEND:begin
                if(sync_cnt[10] && sync_cnt[5])begin // count to 1040
                    tx_state_n = (bit_cnt == 4'd10) ? IDLE : SEND;
                    sync_cnt_n = 11'd0;
                    bit_cnt_n  = bit_cnt + 1'd1;
                end else begin
                    tx_state_n = SEND;
                    sync_cnt_n = sync_cnt + 1'd1;
                    bit_cnt_n  = bit_cnt;
                end
            end
        endcase
    end


// ==================================================================
// Tx bit Assignment
// - Output the serial tx bit according to the bit_cnt
// - I use 2 stop-bit here.
// ==================================================================

    always@*begin
        tx_bit_n = tx_bit;
        if(tx_state==IDLE)begin
            tx_bit_n = 1'b1;
        end else begin
            case(bit_cnt)
                4'd0 : tx_bit_n = 1'b0;             // start-bit
                4'd1 : tx_bit_n = tx_enc_store[0];  // bit-0
                4'd2 : tx_bit_n = tx_enc_store[1];  // bit-1
                4'd3 : tx_bit_n = tx_enc_store[2];  // bit-2
                4'd4 : tx_bit_n = tx_enc_store[3];  // bit-3
                4'd5 : tx_bit_n = tx_enc_store[4];  // bit-4
                4'd6 : tx_bit_n = tx_enc_store[5];  // bit-5
                4'd7 : tx_bit_n = tx_enc_store[6];  // bit-6
                4'd8 : tx_bit_n = tx_enc_store[7];  // bit-7
                4'd9 : tx_bit_n = 1'b1;             // stop-bit-0
                4'd10: tx_bit_n = 1'b1;             // stop-bit-1
            endcase
        end
    end

// ==================================================================
// Sequential Logic
// - tx_enc_store: 
//     - Store the target transmitted value.
// ==================================================================

    always@(posedge clk_10Hz)begin
        if(~reset)begin
            tx_state     <=  1'd0;
            sync_cnt     <= 11'd0;
            bit_cnt      <=  4'd0;    
            tx_bit       <=  1'b1;
            tx_enc_store <=  8'd0;
        end else begin
            tx_state     <= tx_state_n;
            sync_cnt     <= sync_cnt_n;
            bit_cnt      <= bit_cnt_n;
            tx_bit       <= tx_bit_n;
            tx_enc_store <= tx_state == IDLE ? tx_enc : tx_enc_store;
        end
    end
        
endmodule