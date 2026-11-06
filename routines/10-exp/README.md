# EXP: exact reduction and a polynomial loop

**ROM address range:** $36C4-$370D, $39F1-$39FD, $3AAC-$3ADE  
**Size of the ranges:** 138 bytes (including the padding inside them)  
**Replaces:** EXP at `$36C4`  
**Manual:** chapter 11 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

The argument is reduced as x = n ln 2 + r with n truncated towards zero and ln 2 in two parts (a 24-bit high part and a low part), so that n times each part is exact (Cody-Waite). exp(r) is a polynomial of degree 10 on [-ln 2, ln 2], evaluated by a 9-turn Horner loop with constants of four to two bytes. `EXP_REDUCE` does the reduction and the range check, and `EXP_NEGT` is the tail for n < 0.

## Results

- Error at most about 1.9 ulp for every argument tested, of either sign (it was up to 80 ulp and grew with the argument).
- About 28% faster than the 1982 routine (about 101,000 T-states).

## Code

[`exp.asm`](exp.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## License

CC BY-NC 4.0: free to use and adapt with credit; commercial use needs written permission. See the [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE.md).
