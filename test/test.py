# SPDX-FileCopyrightText: © 2024 Uri Shaked
# SPDX-License-Identifier: Apache-2.0

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from PIL import Image

async def do_start(dut, inputs = 0):
    dut._log.info("Start")

    # 100MHz clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = inputs
    dut.uio_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)

    dut.rst_n.value = 1

async def frame_dump(dut, frame, filename):
    await do_start(dut, frame << 3)

    await ClockCycles(dut.clk, 4)

    for i in range(45):
        vsync = 0 if i in (10, 11) else 1
        for j in range(16):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(96):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(46):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(640):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)

    
    image = Image.new("RGB", (640, 480))

    for i in range(480):
        for j in range(16):
            assert dut.vsync.value == 1
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(96):
            assert dut.vsync.value == 1
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(46):
            assert dut.vsync.value == 1
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(640):
            assert dut.vsync.value == 1
            assert dut.hsync.value == 1
            red = dut.red.value * 85
            green = dut.green.value * 85
            blue = dut.blue.value * 85
            image.putpixel((j, i), (red, green, blue))
            await ClockCycles(dut.clk, 4)

    image.save(filename)

@cocotb.test()
async def test_frames(dut):
    await frame_dump(dut,  0, "mandelvga.png")