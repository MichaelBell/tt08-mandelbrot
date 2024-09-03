`default_nettype none `timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  reg signed [12:0] value_in;
  reg [2:0] ctrl_in;

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  wire [7:0] ui_in = {value_in[4:0], ctrl_in};
  wire [7:0] uio_in = {value_in[12:5]};
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  wire hsync;
  wire vsync;
  wire [5:0] rgb;
  wire [1:0] red;
  wire [1:0] green;
  wire [1:0] blue;

`ifdef GL_TEST
  wire vpwr = 1'b1 ? 1'b1 : 1'bz;
  wire vgnd = 1'b1 ? 1'b0 : 1'bz;
`endif  

  // Replace tt_um_example with your module name:
  tt_um_MichaelBell_mandelbrot user_project (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(vpwr),
      .VGND(vgnd),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

  assign hsync = uo_out[7];
  assign vsync = uo_out[3];
  assign rgb = {uo_out[0], uo_out[4], uo_out[1], uo_out[5], uo_out[2], uo_out[6]};
  assign red = rgb[5:4];
  assign green = rgb[3:2];
  assign blue = rgb[1:0];
  
endmodule
