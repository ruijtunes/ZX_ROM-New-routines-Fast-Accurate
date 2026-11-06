# Editor: letter-by-letter keywords and the tokenizer

**ROM address range:** $38F7-$39F0, $3CA0-$3CC5  
**Size of the ranges:** 288 bytes (including the padding inside them)  
**Replaces:** The K mode of the keyboard decoding (keyword tables) and the keyword-from-key path of the editor  
**Manual:** chapter 2 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

The new ROM has a single editor and no K mode. Keywords are typed letter by letter, as BASIC is printed (`PRINT`, `print` or `Print`, in L or C mode), so listings from books and magazines can be typed as they appear.

The editor itself is the original ROM editor. The new code is a thin wrapper, that clears any pending mode change, forces L mode, calls the original `EDITOR` and, when it returns, hands the line to the tokenizer (`TOKENIZE`, entered at ENTER).

The tokenizer makes one pass over the line and has no table of its own: it looks the words up in the ROM's own token table at `$0095`, in either case. A word becomes a token only where a word can start (not inside a string, after REM, inside a number or inside an identifier). The space inside two-word keywords is optional (`GOTO` becomes `GO TO`), `FN` accepts a one-letter function name, and `VAL` and `VAL$` tokenize their strings too.

SYMBOL SHIFT with a letter key gives the characters that the 1982 keyboard cannot print in L or C mode. The cursor starts every line in L.

## Results

- Entry points of the 1982 ROM are unchanged.

## Code

[`editor_tokenizer.asm`](editor_tokenizer.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

The routines are in the unused area of the 1982 ROM (`$386E` to `$3CFE`), plus the small helpers `TK_NOKW`, `TK_ID`, `TK_ALNUM`, `TK_LET` and `TK_NO` at the end of the last page. Hooks in the original keyboard and editor code (a few bytes each) are not included here.

## License

Free to use.
