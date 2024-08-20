`timescale 1ns / 1ns
module testbench;

// Declaration
reg reset, clk;

wire usb_uart_txd;
wire usb_uart_rxd;

reg  [15:0] dip_switches_16bits_tri_i;
wire [15:0] led_16bits_tri_o;
reg  [3:0]  push_buttons_4bits_tri_i;

always #5 clk = ~clk;

// Test
initial begin
    clk = 0;
    reset = 0;
    push_buttons_4bits_tri_i  =  4'b0000;
    dip_switches_16bits_tri_i = 16'h0000;
     
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;
    
    #10000; 
    @(negedge clk);
    push_buttons_4bits_tri_i  =  4'b0001;
    dip_switches_16bits_tri_i = 16'h1234; 
    
    #10000; 
    @(negedge clk);
    push_buttons_4bits_tri_i  =  4'b0000;
    
    #10000; 
    @(negedge clk);
    push_buttons_4bits_tri_i  =  4'b0001;
    dip_switches_16bits_tri_i = 16'h5678; 
    
    #10000; 
    @(negedge clk);
    push_buttons_4bits_tri_i  =  4'b0000;
    
end

// Module Connection
design_1_wrapper design_1_wrapper
(
    .sys_clock                 (clk),
    .reset                     (reset),
    .dip_switches_16bits_tri_i (dip_switches_16bits_tri_i),
    .led_16bits_tri_o          (led_16bits_tri_o),
    .push_buttons_4bits_tri_i  (push_buttons_4bits_tri_i),
    .usb_uart_rxd              (usb_uart_rxd),
    .usb_uart_txd              (usb_uart_txd)
);



endmodule
