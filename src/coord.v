`default_nettype none

`define CTRL_DEMO 3'b000
`define CTRL_SET_LEFT 3'b001
`define CTRL_SET_TOP 3'b010
`define CTRL_NONE 3'b011
`define CTRL_SET_INC_COL_X 3'b100
`define CTRL_SET_INC_COL_Y 3'b101
`define CTRL_SET_INC_ROW_X 3'b110
`define CTRL_SET_INC_ROW_Y 3'b111

/** 
 * Control coordinates for Mandelbrot
 */
module coord_control #(parameter BITS=16) (
    input clk,
    input rst_n,
    input next_row,
    input next_frame,
    input [12:0] value,
    input [2:0] ctrl,
    input signed [2:-(BITS-3)] x0,
    input signed [1:-(BITS-3)] y0,
    output signed [2:-(BITS-3)] next_x0,
    output signed [1:-(BITS-3)] next_y0
);

  localparam [2:-(BITS-3)] x_left_default = -2 << (BITS-3);
  localparam [1:-(BITS-3)] y_top_default = 3 << (BITS-4);
  localparam [-4:-(BITS-3)] x_inc_default = 240;
  localparam [-6:-(BITS-3)] y_inc_default = -51;

  wire signed [2:-(BITS-3)] x_left;
  wire signed [1:-(BITS-3)] y_top;
  wire signed [-4:-(BITS-3)] x_inc_px;
  wire signed [-4:-(BITS-3)] y_inc_px;
  wire signed [-6:-(BITS-3)] x_inc_row;
  wire signed [-6:-(BITS-3)] y_inc_row;

  reg signed [2:-(BITS-3)] x_row_start;
  reg signed [1:-(BITS-3)] y_row_start;

  wire demo_update;
  assign demo_update = ctrl == `CTRL_DEMO && next_frame;

  wire [1:-(BITS-3)] demo_y_top = y_top_default - 240;
  wire [-6:-(BITS-3)] demo_y_in = y_inc_default + 1;

  latch_reg #(.WIDTH(BITS)) l_xl (
    .clk(clk),
    .wen(!rst_n || ctrl == `CTRL_SET_LEFT),
    .data_in(rst_n ? {value,3'd0} : x_left_default),
    .data_out(x_left)
  );

  latch_reg #(.WIDTH(BITS-1)) l_yt (
    .clk(clk),
    .wen(!rst_n || ctrl == `CTRL_SET_TOP || demo_update),
    .data_in(rst_n ? (demo_update ? demo_y_top : {value,2'd0}) : y_top_default),
    .data_out(y_top)
  );

  latch_reg #(.WIDTH(10)) l_xip (
    .clk(clk),
    .wen(!rst_n || ctrl == `CTRL_SET_INC_COL_X),
    .data_in(rst_n ? value[9:0] : x_inc_default),
    .data_out(x_inc_px)
  );

  latch_reg #(.WIDTH(10)) l_yip (
    .clk(clk),
    .wen(!rst_n || ctrl == `CTRL_SET_INC_COL_Y),
    .data_in(rst_n ? value[9:0] : 10'd0),
    .data_out(y_inc_px)
  );

  latch_reg #(.WIDTH(8)) l_xir (
    .clk(clk),
    .wen(!rst_n || ctrl == `CTRL_SET_INC_ROW_X),
    .data_in(rst_n ? value[7:0] : 8'd0),
    .data_out(x_inc_row)
  );

  latch_reg #(.WIDTH(8)) l_yir (
    .clk(clk),
    .wen(!rst_n || ctrl == `CTRL_SET_INC_ROW_Y),
    .data_in(rst_n ? (demo_update ? demo_y_in : value[7:0]) : y_inc_default),
    .data_out(y_inc_row)
  );

  assign next_x0 = next_frame ? x_left :
                   next_row   ? x_row_start :
                                x0 + {{6{x_inc_px[-4]}}, x_inc_px};
  assign next_y0 = next_frame ? y_top :
                   next_row   ? y_row_start :
                                y0 + {{5{y_inc_px[-4]}}, y_inc_px};

  always @(posedge clk) begin
    if (next_frame) begin
      x_row_start <= x_left;
      y_row_start <= y_top;
    end else if (next_row) begin
      x_row_start <= x_row_start + {{8{x_inc_row[-6]}}, x_inc_row};
      y_row_start <= y_row_start + {{7{y_inc_row[-6]}}, y_inc_row};
    end
  end

endmodule