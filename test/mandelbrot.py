# SPDX-License-Identifier: Apache-2.0
# Description: Mandelbrot set test function

def escaped(x, y, bits):
    x = x >> (bits - 13)
    y = y >> (bits - 13)
    return x*x + y*y > (4 << 20)

def mandelbrot_calc_fixed(c: complex, max_iters=256, bits=16):
    n = 0
    x0 = int(c.real * (1 << 12)) << (bits - 15)
    y0 = int(c.imag * (1 << 12)) << (bits - 15)
    #print(x0, y0)
    x = x0
    y = y0
    x0 <<= 1
    while (not escaped(x, y, bits)) and n < max_iters:
        x_new = ((x*x) >> (bits - 4)) - ((y*y) >> (bits-4)) + x0
        y = ((x*y) >> (bits - 4)) + y0
        x = x_new >> 1
        n += 1
        #print(x, y)
        #print(float(x) / (1 << (bits - 3)), float(y) / (1 << (bits - 3)), n)
    return n

def mandelbrot_calc(c: complex, max_iters=256):
    z = c
    n = 0
    while abs(z) <= 2 and n < max_iters:
        z = z * z + c
        n += 1
    return n