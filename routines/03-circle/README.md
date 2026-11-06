# CIRCLE: integer midpoint algorithm

**ROM address range:** $2320-$2354, $238E-$23F6  
**Size of the ranges:** 158 bytes (including the padding inside them)  
**Replaces:** CIRCLE at `$2320`  
**Manual:** chapter 4 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

The 1982 CIRCLE reduces the operation to an arc of 2π and sends it through the same floating-point machinery as DRAW. The new routine needs no floating-point calculation at all: it is an integer midpoint (Bresenham-style) circle algorithm with eight-fold symmetry. It is made possible by the 73 bytes freed by the new arc routine.

The circle is drawn from the top, moving right or down-right, whichever is closer to the circle, until x = y; the other seven octants are mirrored.

## Results

- 16.8 times faster than the 1982 routine.
- The error never exceeds 0.50 pixel.

## Code

[`circle.asm`](circle.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## Credits

Midpoint circle algorithm.

## License
Free to use.
