# PLOT-SUB: a lookup table for the pixel mask

**ROM address range:** $22E5-$2306, $2400-$2407  
**Size of the ranges:** 42 bytes (including the padding inside them)  
**Replaces:** PLOT-SUB at `$22E5`  
**Manual:** chapter 5 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

PLOT-SUB sets one pixel and is called by PLOT and by DRAW-LINE, so it runs once for every pixel of every point, line, arc and circle segment. The loop that built the pixel mask was replaced by an eight-entry lookup table (`Mask_tab`, `$2400`), which the space freed by the new arc routine pays for.

A pixel can be set, reset (INVERSE 1) or toggled (OVER 1); with both switches on the byte is put back as it is.

## Results

- 21% fewer T-states for the pixel part and 14.5% for the whole routine.

## Code

[`plot_sub.asm`](plot_sub.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

## License

Free to use.
