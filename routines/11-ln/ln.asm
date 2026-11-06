; ---------------------------------------------------------------------------
; LN: through atanh and a short polynomial
; ZX Spectrum 48K ROM replacement routine
; ROM address range(s): $3713-$3771   (95 bytes)
; Replaces: LN at $3713
; Author: ruijtunes (github.com/ruijtunes)   License: CC BY-NC 4.0 (see LICENSE)
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

label_3713:
	RST     28H
        DEFB    $3D
        DEFB    $31
        DEFB    $37
        DEFB    $00
        DEFB    $04
        DEFB    $38
label_371A:  RST     08H
        DEFB    $09
label_371C:
        DEFB    $38
        LD      A,(HL)          ; the exponent byte of x
        LD      (HL),$80        ; x = m * 2^e with m in [0.5, 1)
        CALL    label_2D28      ; routine STACK-A: the exponent byte on the stack
	LD	B,4		; the Horner loop below goes round 4 times (RST 28 loads BREG from B)
        RST     28H
        DEFB    $34,$38,$00     ;;stk-data 128
        DEFB    $03             ;;subtract         m, e
        DEFB    $01             ;;exchange         e, m
        DEFB    $31             ;;duplicate        e, m, m
        DEFB    $34,$30,$40     ;;stk-data 3/4 (one mantissa byte: the threshold needs no more)
        DEFB    $03
        DEFB    $37             ;;greater-0        m > 3/4 ?
        DEFB    $00
        DEFB    label_373D-$    ;;to GRE.8: yes, m is already in (3/4, 3/2]
        DEFB    $01             ;;exchange         no: m*2 and e-1
        DEFB    $A1
        DEFB    $03
        DEFB    $01
        DEFB    $38
        INC     (HL)            ; m * 2
	LD	B,4
        RST     28H
label_373D:  DEFB    $01        ;;exchange         m, e
        DEFB    $34,$F0,$31,$72,$17,$F8 ;;stk-data ln 2
        DEFB    $04             ;;multiply         m, E = e*ln 2
        DEFB    $01             ;;exchange         E, m
        DEFB    $31             ;;duplicate        E, m, m
        DEFB    $A2
        DEFB    $03             ;;subtract         m - 1/2: exact
        DEFB    $A2
        DEFB    $03             ;;subtract         E, m, m-1: exact (a subtraction of 1 would lose the last bit of m: the ROM's addition has no guard bit)
        DEFB    $01             ;;exchange         E, m-1, m
        DEFB    $A1
        DEFB    $0F             ;;addition         E, m-1, m+1
        DEFB    $05             ;;division         E, z = (m-1)/(m+1), z from -0.143 to 0.2
        DEFB    $31             ;;duplicate        E, z, z
        DEFB    $31             ;;duplicate        E, z, z, z
        DEFB    $04             ;;multiply         E, z, w = z*z
        DEFB    $C0             ;;st-mem-0         mem-0 = w
        DEFB    $02             ;;delete           E, z
        DEFB    $A1
        DEFB    $3C             ;;mul-by-2         E, z, c0 = 2
	DEFB	$34,$F0,$2A,$AA,$A9,$D5	;;stk-data c1 (4 mantissa bytes)
	DEFB	$34,$AF,$4C,$CE,$19	;;stk-data c2 (3 mantissa bytes)
	DEFB	$34,$AF,$11,$EF,$22	;;stk-data c3 (3 mantissa bytes)
	DEFB	$34,$6E,$77,$45	;;stk-data c4 (2 mantissa bytes)
LN_LP:	DEFB	$E0		;;get-mem-0      ... p, w
        DEFB    $04             ;;multiply         p*w
        DEFB    $0F             ;;addition         p*w + the constant below
        DEFB    $35             ;;dec-jr-nz        4 times
        DEFB    LN_LP-$
        DEFB    $04             ;;multiply         E, z*P(w) = ln m
        DEFB    $0F             ;;addition         E + ln m = ln x
        DEFB    $38
        RET
