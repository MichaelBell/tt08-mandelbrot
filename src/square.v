`default_nettype none

module approx_square #(parameter BITS=16) (
    input signed [2:-(BITS-3)] x,
    output wire [4:-(BITS-2)] x2
);

    wire signed [5:-BITS-2] hihi = $signed(x[2:-BITS/2-1]) * $signed(x[2:-BITS/2-1]);

    wire signed [2:-6] hi_corrected = x[2] ? (x[2:-6] + 1) : x[2:-6];

    /* verilator lint_off UNUSEDSIGNAL */
    wire signed [1-BITS/2:-BITS-3] lohi = hi_corrected * $signed({1'b0,x[-BITS/2-2:-(BITS-3)]});

    wire signed [6:-BITS-2] result = hihi + {{(3+BITS/2){lohi[1-BITS/2]}}, lohi[1-BITS/2:-BITS-3]};
    /* verilator lint_on UNUSEDSIGNAL */

    assign x2 = result[4:-(BITS-2)];

`ifdef FORMAL
    reg past_valid = 0;
    wire signed [5:-(2*BITS-6)] x2_exact = x * x;
    wire signed [5:-(2*BITS-6)] x2_padded = {1'b0, x2, {(BITS-4){1'b0}}};
    wire signed [5:-(2*BITS-6)] diff = x2_exact - x2_padded;
    int error = BITS <= 16 ? 1 : 1 << (BITS - 16);
    initial assert($signed(diff[5:-(BITS-2)]) <= error);
    initial assert($signed(diff[5:-(BITS-2)]) >= -error);
`endif
endmodule
