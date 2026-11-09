# Multiplication: a loop one byte at a time

**ROM address range:** $3110-$312F, $3CD8-$3CEE  
**Size of the ranges:** 55 bytes (including the padding inside them)  
**Replaces:** The 33-step loop of MULTIPLY (`$3110` to `$312F`)  
**Manual:** chapter 18 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

The 1982 loop shifted all four bytes of the multiplier in every one of its 33 steps. The new loop works one byte at a time: the 8 steps of `MUL_PH` shift only the byte in use, which sends out the next bit of the multiplier and takes in the bit that falls out of the product. Of the low half of the product the rest of the routine reads only its highest byte, so the other three are not kept. The loop takes the same 32 bytes at the same address; `MUL_PH` takes 23 more.

## Results

- A floating-point multiplication is 15.6% faster (5,700 to 4,809 T-states).
- SIN, COS, TAN, ATN, ASN, ACS, LN, EXP and x^y are 6% to 9% faster, with identical results (checked bit by bit on 9,830 tests).

## Code

[`multiplication_loop.asm`](multiplication_loop.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## License

CC BY-NC 4.0: free to use and adapt with credit; commercial use needs written permission. See the [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE.md).
