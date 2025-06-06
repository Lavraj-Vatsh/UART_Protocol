module uart_top #(
    parameter CLOCK_FREQ = 50000000,
    parameter BAUD_RATE  = 9600
)(
    input clk,
    input rst,
    input start,
    input [7:0] data_in,
    output tx,
    output [7:0] data_out,
    output data_valid,
    output busy
);

    // Instantiate UART Transmitter
    uart_tx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .start(start),
        .tx(tx),
        .busy(busy)
    );

    // Instantiate UART Receiver
    uart_rx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx),     // Loopback connection
        .data_out(data_out),
        .data_valid(data_valid)
    );

endmodule