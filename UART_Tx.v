module uart_tx #(
    parameter CLOCK_FREQ = 50000000,  // 50 MHz
    parameter BAUD_RATE  = 9600
)(
    input clk,
    input rst,
    input [7:0] data_in,
    input start,
    output reg tx,
    output reg busy
);

    localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    // Define FSM States using localparam
    localparam STATE_IDLE      = 3'd0;
    localparam STATE_START_BIT = 3'd1;
    localparam STATE_DATA_BITS = 3'd2;
    localparam STATE_STOP_BIT  = 3'd3;
    localparam STATE_CLEANUP   = 3'd4;

    reg [2:0] state = STATE_IDLE;

    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] tx_data   = 8'd0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= STATE_IDLE;
            clk_count <= 0;
            bit_index <= 0;
            tx_data   <= 8'd0;
            tx        <= 1'b1; // Idle line is high
            busy      <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    tx        <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;
                    busy      <= 1'b0;

                    if (start) begin
                        busy    <= 1'b1;
                        tx_data <= data_in;
                        state   <= STATE_START_BIT;
                    end
                end

                STATE_START_BIT: begin
                    tx <= 1'b0;  // Start bit

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= STATE_DATA_BITS;
                    end
                end

                STATE_DATA_BITS: begin
                    tx <= tx_data[bit_index];

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state <= STATE_STOP_BIT;
                        end
                    end
                end

                STATE_STOP_BIT: begin
                    tx <= 1'b1;  // Stop bit

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= STATE_CLEANUP;
                    end
                end

                STATE_CLEANUP: begin
                    busy <= 1'b0;
                    state <= STATE_IDLE;
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule