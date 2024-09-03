<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The Mandelbrot fractal is computed "racing the beam" and displayed through the [TinyVGA Pmod](https://github.com/mole99/tiny-vga).

One iteration of the computation is done over two clock cycles, and a maximum iteration depth of 14 iterations is used.  The design is clocked at 100MHz, allowing four clock cycles per 25MHz pixel clock.  This means one value is computed every 7 pixels, giving a result like this:

![The Mandelbrot set](mandelvga.png)

The computation uses 16-bit fixed point arithmetic.  The multiplications are approximated to save area, giving a possible error in the least significant bit.  This gives at least 14-bit accuracy on each iteration.

The output image is at a 720x480 resolution (~103x480 Mandelbrot pixels).

## How to test

Provide a 100MHz clock.

The image position and zoom may be able to be configured (TBD)

## External hardware

[Tiny VGA Pmod](https://github.com/mole99/tiny-vga) in the output socket.
