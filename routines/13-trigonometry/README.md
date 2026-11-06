# SIN, COS, TAN, ATN: Horner generator and minimum-error polynomials

**ROM address range:** $3449-$3463, $37B7-$37D6, $37E2-$3828  
**Size of the ranges:** 130 bytes (including the padding inside them)  
**Replaces:** series-xx (`$3449`), the polynomial of SIN/COS and ATN  
**Manual:** chapter 14 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

The general literal `series-xx` (`$80`+n) now evaluates a polynomial with Horner's rule, in 27 bytes instead of 33. The sine uses a polynomial of minimum error (Remez) of degree 5 in Y squared, for the angle reduced to Y between -1 and 1, instead of a Chebyshev series. ATN uses the half-angle identity, which brings the argument to a quarter of its size and needs seven constants instead of twelve. ASN and ACS follow ATN.

The reduction of the angle (`GET-ARGT`) is not changed: the precision of SIN, COS and TAN for large angles and their behavior are as in 1982.

## Results

- 39% to 48% faster (for example SIN 132,400 to 78,300 T-states).
- The same results and behavior, and every entry point is where it was; 19 bytes less.

## Code

[`trigonometry.asm`](trigonometry.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## License

Free to use.
