/*
 * Copyright (c) 2024 Michael Bell
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
  wire _unused = &{ena, ui_in, uio_in, 1'b0};

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  localparam BITS = 16;

  localparam max_step = 27;

  reg signed [2:-(BITS-3)] x0;
  reg signed [1:-(BITS-3)] y0;
  wire signed [2:-(BITS-3)] next_x0;
  wire signed [1:-(BITS-3)] next_y0;
  wire signed [2:-(BITS-3)] next_x0_with_blank;
  wire signed [1:-(BITS-3)] next_y0_with_blank;

  wire next_pixel;
  wire next_frame;
  wire next_row;

  coord_control #(.BITS(BITS)) i_coord(
    .clk(clk),
    .rst_n(rst_n),
    .next_row(next_row),
    .next_frame(next_frame),
    .value({uio_in, ui_in[7:3]}),
    .ctrl(ui_in[2:0]),
    .x0(x0),
    .y0(y0),
    .next_x0(next_x0),
    .next_y0(next_y0)
  );

  reg signed [2:-(BITS-3)] x;
  reg signed [2:-(BITS-3)] y;
  reg [3:0] iter;
  reg [3:0] last_iter;
  
  wire [3:0] next_iter;

  wire signed [2:-(BITS-3)] x_out;
  wire signed [2:-(BITS-3)] y_out;
  wire escape;

  reg [4:0] step;

  mandel_iter #(.BITS(BITS)) i_mandel (
    .clk(clk),
    .phase(step[0]),
    .x0(x0),
    .y0({y0[1], y0}),
    .x_in(x),
    .y_in(y),
    .x_out(x_out),
    .y_out(y_out),
    .escape(escape)
  );

  wire vga_blank;

  assign next_pixel = step[1:0] == 2'b11;

  vga i_vga (
    .clk        (clk),
    .reset_n    (rst_n),
    .advance    (next_pixel),
    .hsync      (uo_out[7]),
    .vsync      (uo_out[3]),
    .blank      (vga_blank),
    .hsync_pulse(next_row),
    .vsync_pulse(next_frame)
  );

  assign next_iter = iter + (escape ? 0 : 1);

  always @(posedge clk) begin
    if (!rst_n) step <= 0;
    else begin
      step <= step + 1;
      if (step == max_step) step <= 0;
    end
  end

  assign next_x0_with_blank = vga_blank ? x0 : next_x0;
  assign next_y0_with_blank = vga_blank ? y0 : next_y0;

  always @(posedge clk) begin
    if (next_row || next_frame) begin
      x0 <= next_x0;
      y0 <= next_y0;
    end else begin
      if (step[0]) begin
        iter <= next_iter;
        if (step[4:1] == max_step[4:1]) begin
          last_iter <= next_iter;
          iter <= 0;
          x0 <= next_x0_with_blank;
          y0 <= next_y0_with_blank;
          x <= next_x0_with_blank;
          y <= {next_y0_with_blank[1], next_y0_with_blank};
        end else if (!escape) begin
          x <= x_out;
          y <= y_out;
        end
      end
    end
  end

    function [5:0] rainbow(input [3:0] idx);
        case (idx)
 0: rainbow = 6'h23;
 1: rainbow = 6'h32;
 2: rainbow = 6'h31;
 3: rainbow = 6'h30;
 4: rainbow = 6'h34;
 5: rainbow = 6'h38;
 6: rainbow = 6'h2c;
 7: rainbow = 6'h1c;
 8: rainbow = 6'h0c;
 9: rainbow = 6'h0d;
10: rainbow = 6'h0e;
11: rainbow = 6'h0b;
12: rainbow = 6'h07;
13: rainbow = 6'h03;
14: rainbow = 6'h00;
15: rainbow = 6'hx;
        endcase
    endfunction  

  wire [5:0] video_colour;
  assign video_colour = rainbow(last_iter);

  assign uo_out[0] = vga_blank ? 1'b0 : video_colour[5];
  assign uo_out[1] = vga_blank ? 1'b0 : video_colour[3];
  assign uo_out[2] = vga_blank ? 1'b0 : video_colour[1];
  assign uo_out[4] = vga_blank ? 1'b0 : video_colour[4];
  assign uo_out[5] = vga_blank ? 1'b0 : video_colour[2];
  assign uo_out[6] = vga_blank ? 1'b0 : video_colour[0];  

endmodule
