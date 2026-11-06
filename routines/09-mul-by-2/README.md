# Calculator literal $3C: multiply by 2

**ROM address range:** $3829-$3832  
**Size of the ranges:** 10 bytes (including the padding inside them)  
**Replaces:** The pair `duplicate`, `addition` (`$31 $0F`) used wherever a value is doubled  
**Manual:** chapter 10 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

A new calculator literal, `$3C`, multiplies the number on top of the stack by 2 by adding 1 to its exponent (10 bytes). The addition it replaces aligned, added, normalized and rounded to compute something that needs none of this. The literal is used by the series generator, LN, ATN, ASN and the arc setup.

## Results

- About 2,030 T-states become about 290 per use.

## Code

[`mul_by_2.asm`](mul_by_2.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

It uses the slot of the old `e-to-fp` literal.

## License

Freely redistributed.
