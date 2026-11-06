; ---------------------------------------------------------------------------
; ABS and NEGATE
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $346A-$3491   (40 bytes)
; Replaces: ABS ($346A) and NEGATE ($346E)
; Author: ruijtunes (github.com/ruijtunes)   License: Free to use
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

label_346A:
	jr	ABS_BODY	; the body is placed after negate, so that negate keeps its address $346E
	DEFB	$FF, $FF	; (2 free bytes)

;   Unary so on entry HL points to last value, DE to STKEND.  Both are preserved.
;   A floating point number is never zero (zero is the small integer 00 00 00 00 00), so there
;   is no test for zero: the sign bit is just flipped.  A small integer is negated as a 24 bit
;   two's complement number (sign byte, low byte, high byte), and zero stays zero by itself.

label_346E:
	ld	a, (hl)		; exponent byte: 0 for a small integer
	inc	hl		; -> sign byte (integer) / first mantissa byte (float)
NEG_TEST:
	and	a
	jr	z, NEG_INT
	ld	a, (hl)		; floating point: the sign is bit 7 of the first mantissa byte
	xor	$80
NEG_STORE:
	ld	(hl), a
	dec	hl		; HL as on entry
	ret

NEG_INT:			; here A = 0, HL -> sign byte
	inc	hl		; -> low byte
	sub	(hl)		; 0 - low
	ld	(hl), a
	inc	hl		; -> high byte
	ld	a, 0		; (not XOR A: the carry must survive)
	sbc	a, (hl)		; 0 - high - borrow
	ld	(hl), a
	dec	hl
	dec	hl		; -> sign byte
	ld	a, 0
	sbc	a, (hl)		; 0 - sign - borrow
	jr	NEG_STORE

ABS_BODY:
	ld	a, (hl)		; exponent byte, as at the start of negate
	inc	hl
	bit	7, (hl)		; negative?  (BIT leaves A alone)
	jr	nz, NEG_TEST	; yes: abs = negate, continuing in negate with A = exponent
	dec	hl		; no: nothing to do
	ret

	ASSERT $ <= $3492
	DS	$3492-$,$FF	; free bytes
