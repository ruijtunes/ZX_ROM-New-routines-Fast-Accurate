# SQR: Júlia's method plus one Newton step

**ROM address range:** $384A-$3850, $386E-$38D7  
**Size of the ranges:** 113 bytes (including the padding inside them)  
**Replaces:** SQR at `$384A` (it was `x ** 0.5`)  
**Manual:** chapter 6 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

The new SQR uses Júlia's method plus a single Newton-Raphson step. Júlia's progression finds the integer part of the root, the regression gives it 5 digits computed in integers on the Z80, and Newton brings them to the full precision of the 5-byte format.

Exact squares, such as the powers of 4, come out without a division.

## Results

- 111 bytes and 13,724 T-states on average (3.9 ms at 3.5 MHz) over 1,051 arguments.
- 27.7 times faster than the original ROM (379,712 T-states) and 6.2 times faster than a plain Newton-Raphson routine.
- Maximum error 0.79 ulp, against 72.8 ulp for the original.

## Code

[`sqr.asm`](sqr.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## Credits

Júlia's Regression, created at age 11 by Júlia Helena Pimenta Ferreira (Belo Horizonte, Brazil) and formalized with her mathematics teacher, Frederico Ferreira.

## License

CC BY-NC 4.0: free to use and adapt with credit; commercial use needs written permission. See the [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE.md).
