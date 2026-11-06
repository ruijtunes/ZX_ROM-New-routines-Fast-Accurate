# Integer powers by squaring

**ROM address range:** $3A6C-$3AAB  
**Size of the ranges:** 64 bytes (including the padding inside them)  
**Replaces:** TO-POWER for integer exponents (the 1982 ROM computes every power through LN and EXP)  
**Manual:** chapter 8 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

For an integer exponent n with 1 <= |n| <= 64 the new routine, `IPOW` (64 bytes), computes the power by repeated squaring, and the original TO-POWER, shared and untouched, handles every other case. Negative exponents use the reciprocal. Negative bases, which raised an error in the original, now work.

## Results

- Up to 37 times faster than the original (10,008 T-states for |n| from 1 to 8, against about 371,800).
- The error is much smaller: rms 0.6 to 4.9 ulp against 9 to 13 for the original.
- The limit of 64 is where the error of the squares grows past that of LN/EXP.

## Code

[`integer_powers.asm`](integer_powers.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## License

CC BY-NC 4.0: free to use and adapt with credit; commercial use needs written permission. See the [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE.md).
