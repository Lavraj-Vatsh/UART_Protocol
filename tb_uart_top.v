`timescale 1ns/1ps

module tb_uart_loopback;

    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    reg [7:0] data_in = 8'b00000000;
    wire tx;
    wire [7:0] data_out;
    wire data_valid;
    wire busy;

    // Clock Generation (50MHz = 20ns period)
    always #10 clk = ~clk;

    // Instantiate uart_top
    uart_top #(
        .CLOCK_FREQ(50000000),
        .BAUD_RATE(9600)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .data_out(data_out),
        .data_valid(data_valid),
        .busy(busy)
    );

    initial begin
        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);

        // Reset sequence
        rst = 1; #100;
        rst = 0;

        // Transmit a byte
        @(negedge clk);
        data_in = 8'b10101010;
        start = 1;
        @(negedge clk);
        start = 0;

        // Wait for reception
        wait(data_valid);
        #20;

        // Display result
        $display("Transmitted = %b, Received = %b", data_in, data_out);
        if (data_in == data_out)
            $display("? UART Loopback Successful");
        else
            $display("? UART Loopback Failed");

        #100;
        $finish;
    end
endmodule