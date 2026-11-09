; ---------------------------------------------------------------------------
; Decimal literals rounded once
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $2CD8-$2CE2, $3BD3-$3BE9, $3CBD-$3CD7   (61 bytes)
; Replaces: The conversion of the digits of a number (DEC-TO-FP)
; Author: ruijtunes (github.com/ruijtunes)   License: CC BY-NC 4.0 (see LICENSE)
; The labels (label_XXXX) are those of the standard ROM disassembly; the routine
; assembles inside the ROM source (sjasmplus) at the addresses given here.
; Credit: the DIVISOR routine (10^f), called from here, comes from the Looking Glass ROM and the Gosh Wonderful ROM, both by Geoff Wearmouth.
; ---------------------------------------------------------------------------

; ---- DEC_DIV: D = 10^f counted from CH-ADD (the first fraction digit), then divides the stack top by D
DEC_DIV:
	rst	28h
	DEFB	$A1,$38
	rst	18h		; GET-CHAR: the first fraction digit
	call	label_3BD3	; DIVISOR: 10^f
	rst	28h
	DEFB	$05,$38
	ret


; DEC_BIG: N does not fit in 32 bits (more than about 9 digits), so it is not exact:
; the old way, x + F/10^f, where x and F are each exact.
DEC_BIG:
	rst	28h
	DEFB	$02,$E0,$38	; delete N ; get-mem-0 (x)
	rst	18h		; GET-CHAR: the first fraction digit
	push	hl
	call	label_2D3B	; INT-TO-FP: F
	pop	hl
	ld	($5C5D),hl
	call	DEC_DIV		; F / 10^f
	rst	28h
	DEFB	$0F,$38	; addition: x + F/10^f
	rst	18h
	jp	label_2CEB


	ASSERT $ <= $3D00
; ----------------------------------------------------------------------------
; DEC_FRAC: the fraction of a decimal literal, rounded only once.
; Entry: x (the integer part) is on the calculator stack, A is the first digit of the
; fraction and CH-ADD points at it. The digits go on being accumulated onto x, so that
; N = x*10^f + F is an exact integer while it is below 2^32; one division by 10^f then
; gives the correctly rounded value (before: x + F/10^f, two roundings).
; ----------------------------------------------------------------------------
DEC_FRAC:
	rst	28h
	DEFB	$C0,$38	; st-mem-0: mem-0 = x (it stays on the stack too)
	rst	18h		; GET-CHAR: A = first digit, HL = CH-ADD (the calculator changes A, so after it)
	push	hl
	call	label_2D40	; NXT-DGT-2: N = x*10^f + F
	rst	28h
	DEFB	$38		; end-calc: HL -> exponent byte of N
	ld	a,(hl)
	pop	hl
	ld	($5C5D),hl	; CH-ADD back on the first fraction digit
	cp	$A1		; N >= 2^32: it may not be exact
	jp	nc,DEC_BIG
	call	DEC_DIV		; N / 10^f: the only rounding
	rst	18h
	jp	label_2CEB
