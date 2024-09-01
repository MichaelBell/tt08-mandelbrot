/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_MichaelBell_mandelbrot (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Handle input
  wire [1:-12] value_in = {uio_in[5:0], ui_in};
  wire input_x   = uio_in[6];
  wire in_enable = uio_in[7];

  localparam BITS = 16;

  reg signed [2:-(BITS-3)] x0;
  reg signed [2:-(BITS-3)] y0;
  reg signed [2:-(BITS-3)] x;
  reg signed [2:-(BITS-3)] y;
  reg [6:0] iter;

  wire signed [2:-(BITS-3)] x_out;
  wire signed [2:-(BITS-3)] y_out;
  wire escape;
  reg escape_r;

  assign uo_out = {escape_r, iter};

  reg phase;

  mandel_iter #(.BITS(BITS)) i_mandel (
    .clk(clk),
    .phase(phase),
    .x0(x0),
    .y0(y0),
    .x_in(x),
    .y_in(y),
    .x_out(x_out),
    .y_out(y_out),
    .escape(escape)
  );

  always @(posedge clk) begin
    if (!rst_n) begin
      iter <= 0;
    end else if (in_enable) begin
      if (input_x) begin
        x0 <= {value_in[1], value_in, {BITS-15{1'b0}}};
        x  <= {value_in[1], value_in, {BITS-15{1'b0}}};
      end else begin
        y0 <= {value_in[1], value_in, {BITS-15{1'b0}}};
        y  <= {value_in[1], value_in, {BITS-15{1'b0}}};
      end
      iter <= 0;
      phase <= 0;
      escape_r <= 0;
    end else begin
      phase <= !phase;
      if (phase) begin
        if (!escape && iter != 7'h7f) begin
          iter <= iter + 1;
          x <= x_out;
          y <= y_out;
        end
        escape_r <= escape;
      end
    end
  end
endmodule
