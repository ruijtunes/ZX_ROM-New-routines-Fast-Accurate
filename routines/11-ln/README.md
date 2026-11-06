# LN: through atanh and a short polynomial

**ROM address range:** $3713-$3771  
**Size of the ranges:** 95 bytes (including the padding inside them)  
**Replaces:** LN at `$3713`  
**Manual:** chapter 12 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

LN x is computed from the exponent and the mantissa: with the mantissa m brought to (3/4, 3/2], z = (m-1)/(m+1) and ln m = 2 atanh z = z P(z squared), with P a Remez polynomial of degree 4 evaluated by a 4-turn Horner loop with short constants. m-1 is computed exactly as m - 1/2 - 1/2, because the addition of the ROM has no guard bit. It replaces the 12 terms of the Chebyshev series.

## Results

- About 88,000 T-states instead of about 224,000 (61% less), with the accuracy of the 1982 routine and better near 1.
- The general power x^y, whose time is mostly LN and EXP, is 48% faster.

## Code

[`ln.asm`](ln.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## License

CC BY-NC 4.0: free to use and adapt with credit; commercial use needs written permission. See the [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE.md).
