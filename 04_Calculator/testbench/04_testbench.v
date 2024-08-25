`timescale 1ns / 1ns
module testbench;

// Declaration
reg reset, clk;

wire [2:0] an_out_0;
wire [7:0] sg_out_0;

wire usb_uart_txd;
wire usb_uart_rxd;

always #5 clk = ~clk;

// Test
initial begin
    clk = 0;
    reset = 0;
     
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;
    
end

// Module Connection
design_1_wrapper design_1_wrapper
(
    .sys_clock                 (clk),
    .reset                     (reset),
    .sg_out_0                  (sg_out_0),
    .an_out_0                  (an_out_0),
    .usb_uart_rxd              (usb_uart_rxd),
    .usb_uart_txd              (usb_uart_txd)
);

endmodule
