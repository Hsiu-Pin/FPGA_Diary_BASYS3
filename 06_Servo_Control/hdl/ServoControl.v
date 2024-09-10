/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.09.10
* Description:
* - This module generates a 1-bit PWM output to control a servo motor.
* - It supports 6 angle modes: 0(deg), 30, 60, 90, 120, 150, and 180.
* - The module requires a 10 MHz clock input for proper operation.
* - This module is designed for operating the MG996R Digital Servo.
******************************************************************************/

module ServoControl(
    input       clk_10MHz,  // 10MHz = 100ns   
    input       reset,      // Active low reset
    input [2:0] degree,     // 7-angle
    output      servo_pwm   // Output PWM
    );
    
// ==================================================================
// Declaration
// ==================================================================

    // FSM parameters
    localparam IDLE = 2'd0;
    localparam HIGH = 2'd1;
    localparam LOW  = 2'd2;
    
    reg [ 1:0] pwm_state;   // PWM state
    reg [17:0] cnt50Hz;    // Frequency Counter
                    
    wire       flagStop;   // Pulse width end flag
    wire       flag50Hz;   // 50 Hz flag
    reg [ 6:0] stop_point; // Store the specific Pulse width depends on the input degree
 
// ==================================================================
// Stop Point Determination
// - stop_point:
//   This signal determines how many clock cycles of the 10 MHz clock
//   are required to achieve a specific PWM width.
//
// - Example (0-deg position):
//   For a 0-deg position (input degree = 1), the corresponding PWM width is 0.5 ms.
//     - Calculation:
//       0.5 ms / (1 / 10 MHz) = 500 us / 0.1 us = 5000 cycles.
//     - To simplify the comparator, only the most significant 7 bits are used.
//       5000 = 18'b_00_0001_0011_1000_1000 ~= 3'd0, 7'b001_0011, 8'd0 = 4864
//
// - PWM Width Range (MG996R Digital Servo):
//   - According to the specifications, the PWM width should range from 1 ms (0-deg)
//     to 2 ms (180-deg). 
//   - However, in my case, the actual working range is from 0.5 ms (0-deg)
//     to 2.5 ms (180-deg).
// ==================================================================   

    always@*begin
        stop_point = 7'b001_0011;
        case(degree)
            0: stop_point = 0;           // idle
            1: stop_point = 7'b001_0011; //  4864 ~=   0-deg
            2: stop_point = 7'b010_0000; //  8192 ~=  30-deg
            3: stop_point = 7'b010_1101; // 11520 ~=  60-deg
            4: stop_point = 7'b011_1010; // 14848 ~=  90-deg
            5: stop_point = 7'b100_0110; // 17920 ~= 120-deg
            6: stop_point = 7'b101_0010; // 21162 ~= 150-deg
            7: stop_point = 7'b101_1111; // 24320 ~= 180-deg
        endcase
    end

// ==================================================================
// 50Hz Counter
// - cnt50Hz:
//   A counter that counts up to 200,000 cycles.
//     - Calculation:
//       (1 / 50Hz) = 0.02s. 0.02s / 0.1us = 20,000us / 0.1us = 200,000 cycles.
//     - The counter resets when it reaches 200,000 or when the input degree = 0 (IDLE).
//
// - flag50Hz:
//   This signal is asserted when the 50Hz counter reaches 196,608 ~= 200,000.
//     - To simplify the comparator, only the most significant 2 bits are used.
//       200,000 ~= 196,608 = 18'b11_000....
// ==================================================================

    assign flag50Hz = cnt50Hz[17:16] == 2'b11;
    
    always@(posedge clk_10MHz)begin
        if(~reset)begin
            cnt50Hz <= 18'd0;
        end else begin
            if(degree==0)     cnt50Hz <= 18'd0;
            else if(flag50Hz) cnt50Hz <= 18'd0;
            else              cnt50Hz <= cnt50Hz + 1'd1;
        end
    end
    
// ==================================================================
// PWM State Machine
// - pwm_state:
//     - IDLE: When the input degree != 0 (not IDLE), the state transitions to HIGH.
//     - HIGH: This state determines the width of the PWM signal,
//             transitioning to LOW when the stop point is reached (flagStop == 1).
//     - LOW:  The PWM signal remains LOW until the 50Hz period ends.
//
// - flagStop:
//   This signal indicates that the cnt50Hz counter has reached the stop point value,
//   meaning the target PWM width has been achieved.
//
// - servo_pwm:
//   The output PWM signal. 
//   When the state is HIGH, the signal remains high, and vice versa.
// ==================================================================


    assign flagStop  = cnt50Hz[14: 8] == stop_point; // Only compare 7-bit
    assign servo_pwm =      pwm_state == HIGH;

    // FSM
    always@(posedge clk_10MHz)begin
        if(~reset)begin
            pwm_state <= 2'd0;
        end else begin 
            case(pwm_state)
                IDLE: pwm_state <= |degree  ? HIGH : IDLE;
                HIGH: pwm_state <= flagStop ? LOW  : HIGH;
                LOW : pwm_state <= flag50Hz ? HIGH : LOW;
            endcase
        end
    end
    
endmodule
