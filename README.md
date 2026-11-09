# New routines for the ZX Spectrum 48K ROM

Faster and more accurate replacements for routines of the ZX Spectrum 48K ROM: graphics (PLOT, CIRCLE, DRAW arcs), arithmetic (SQR, ABS/NEGATE, integer powers, RND, EXP, LN, SIN/COS/TAN/ATN, the multiplication loop, INT, decimal literals) and a letter-by-letter editor with a tokenizer.

Each folder in [`routines/`](routines/) has the **code** of the routine (an excerpt of the ROM source, with its ROM address range) and a short **description**.

> Status: all the measurements were made in an emulator of the Z80 with the ROM in place; The entry points of the 1982 ROM are kept.

## The routines

| # | Routine | ROM address(es) | Result |
|---|---|---|---|
| 01 | [Editor: letter-by-letter keywords and the tokenizer](routines/01-editor-tokenizer/) | $38F1, $3C97, $3C47… | Keywords typed letter by letter, tokenized at ENTER; no K mode |
| 02 | [DRAW x,y,angle: circular arcs](routines/02-draw-arc/) | $2355, $23F7, $2408 | 218 bytes instead of 291; no more report B on multiples of 2π; optional angle reduction |
| 03 | [CIRCLE: integer midpoint algorithm](routines/03-circle/) | $2320, $238E | 16.8× faster; error never above 0.50 pixel |
| 04 | [PLOT-SUB: a lookup table for the pixel mask](routines/04-plot/) | $22E5, $2400 | 21% fewer T-states for the pixel part; 14.5% for the whole routine |
| 05 | [SQR: Júlia's method plus one Newton step](routines/05-sqr/) | $384A, $386E | 27.7× faster; maximum error 0.79 ulp (72.8 in the original) |
| 06 | [ABS and NEGATE](routines/06-abs-negate/) | $346A | NEGATE 3.5× faster on floats; ABS up to 5.6× faster on integers; 38 bytes in a 40-byte slot |
| 07 | [Integer powers by squaring](routines/07-integer-powers/) | $3A6C | Up to 37× faster; negative bases work; much smaller error |
| 08 | [RND: integer generator](routines/08-rnd/) | $25F8 | 24× faster; full period of 65,536; 2 bytes shorter |
| 09 | [Calculator literal $3C: multiply by 2](routines/09-mul-by-2/) | $3829 | About 2,030 T-states become about 290 per use |
| 10 | [EXP: exact reduction and a polynomial loop](routines/10-exp/) | $36C4, $39EB, $3AAC | Error from up to 80 ulp to about 1.9 ulp; about 28% faster |
| 11 | [LN: through atanh and a short polynomial](routines/11-ln/) | $3713 | 61% faster (224,000 to 88,000 T-states); same accuracy, better near 1; x^y 48% faster |
| 12 | [Decimal literals rounded once](routines/12-decimal-literals/) | $2CD8, $3BD3, $3CBD | Literals of up to 9 digits always correctly rounded (100%, against 98.3%) |
| 13 | [SIN, COS, TAN, ATN: Horner generator and minimum-error polynomials](routines/13-trigonometry/) | $3449, $37B7, $37E2 | 39% to 48% faster; same results, behavior and entry points; 19 bytes less |
| 14 | [INT and FP-TO-BC / FP-TO-A](routines/14-int-fp-to-bc/) | $36AF, $3772, $2DA2… | Same results, 3 to 10 times faster |
| 15 | [Multiplication: a loop one byte at a time](routines/15-multiplication-loop/) | $3110, $3CD8 | Multiplication 15.6% faster; the functions 6% to 9%; same results and addresses |

Times are T-states at 3.5 MHz measured in the emulator; "ulp" is one unit in the last place of the 32-bit mantissa.

## How to use the code

The `.asm` files are parts of the ROM source, not stand-alone programs: they have to be assembled inside a ROM source with [sjasmplus](https://github.com/z00m128/sjasmplus), at the addresses given in each file. Each routine keeps the entry address of the routine it replaces, or says where it moved.

```
sjasmplus --lst=zxrom.lst rom.asm
```

## Credits

- Random numbers: the generator of the SAM Coupé ROM v3.0 by Dr. Andy Wright, who in 2008 allowed all his ROMs to be freely redistributed.
- Square root: Júlia's Regression, by Júlia Helena Pimenta Ferreira and her mathematics teacher Frederico Ferreira.
- Decimal literals: the `DIVISOR` routine (10^f), on which the new conversion relies, comes from the Looking Glass ROM and the Gosh Wonderful ROM, both by Geoff Wearmouth.
- Circle: the midpoint (Bresenham-style) circle algorithm.
- Editor keys: the assignments SYMBOL SHIFT + Q, E, W (LOAD, RUN, CODE) and the symbols of the digit keys in extended mode follow OpenSE BASIC by Andrew Owen (Source Solutions, GPL v2); only the behavior was adopted.
- See [NOTICE.md](NOTICE.md) for the third-party material and the position about the original ROM.


