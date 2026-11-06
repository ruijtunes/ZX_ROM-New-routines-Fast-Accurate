; ---------------------------------------------------------------------------
; INT and FP-TO-BC / FP-TO-A
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $36AF-$36BB, $3772-$377F, $2DA2-$2DAC, $2CE3-$2CEA, $3ADF-$3AF2, $3BEA-$3BFA   (83 bytes)
; Replaces: INT ($36AF), FP-TO-BC ($2DA2) and FP-TO-A ($2DD5)
; Author: ruijtunes (github.com/ruijtunes)   License: Free to use
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

; FPBC_OLD: the old rounding (x + 1/2, then INT) for negative numbers and for numbers of 32768 or more
FPBC_OLD:
	rst	28h
	DEFB	$A2,$0F,$27,$38	; stk-half, addition, int, end-calc
	jp	label_2DAD


label_2DA2:
	call	label_35BF	; STK-PNTRS: HL -> the number on top, DE = STKEND (the same as 'RST 28, end-calc' but quicker)
	ld	a,(hl)		; the exponent byte
	and	a
	jr	z,label_2DAD	; a small integer or zero: nothing to round
	jp	FPBC_1		; a floating-point number: rounded without the calculator (FPBC_1, FPBC_2 and FPBC_OLD below)
	DS	$2DAD-$,$FF


label_36AF:
	ld	a,(hl)		; the exponent byte of x
	and	a
	ret	z		; 0: zero or a small integer, and INT x = x
	inc	hl
	bit	7,(hl)		; the sign
	dec	hl
	jp	z,label_3214	; x > 0: INT x = TRUNCATE x (towards zero, that is down)
	jp	X_NEG		; x < 0: the script X_NEG, in the free bytes of the window of LN


;
;

; X_NEG: INT of a negative number (it was inside the routine INT: the calculator literal $27 jumps here).
; truncate gives -3 for -3.4 but INT must give -4, so one is subtracted when there was a fraction.
X_NEG:
	rst     28h             ;; FP-CALC              x.    (= -3.4).
        DEFB    $31
        DEFB    $3A
        DEFB    $C0
        DEFB    $03
        DEFB    $E0
        DEFB    $01
        DEFB    $30
        DEFB    $00
        DEFB    X_NEG_EXIT-$    ;;to EXIT               -3.
        DEFB    $A1
        DEFB    $03
X_NEG_EXIT:
	DEFB    $38
        ret


; ----------------------------------------------------------------------------
; FPBC_1, FPBC_2: the floating-point part of FP-TO-BC. For x >= 0 and x < 32768, round(x) = floor(x + 1/2) =
; (floor(2x) + 1) div 2, and 2x is the exponent plus one, so the addition of 1/2 and the INT of the calculator
; (about 3,300 T-states) become a TRUNCATE (about 700). Entry: HL -> x, A = its exponent byte (not zero).
; ----------------------------------------------------------------------------
FPBC_1:
	inc	hl
	bit	7,(hl)		; the sign
	dec	hl
	jp	nz,FPBC_OLD	; negative: the old way
	cp	$90
	jp	nc,FPBC_OLD	; 32768 or more: the old way
	inc	(hl)		; 2x
	call	label_3214	; TRUNCATE: floor(2x), a small integer
	push	hl
	jp	FPBC_2


FPBC_2:
	call	label_2D7F	; INT-FETCH: DE = floor(2x)
	srl	d
	rr	e		; carry = the lowest bit of floor(2x)
	jr	nc,FPBC_3
	inc	de		; (floor(2x) + 1) div 2 = floor(2x) div 2 + its lowest bit
FPBC_3:	pop	hl
	call	label_2D8E	; INT-STORE: the result goes back to the stack
	jp	label_2DAD	; FP-DELETE: as before
