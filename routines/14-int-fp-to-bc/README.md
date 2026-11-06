# INT and FP-TO-BC / FP-TO-A

**ROM address range:** $36AF-$36BB, $3772-$377F, $2DA2-$2DAC, $2CE3-$2CEA, $3ADF-$3AF2, $3BEA-$3BFA  
**Size of the ranges:** 83 bytes (including the padding inside them)  
**Replaces:** INT (`$36AF`), FP-TO-BC (`$2DA2`) and FP-TO-A (`$2DD5`)  
**Manual:** chapter 15 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

INT is now 13 bytes of Z80 code: a zero or a small integer is returned as it is, a positive number goes straight to TRUNCATE, and a negative number goes to `X_NEG`. FP-TO-BC and FP-TO-A call STK-PNTRS and, for a positive float below 32768, compute floor(x+1/2) as (floor(2x)+1)/2 by incrementing the exponent, truncating and halving.

## Results

- INT of a positive float: 2,416 to 676 T-states; of an integer: 3,343 to 233.
- FP-TO-BC of a positive float: 6,732 to 3,261.
- The same results, bit by bit (906 values checked).

## Code

[`int_fp_to_bc.asm`](int_fp_to_bc.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## License

Free to use.
