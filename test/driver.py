import struct
from cocotb.triggers import ClockCycles


class MandelbrotDriver:
    def __init__(self, dut):
        self._dut = dut
        self.round = 6

    async def reset(self):
        self._dut._log.info("Reset")
        self._dut.ena.value = 1
        self._dut.value_in.value = 0
        self._dut.input_x.value = 0
        self._dut.input_en.value = 0
        self._dut.rst_n.value = 0
        await ClockCycles(self._dut.clk, 10)
        self._dut.rst_n.value = 1

    async def load_c(self, c: complex):
        value = int(c.real * (1 << 12))
        self._dut.value_in.value = value
        self._dut.input_x.value = 1
        self._dut.input_en.value = 1
        await ClockCycles(self._dut.clk, 1)
        value = int(c.imag * (1 << 12))
        self._dut.value_in.value = value
        self._dut.input_x.value = 0
        await ClockCycles(self._dut.clk, 1)
        self._dut.input_en.value = 0

    async def run(self, c: complex, iter: int = 32):
        await self.load_c(c)
        for i in range(2*iter+1):
            await ClockCycles(self._dut.clk, 1)
            if self._dut.escaped.value == 1:
                return self._dut.iter.value.integer
        return self._dut.iter.value.integer
