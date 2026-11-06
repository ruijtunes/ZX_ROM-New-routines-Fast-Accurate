# Decimal literals rounded once

**ROM address range:** $2CD8-$2CE2, $3BD3-$3BE9, $3CC6-$3CE0  
**Size of the ranges:** 61 bytes (including the padding inside them)  
**Replaces:** The conversion of the digits of a number (DEC-TO-FP)  
**Manual:** chapter 13 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

The digits of a number are accumulated as one exact integer N = x*10^f + F and divided once by 10^f (`DEC_FRAC`), so the result is rounded only once. When the integer does not fit in 32 bits, `DEC_BIG` falls back to the old x + F/D method, and `DEC_DIV` is the common division.

## Results

- Literals of 1 to 9 digits are always correctly rounded (100%, against 98.3%).
- The classic cases (3.6, 6.6036, 0.1 ...) are all correct; `PRINT 3.6=36/10` now prints 1.
- Literals of 10 to 12 digits are unchanged (about 95% correctly rounded).

## Code

[`decimal_literals.asm`](decimal_literals.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## Credits

The routine `DIVISOR`, which builds D = 10^f by multiplying by ten once per fractional digit and which `DEC_FRAC` and `DEC_BIG` call, comes from the Looking Glass ROM and the Gosh Wonderful ROM, both by Geoff Wearmouth.

## License

Free to use.
