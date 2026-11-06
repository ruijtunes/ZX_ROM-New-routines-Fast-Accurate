# ABS and NEGATE

**ROM address range:** $346A-$3491  
**Size of the ranges:** 40 bytes (including the padding inside them)  
**Replaces:** ABS (`$346A`) and NEGATE (`$346E`)  
**Manual:** chapter 7 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

Both routines were rewritten in the same 40-byte slot and now take 38 bytes, without the zero test and the integer fetch of the original. Their entry addresses are unchanged and the results are identical to the original code.

## Results

- NEGATE is 3.5 times faster on floating-point numbers and 3.3 times faster on small integers.
- ABS is 5.6 times faster on positive integers and zero, 1.9 times on negative integers and 1.6 times on positive floats, and no slower on negative floats.

## Code

[`abs_negate.asm`](abs_negate.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## License

Free to use
