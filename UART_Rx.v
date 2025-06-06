module uart_rx #(
    parameter CLOCK_FREQ = 50000000,
    parameter BAUD_RATE  = 9600
)(
    input clk,
    input rst,
    input rx,              // Serial input line
    output reg [7:0] data_out,
    output reg data_valid  // High for 1 clock when byte is received
);

    localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    // FSM states
    localparam STATE_IDLE       = 3'd0;
    localparam STATE_START_BIT  = 3'd1;
    localparam STATE_DATA_BITS  = 3'd2;
    localparam STATE_STOP_BIT   = 3'd3;
    localparam STATE_DONE       = 3'd4;

    reg [2:0] state = STATE_IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] rx_shift_reg = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= STATE_IDLE;
            clk_count   <= 0;
            bit_index   <= 0;
            rx_shift_reg<= 0;
            data_out    <= 0;
            data_valid  <= 0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    data_valid <= 0;
                    clk_count  <= 0;
                    bit_index  <= 0;

                    if (rx == 0)  // Detected start bit edge
                        state <= STATE_START_BIT;
                end

                STATE_START_BIT: begin
                    if (clk_count == (CLKS_PER_BIT / 2)) begin
                        // Sample in middle of start bit to confirm it's still 0
                        if (rx == 0) begin
                            clk_count <= 0;
                            state <= STATE_DATA_BITS;
                        end else begin
                            state <= STATE_IDLE;  // False start bit
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STATE_DATA_BITS: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_shift_reg[bit_index] <= rx;

                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state <= STATE_STOP_BIT;
                        end
                    end
                end

                STATE_STOP_BIT: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= STATE_DONE;
                    end
                end

                STATE_DONE: begin
                    data_out   <= rx_shift_reg;
                    data_valid <= 1;
                    state      <= STATE_IDLE;
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule