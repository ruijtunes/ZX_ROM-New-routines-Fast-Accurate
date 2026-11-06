; ---------------------------------------------------------------------------
; SIN, COS, TAN, ATN: Horner generator and minimum-error polynomials
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $3449-$3463, $37B7-$37D6, $37E2-$3828   (130 bytes)
; Replaces: series-xx ($3449), the polynomial of SIN/COS and ATN
; Author: ruijtunes (github.com/ruijtunes)   License: Free to use
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

;; series-xx: the generator of the polynomials of SIN, COS and ATN (Chapter 14)
; It is the literal $80 + n of the old Chebyshev series, but it evaluates a polynomial in w by Horner's rule:
; the stack holds ..., w; after the literal come n+1 constants in the format of STK-DATA without its opcode,
; the highest degree first: P(w) = c0 + w*(c1 + w*(c2 + ... + w*c(n))). The result replaces w.
label_3449:
	ld	b, a		; n, the number of turns of the loop
	call	label_335E	; GEN-ENT-1: BREG = B; the pointer to the constants goes on the machine stack
	DEFB	$C0,$02,$38	; st-mem-0 (w), delete, end-calc: the pointer comes back to H'L'
	call	label_33C6	; STK-DATA: the first constant, c(n)
	call	label_3362	; GEN-ENT-2: back to the calculator
label_3453:
	DEFB	$E0,$04,$38	; get-mem-0, multiply, end-calc
	call	label_33C6	; the next constant
	call	label_3362
	DEFB	$0F,$35		; addition, dec-jr-nz
	DEFB	label_3453-$
	DEFB	$38
	ret			; with H'L' after the last constant


label_37B7:  DEFB    $31
        DEFB    $31             ;;duplicate          Y, Y, Y.
        DEFB    $04             ;;multiply           Y, Y*Y.
	DEFB	$85			;;series-xx: sin(pi*Y/2) = Y*P(Y*Y), with P of degree 5: six constants (Chapter 14)
	DEFB	$5E,$E6,$1A		; c5
	DEFB	$64,$28,$08		; c4
	DEFB	$A9,$99,$68,$89		; c3
	DEFB	$ED,$23,$35,$DF,$E1		; c2
	DEFB	$F0,$A5,$5D,$E7,$28		; c1
	DEFB	$F1,$49,$0F,$DA,$A2		; c0
        DEFB    $04             ;;multiply           Y*P(Y*Y).
        DEFB    $38

        RET


;; atn: for |x| >= 1 atan(x) = +-pi/2 - atan(1/x); then atan(x) = 2*atan(y) with y = x/(1 + sqr(1 + x*x)), |y| <= tan(pi/8) (Chapter 14)
label_37E2:
	call	label_3297
	ld	a,(hl)
	cp	$81
	jr	c,ATN_SMALL
	rst	28h
	DEFB	$A1,$1B,$01,$05,$31,$36,$A3,$01,$00	; stk-one, negate, exchange, division, duplicate, less-0, stk-pi/2, exchange, jump-true
	DEFB	ATN_CASES-$
	DEFB	$1B,$33		; negate, jump
	DEFB	ATN_CASES-$
ATN_SMALL:
	rst	28h
	DEFB	$A0
ATN_CASES:
	DEFB	$01			; exchange: offset, x
	DEFB	$31,$31,$04,$A1,$0F,$28,$A1,$0F,$05	; y = x/(1 + sqr(1 + x*x))
	DEFB	$31,$31,$04,$86	; y, y*y ; series-xx with 6 turns (7 constants)
	DEFB	$6C,$41,$19		; q6
	DEFB	$6D,$AD,$42		; q5
	DEFB	$AD,$62,$1F,$9F		; q4
	DEFB	$AE,$92,$3E,$7E		; q3
	DEFB	$AE,$4C,$CC,$81		; q2
	DEFB	$EF,$AA,$AA,$AA,$44		; q1
	DEFB	$F1,$00,$00,$00,$00		; q0
	DEFB	$04,$3C,$0F,$38	; y*Q(y*y), times 2, plus the offset, end-calc
	ret
