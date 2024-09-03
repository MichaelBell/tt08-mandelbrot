# SPDX-FileCopyrightText: © 2024 Uri Shaked, Michael Bell
# SPDX-License-Identifier: Apache-2.0

# Plots the Mandelbrot set using the cocotb test framework
# To run: make MODULE=test_png

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from mandelbrot import mandelbrot_calc
from PIL import Image


IMAGE_WIDTH = 103
IMAGE_REP = 7
IMAGE_HEIGHT = 480

# How many iterations to run
MAX_ITER = 14

# Define the plotting range
X_RANGE = (-2.0, 0.8)
Y_RANGE = (-1.2, 1.2)


@cocotb.test()
async def test_mandelbrot_py_png(dut):
    dut._log.info("Start")

    image = Image.new("RGB", (IMAGE_WIDTH*IMAGE_REP, IMAGE_HEIGHT))
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
            palette = [(0xA0, 0,    0xF0),
                       (0xF0, 0,    0xA0),
                       (0xF0, 0,    0x50),
                       (0xF0, 0, 0),
                       (0xF0, 0x50, 0),
                       (0xF0, 0xA0, 0),
                       (0xA0, 0xF0, 0),
                       (0x50, 0xF0, 0),
                       (0,    0xF0, 0),
                       (0,    0xF0, 0x50), 
                       (0,    0xF0, 0xA0),
                       (0,    0xA0, 0xF0),
                       (0,    0x50, 0xF0),
                       (0,    0,    0xF0),
                       #(0,    0,    0xA0),
                       #(0,    0,    0x50),
                       (0, 0, 0)]
            for i in range(IMAGE_REP):
                image.putpixel((IMAGE_REP*px+i, py), palette[m])

    ## Save the image
    image.save("mandelbrot_py.png")
