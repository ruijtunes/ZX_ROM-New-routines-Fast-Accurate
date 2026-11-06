; ---------------------------------------------------------------------------
; Multiplication: a loop one byte at a time
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $3110-$312F, $3CE1-$3CF7   (55 bytes)
; Replaces: The 33-step loop of MULTIPLY ($3110 to $312F)
; Author: ruijtunes (github.com/ruijtunes)   License: Free to use
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

; THE LOOP OF THE MULTIPLICATION, ONE BYTE OF THE MULTIPLIER AT A TIME  (Chapter 18)
;   The registers are as for the old loop: HL, HL' = 0 (the high half of the product), DE, DE' = the multiplicand,
;   A, C, C', B' = the multiplier (the lowest byte in A), the carry is clear. The old loop shifted the four bytes of
;   the multiplier, which received the low half of the product, in every one of the 33 steps. Here only the byte
;   that is being used is shifted (MUL_PH, 8 steps), and the bit that the shift sends out is the next bit of the
;   multiplier. Of the low half of the product the rest of the routine only uses the highest byte, which is the one
;   that the last byte leaves in A and goes to B'; the other three are not needed. (32 bytes, as the old loop.)
MUL_LOOP:
	rra			; bit 0 of the lowest byte to the carry (the carry was clear)
	call	MUL_PH		; the lowest byte
	ld	a, c
	srl	a			; the next byte; its bit 0 to the carry
	call	MUL_PH
	exx
	ld	a, c			; C'
	exx
	srl	a
	call	MUL_PH
	exx
	ld	a, b			; B', the highest byte
	exx
	srl	a
	call	MUL_PH
	exx
	ld	b, a			; B' = the highest byte of the low half of the product
	exx
	jr	MUL_DONE		; (the byte that follows is free)
	DEFB	$FF


; MUL_PH: 8 steps of the multiplication with the byte of the multiplier that is in A (the carry is its bit 0).
; In every step: if the carry is set, the multiplicand is added to the product; the product is shifted right,
; and its lowest bit goes into A, which gives the carry of the next step. At the end A holds the 8 low bits.
MUL_PH:
	ld	b, $08
MUL_PHL:
	jr	nc, MUL_PH1
	add	hl, de
	exx
	adc	hl, de
	exx
MUL_PH1:
	exx
	rr	h
	rr	l
	exx
	rr	h
	rr	l
	rra
	djnz	MUL_PHL
	ret
