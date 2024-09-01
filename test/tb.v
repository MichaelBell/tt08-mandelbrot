`default_nettype none `timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  reg signed [1:-12] value_in;
  reg input_x;
  reg input_en;

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  wire [7:0] ui_in = value_in[-5:-12];
  wire [7:0] uio_in = {input_en, input_x, value_in[1:-4]};
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  wire escaped = uo_out[7];
  wire [6:0] iter = uo_out[6:0];

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

endmodule
