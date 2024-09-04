# SPDX-FileCopyrightText: © 2024 Michael Bell
# SPDX-License-Identifier: Apache-2.0

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from PIL import Image

CTRL_SPIN     = 0
CTRL_SET_LEFT = 1
CTRL_SET_TOP  = 2
CTRL_NONE     = 3
CTRL_SET_INC_COL_X = 4
CTRL_SET_INC_COL_Y = 5
CTRL_SET_INC_ROW_X = 6
CTRL_SET_INC_ROW_Y = 7

async def do_start(dut):
    dut._log.info("Start")

    # 100MHz clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ctrl_in.value = CTRL_NONE
    dut.value_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)

    dut.rst_n.value = 1

async def frame_dump(dut, filename, skip_initial=0):
    for i in range(19):
        vsync = 1 if 3 <= i < 13 else 0
        for j in range(24-skip_initial):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(64):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(88):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(720):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        skip_initial = 0

    
    image = Image.new("RGB", (720, 480))

    for i in range(480):
        for j in range(24):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(64):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(88):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 4)
        for j in range(720):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 1
            red = dut.red.value * 85
            green = dut.green.value * 85
            blue = dut.blue.value * 85
            image.putpixel((j, i), (red, green, blue))
            await ClockCycles(dut.clk, 4)

    image.save(filename)

@cocotb.test()
async def test_default(dut):
    await do_start(dut)

    await ClockCycles(dut.clk, 4)

    await frame_dump(dut, "frame1.png")

@cocotb.test()
async def test_vertical(dut):
    await do_start(dut)

    dut.ctrl_in.value = CTRL_SET_LEFT
    dut.value_in.value = -2 << 10
    await ClockCycles(dut.clk, 1)

    dut.ctrl_in.value = CTRL_SET_TOP
    dut.value_in.value = 3 << 10
    await ClockCycles(dut.clk, 1)

    dut.ctrl_in.value = CTRL_SET_INC_COL_X
    dut.value_in.value = 0
    await ClockCycles(dut.clk, 1)

    dut.ctrl_in.value = CTRL_SET_INC_COL_Y
    dut.value_in.value = -237
    await ClockCycles(dut.clk, 1)

    dut.ctrl_in.value = CTRL_SET_INC_ROW_X
    dut.value_in.value = 51
    await ClockCycles(dut.clk, 1)

    dut.ctrl_in.value = CTRL_SET_INC_ROW_Y
    dut.value_in.value = 0
    await ClockCycles(dut.clk, 1)

    dut.ctrl_in.value = CTRL_NONE
    dut.value_in.value = 0
    await ClockCycles(dut.clk, 2)

    await frame_dump(dut, "frame2.png", 1)

