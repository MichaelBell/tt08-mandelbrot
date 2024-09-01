`default_nettype none

/** 
 * Calculate one iteration of the Mandelbrot set function over 2 clocks:
 * x_out = x_in^2 - y_in^2 + x0
 * y_out = 2 * x_in * y_in + y0
 * escape = x_in^2 + y_in^2 > 4
 *
 * All values are signed fixed point integers with 3 bits before the fixed point
 */
module mandel_iter #(parameter BITS=18) (
    input clk,
    input phase,
    input signed [2:-(BITS-3)] x0,
    input signed [2:-(BITS-3)] y0,
    input signed [2:-(BITS-3)] x_in,
    input signed [2:-(BITS-3)] y_in,
    output wire signed [2:-(BITS-3)] x_out,
    output wire signed [2:-(BITS-3)] y_out,
    output reg escape
);

    wire [2:-(BITS-3)] sq_in;
    wire [4:-(BITS-2)] sq_out;
    wire [4:-(BITS-2)] x_square;
    wire [4:-(BITS-2)] y_square;

/* verilator lint_off UNUSEDSIGNAL */
    wire signed [5:-(BITS-2)] x_y;

    reg signed [3:-(BITS-2)] x_out_reg;
    reg signed [3:-(BITS-3)] y_out_reg;
/* verilator lint_on UNUSEDSIGNAL */    

    assign sq_in = phase ? y_in : x_in;

    approx_square #(.BITS(BITS)) i_sq (
        .x(sq_in),
        .x2(sq_out)
    );

    latch_reg #(.WIDTH(3+BITS)) l_sq(
        .clk(clk),
        .wen(!phase),
        .data_in(sq_out),
        .data_out(x_square)
    );

    assign y_square = sq_out;

    approx_mul #(.BITS(BITS)) i_xy (
        .clk(clk),
        .phase(phase),
        .x(x_in),
        .y(y_in),
        .xy(x_y)
    );

    always @(*) begin
        escape = x_square[4:-10] + y_square[4:-10] > 15'h1000;
        x_out_reg = x_square[3:-(BITS-2)] - y_square[3:-(BITS-2)] + {x0[2], x0, 1'b0};
        y_out_reg = x_y[2:-(BITS-2)] + {y0[2], y0};
    end

    assign x_out = x_out_reg[2:-(BITS-3)];
    assign y_out = y_out_reg[2:-(BITS-3)];

endmodule
