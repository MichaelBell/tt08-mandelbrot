# SPDX-FileCopyrightText: © 2024 Uri Shaked
# SPDX-License-Identifier: Apache-2.0

# Plots the Mandelbrot set using the cocotb test framework
# To run: make MODULE=test_png

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from driver import MandelbrotDriver
from mandelbrot import mandelbrot_calc
from PIL import Image


IMAGE_WIDTH = 106
IMAGE_HEIGHT = 80

# How many iterations to run
MAX_ITER = 15

# Define the plotting range
X_RANGE = (-2.0, 1.5)
Y_RANGE = (-1.5, 1.5)


@cocotb.test()
async def test_mandelbrot_png(dut):
    dut._log.info("Start")

    # Set the clock period to 50 ns (20 MHz)
    clock = Clock(dut.clk, 50, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test mandelbrot set")

    mandelbrot = MandelbrotDriver(dut)

    # Create a new image with RGB mode
    image = Image.new("RGB", (IMAGE_WIDTH, IMAGE_HEIGHT))

    xmin, xmax = X_RANGE
    ymin, ymax = Y_RANGE

    # Loop through each pixel
    for py in range(IMAGE_HEIGHT):
        dut._log.info(f"Row {py} of {IMAGE_HEIGHT}")
        for px in range(IMAGE_WIDTH):
            # Convert pixel coordinate to complex number
            x = xmin + (xmax - xmin) * px / (IMAGE_WIDTH - 1)
            y = ymin + (ymax - ymin) * py / (IMAGE_HEIGHT - 1)

            # Compute the number of iterations
            m = await mandelbrot.run(complex(x, y), MAX_ITER)

            # Color mapping
            color = 255 - int(m * 255 / MAX_ITER)
            image.putpixel((px, py), (color, color, color))
        image.save("mandelbrot.png")

    ## Save the image
    image.save("mandelbrot.png")


@cocotb.test()
async def test_mandelbrot_py_png(dut):
    dut._log.info("Start")

    image = Image.new("RGB", (IMAGE_WIDTH, IMAGE_HEIGHT))
    xmin, xmax = X_RANGE
    ymin, ymax = Y_RANGE

    # Loop through each pixel
    for py in range(IMAGE_HEIGHT):
        for px in range(IMAGE_WIDTH):
            # Convert pixel coordinate to complex number
            x = xmin + (xmax - xmin) * px / (IMAGE_WIDTH - 1)
            y = ymin + (ymax - ymin) * py / (IMAGE_HEIGHT - 1)

            # Compute the number of iterations
            m = mandelbrot_calc(complex(x, y), MAX_ITER)

            # Color mapping
            color = 255 - int(m * 255 / MAX_ITER)
            image.putpixel((px, py), (color, color, color))

    ## Save the image
    image.save("mandelbrot_py.png")
