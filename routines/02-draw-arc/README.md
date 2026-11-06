# DRAW x,y,angle: circular arcs

**ROM address range:** $2355-$2381, $23F7-$23FF, $2408-$24B6  
**Size of the ranges:** 229 bytes (including the padding inside them)  
**Replaces:** DR-3-PRMS and the arc routine of the 1982 ROM (291 bytes)  
**Manual:** chapter 3 of the *New ZX Spectrum ROM Reference Manual* (summary below)

## Summary

A new arc routine performs the same visible operation as the original DRAW x,y,angle (from the current position to the point offset by (dx,dy), turning through a signed angle A) in 218 bytes instead of 291. The 73 bytes freed pay for the faster CIRCLE and PLOT.

The centre and the radius are reconstructed from the chord and the sweep angle, as in the original, but the number of chords is chosen by a linear law N = 4 + ROUND(|A| (R'+48)/16) tuned on random arcs, and the graphics cursor always finishes on the exact destination pixel.

Angles that are multiples of 2π draw a straight line instead of giving report B. An optional reduction of the angle modulo 2π is selected by bit 6 of FLAGS2 (`$5C6A`), which addresses the large-angle cases described by Ian Logan in 1983.

## Results

- 218 bytes instead of 291.
- 4.2% of 800 random arcs miss the ideal circle by more than a pixel, against 12.0% for the 1982 routine.
- No more report B on multiples of 2π.

## Code

[`draw_arc.asm`](draw_arc.asm) is the part of the ROM source that implements this routine. It depends on the labels of the rest of the ROM source and is meant to be assembled inside it (sjasmplus), at the addresses above.

The 8-byte mask table at `$2400` belongs to PLOT-SUB (folder 04-plot).

## Credits

The bibliography of the algorithm (incremental digital display of circular arcs, Bresenham) is in the manual.

## License

CC BY-NC 4.0: free to use and adapt with credit; commercial use needs written permission. See the [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE.md).
