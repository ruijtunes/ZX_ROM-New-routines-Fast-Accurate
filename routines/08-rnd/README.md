# RND: integer generator

**ROM address range:** $25F8-$2624  
**Size of the ranges:** 45 bytes (including the padding inside them)  
**Replaces:** RND (S-RND) at `$25F8`  
**Manual:** chapter 9 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

Random numbers are generated with an integer routine instead of the floating-point calculator. The generator is the one of the SAM Coupé ROM v3.0 (X(n+1) = (254 (X(n)+1) mod 65537) - 1): the 16-bit seed stays in the same system variable, the numbers have the same range, and the period is the full 65,536 values. Multiplication by 254 uses shifts and a subtraction, with no general multiplication.

## Results

- 24 times faster and 2 bytes shorter than the 1982 routine.
- Measured: 47,069 T-states per RND in the 1982 ROM against 1,972 (23.9 times faster, 5,000 calls). In BASIC, `LET A=RND` takes 52,735 T-states against 7,685 (6.9 times faster), and the loop `FOR I=1 TO 1000: LET A=RND: NEXT I` is 3.2 times faster.

## Code

[`rnd.asm`](rnd.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## Credits

The generator is by Dr. Andy Wright (SAM Coupé ROM v3.0), who in 2008 allowed all his ROMs to be freely redistributed.

## License

CC BY-NC 4.0: free to use and adapt with credit; commercial use needs written permission. See the [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE.md).
