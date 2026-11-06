; ---------------------------------------------------------------------------
; EXP: exact reduction and a polynomial loop
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $36C4-$370D, $39F1-$39FD, $3AAC-$3ADE   (138 bytes)
; Replaces: EXP at $36C4
; Author: ruijtunes (github.com/ruijtunes)   License: CC BY-NC 4.0 (see LICENSE)
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

	DS	$36C4-$,$FF	; EXP stays at $36C4


label_36C4:

	call	EXP_REDUCE	; x -> r = x - n*ln 2 in mem-0 (the stack is empty), n in mem-3, B = 9. n is truncated towards zero,
				; so |n*ln 2| <= |x| and the subtraction is exact for both signs: r is in (-ln 2, ln 2)
	rst     28h
	DEFB	$A1		;;stk-one         1
	DEFB	$34,$F0,$7F,$FF,$FF,$FE	;;stk-data a0
	DEFB	$34,$EF,$7F,$FF,$FF,$FC	;;stk-data a1
	DEFB	$34,$EE,$2A,$AA,$AB,$A5	;;stk-data a2
	DEFB	$34,$EC,$2A,$AA,$AE,$79	;;stk-data a3
	DEFB	$34,$AA,$08,$88,$12	;;stk-data a4 (3 mantissa bytes: its contribution is small)
	DEFB	$34,$A7,$36,$07,$C9	;;stk-data a5 (3 mantissa bytes: its contribution is small)
	DEFB	$34,$A4,$50,$5E,$B1	;;stk-data a6 (3 mantissa bytes: its contribution is small)
	DEFB	$34,$61,$52,$8E	;;stk-data a7 (2 mantissa bytes: its contribution is small)
	DEFB	$34,$5E,$27,$0E	;;stk-data a8 (2 mantissa bytes: its contribution is small)
					; 1, a0 ... a8: e^r = 1 + r*(a0 + r*(a1 + ... + r*a8)), minimax for r in [-ln 2, ln 2]
EXP_LP:	DEFB	$E0		;;get-mem-0      ... p, r
	DEFB	$04		;;multiply       ... p*r
	DEFB	$0F		;;addition       ... p*r + the constant below it
	DEFB	$35		;;dec-jr-nz      9 times (B = 9)
	DEFB	EXP_LP-$
	DEFB    $E3
	DEFB    $38

        call    label_2DD5
        jp      nz,EXP_NEGT          ; n < 0: the rest is in EXP_NEGT 

        jr      c,label_3703

        add     a,(hl)          ;
        jr      nc,label_370C

label_3703:
	rst	08h
	DEFB    $05

label_370C:
	ld	(hl), a
	ret


; EXP_NEGT: the tail of EXP for n < 0 (A = |n|, carry if |n| > 255, HL -> the result of the polynomial)
EXP_NEGT:
	jr	c,EXP_NZ	; |n| > 255: underflow, zero
	sub	(hl)
	jr	nc,EXP_NZ	; the exponent would not be above zero: zero
	neg
	ld	(hl),a
	ret
EXP_NZ:	xor	a
	jp	label_350B	; FP-0/1 with carry clear writes an integer zero over the value

; ----------------------------------------------------------------------------
; EXP_REDUCE: the argument reduction of EXP, with ln 2 in two parts (Cody and Waite).
; The 1982 routine rounded the product x * (1/ln 2) once and took its fractional part, so the error of the
; product went into the exponent of 2: up to 70 ulp for |x| near 80. Here n = INT(x/ln 2) and
; r = x - n*LN2_HI - n*LN2_LO, where LN2_HI has 24 bits (n*LN2_HI and the first subtraction are exact)
; and LN2_LO = ln 2 - LN2_HI. So r is in [0, ln 2) with an error of about 1 ulp, and e^x = 2^n * e^r.
; If |n| is more than 255 the argument is out of range and the answer is known at once: report 6 for a
; positive x, zero for a negative one (the polynomial of EXP could not be evaluated for a huge r).
; In:  x on the calculator stack.   Out: the stack without x, r in mem-0, n in mem-3, B = 7 for the loop of EXP.
; ----------------------------------------------------------------------------
EXP_REDUCE:
	rst	28h
	DEFB	$31
	DEFB	$34,$F1,$38,$AA,$3B,$29	;;stk-data 1/ln 2   x,x,1/ln2
	DEFB	$04			;;multiply      x,y
	DEFB	$3A			;;truncate      x,n   (towards zero: |n*ln 2| <= |x|, so the subtraction below is exact for x < 0 too)
	DEFB	$C3			;;st-mem-3      mem-3 = n (the tail of EXP uses it)
	DEFB	$38
	call	label_2DD5		; FP-TO-A: pops n; carry if |n| > 255, NZ if n < 0. HL -> x
	jr	nc,EXP_RED_OK
	jr	nz,EXP_RED_ZERO	; a negative x: the result is zero
	rst	08h
	DEFB	$05			; a positive x: report 6, Number too big
EXP_RED_ZERO:
	pop	af			; drop the return into EXP
	xor	a			; carry clear: FP-0/1 writes zero
	jp	label_350B		; over x, and returns to the caller of EXP
EXP_RED_OK:
	rst	28h
	DEFB	$E3			;;get-mem-3     x,n
	DEFB	$34,$F0,$31,$72,$17,$00	;;stk-data LN2_HI (24 bits)
	DEFB	$04			;;multiply      x, n*HI (exact)
	DEFB	$03			;;subtract      r1 = x - n*HI (exact)
	DEFB	$E3			;;get-mem-3     r1, n
	DEFB	$34,$D8,$77,$D1,$CF,$78	;;stk-data LN2_LO = ln 2 - LN2_HI
	DEFB	$04			;;multiply      r1, n*LO
	DEFB	$03			;;subtract      r
	DEFB	$C0			;;st-mem-0      mem-0 = r
	DEFB	$02
	DEFB	$38
	ld	b,9			; the loop of EXP goes round 9 times (EXP's RST 28 loads BREG from B)
	ret
