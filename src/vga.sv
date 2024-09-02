// SPDX-FileCopyrightText: © 2022 Leo Moser <leo.moser@pm.me>, 2024 Michael Bell
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

    /*
        Default parameters are VGA 640x480 @ 60 Hz
        clock = ~25 MHz
    */

module vga #(
    parameter WIDTH=640,    // display width
    parameter HEIGHT=480,   // display height
    parameter HFRONT=16,    // horizontal front porch
    parameter HSYNC=96,     // horizontal sync
    parameter HBACK=46,     // horizontal back porch
    parameter VFRONT=10,    // vertical front porch
    parameter VSYNC=2,      // vertical sync
    parameter VBACK=33      // vertical back porch
)(
    input  logic clk,       // clock
    input  logic reset_n,   // reset
    input  logic advance,   // pixel advance
    output logic hsync,     // 1'b1 if in hsync region
    output logic vsync,     // 1'b1 if in vsync region
    output logic blank,     // 1'b1 if in blank region
    output logic hsync_pulse, // 1'b1 for one clock in hsync
    output logic vsync_pulse  // 1'b1 for one clock in vsync
);

    localparam HTOTAL = WIDTH + HFRONT + HSYNC + HBACK;
    localparam VTOTAL = HEIGHT + VFRONT + VSYNC + VBACK;

    logic signed [$clog2(HTOTAL-1) : 0] x_pos_internal;
    logic signed [$clog2(VTOTAL-1) : 0] y_pos_internal;

    /* Horizontal and Vertical Timing */
    
    logic hblank;
    logic vblank;
    logic vblank_w;
    logic next_row;
    logic next_frame;
     
    // Horizontal timing
    timing #(
        .RESOLUTION     (WIDTH),
        .FRONT_PORCH    (HFRONT),
        .SYNC_PULSE     (HSYNC),
        .BACK_PORCH     (HBACK),
        .TOTAL          (HTOTAL),
        .POLARITY       (1'b0)
    ) timing_hor (
        .clk        (clk),
        .enable     (advance),
        .reset_n    (reset_n),
        .sync       (hsync),
        .blank      (hblank),
        .next       (next_row),
        .counter    (x_pos_internal)
    );

    // Vertical timing
    timing #(
        .RESOLUTION     (HEIGHT),
        .FRONT_PORCH    (VFRONT),
        .SYNC_PULSE     (VSYNC),
        .BACK_PORCH     (VBACK),
        .TOTAL          (VTOTAL),
        .POLARITY       (1'b0)
    ) timing_ver (
        .clk        (clk),
        .enable     (next_row),
        .reset_n    (reset_n),
        .sync       (vsync),
        .blank      (vblank_w),
        .next       (next_frame),
        .counter    (y_pos_internal)
    );

    assign blank = hblank || vblank;

    assign hsync_pulse = advance && (x_pos_internal == -HBACK - HSYNC + 1);
    assign vsync_pulse = next_row && (y_pos_internal == -VBACK - VSYNC + 1);

    always_ff @(posedge clk) vblank <= vblank_w;

    wire _unused = &{next_frame, 1'b0};

endmodule
