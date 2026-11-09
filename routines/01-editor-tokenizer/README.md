# Editor: letter-by-letter keywords and the tokenizer

**ROM address range:** $38F1-$39EA, $3C97-$3CBC, $3C47-$3C62, $38D8-$38E7  
**Size of the ranges:** 332 bytes (including the padding inside them)  
**Replaces:** The K mode of the keyboard decoding (keyword tables) and the keyword-from-key path of the editor  
**Manual:** chapter 2 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

The new ROM has a single editor and no K mode. Keywords are typed letter by letter, as BASIC is printed (`PRINT`, `print` or `Print`, in L or C mode), so listings from books and magazines can be typed as they appear.

The editor itself is the original ROM editor. The new code is a thin wrapper, `NEWED`, that clears any pending mode change, forces L mode, calls the original `EDITOR` and, when it returns, hands the line to the tokenizer (`TOKENIZE`, entered at ENTER).

The tokenizer makes one pass over the line and has no table of its own: it looks the words up in the ROM's own token table at `$0095`, in either case. A word becomes a token only where a word can start (not inside a string, after REM, inside a number or inside an identifier). The space inside two-word keywords is optional (`GOTO` becomes `GO TO`), `FN` accepts a one-letter function name, and `VAL` and `VAL$` tokenize their strings too.

SYMBOL SHIFT with a letter key gives the characters that the 1982 keyboard cannot print in L or C mode, and three keys give the commands most typed: SYMBOL SHIFT + Q gives LOAD, + E gives RUN and + W gives CODE, as in OpenSE BASIC. The operators `<=`, `>=` and `<>` have no key: they are typed with `<`, `=` and `>` and the tokenizer joins them at ENTER. In extended mode SYMBOL SHIFT with a digit gives the symbol printed on the key. In graphics mode the keys V to Z give nothing in the editor. The cursor starts every line in L.

## Results

- The keyword tables of the keyboard decoding are gone, which frees ROM space for the other routines.
- Entry points of the 1982 ROM are unchanged.

## Code

[`editor_tokenizer.asm`](editor_tokenizer.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

The routines are in the unused area of the 1982 ROM (`$386E` to `$3CFE`), including the small helpers `TK_NOKW`, `TK_ID`, `TK_ALNUM`, `TK_LET` and `TK_NO` at the end of the last page. The symbol gate (`$3C47`, 28 bytes, with its table of 8 pairs at `$38D8`) decides what a key that gives a keyword becomes. Changes of a few bytes in the original key tables (the letters of SYMBOL SHIFT, the digits of the extended mode) are not included here.

## Credits

The key assignments SYMBOL SHIFT + Q, E and W (LOAD, RUN, CODE) and the symbols of the digit keys in extended mode follow OpenSE BASIC by Andrew Owen (Source Solutions, GPL v2). Only the behavior was adopted: the code is new.

## License

CC BY-NC 4.0: free to use and adapt with credit; commercial use needs written permission. See the [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE.md).
