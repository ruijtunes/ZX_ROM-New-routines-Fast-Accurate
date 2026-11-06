; ---------------------------------------------------------------------------
; Integer powers by squaring
; ZX Spectrum 48K ROM replacement routine
; ROM address range(s): $3A6C-$3AAB   (64 bytes)
; Replaces: TO-POWER for integer exponents (the 1982 ROM computes every power through LN and EXP)
; Author: ruijtunes (github.com/ruijtunes)   License: CC BY-NC 4.0 (see LICENSE)
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; THE 'IPOW' FAST PATH FOR 'TO-POWER'  (new: X^Y by squares, left to right)
; ----------------------------------------------------------------------------
;   The operation table (offset $06) points here instead of at TO-POWER; X and Y are on the calculator stack.
;   If Y is a small integer n with 1 <= |n| <= 64, X^|n| is computed with one squaring per bit of n and one
;   multiplication per bit set (about 2 to 6 times faster than n multiplications);
;   for a negative n the result is inverted at the end (1/r), about 8 to 18 times faster than LN/EXP.
;   The result is exact when it fits in 32 bits, and negative bases work ((-2)^3 = -8).  Anything else (n = 0,
;   |n| > 64, a fraction, or a number in floating-point form) goes on to the old TO-POWER at $3851, untouched.
;   Entry: HL -> X, DE -> Y (as for every binary operation).  Uses calculator mem-0 and the ROM's INT-FETCH.
;   Above 64 the error of the squares grows with n (up to 86 ulp at 255), so those go to LN/EXP as before.

IPOW:
        ex      de,hl           ; HL -> Y
        ld      a,(hl)
        and     a
        jr      nz,IPW_GEN       ; Y in floating-point form
        call    label_2D7F       ; C = sign (00/FF), DE = |Y|
        ld      a,d
        and     a
        jr      nz,IPW_GEN       ; |Y| >= 256
        ld      a,e
        dec     a
        cp      64
        jr      nc,IPW_GEN       ; Y = 0 or |Y| > 64:  |Y|-1 must be 0..63
        push    bc              ; keep the sign (C) for the end
        ld      a,e
        scf
        adc     a,a             ; carry:A = 2n+1   (a 1 below the lowest bit of n: the sentinel)
        jr      c,IPW_G
IPW_F:   add     a,a
        jr      nc,IPW_F         ; the leading 1 of n goes out; A = the bits below it, then the sentinel
IPW_G:   push    af
        rst     28h
        DEFB    $02             ; delete                X
        DEFB    $C0             ; st-mem-0              X     (mem-0 = X)
        DEFB    $38
        pop     af
IPW_LP:  add     a,a             ; carry = next bit; Z = only the sentinel was left
        jr      z,IPW_END
        push    af
        rst     28h
        DEFB    $31
        DEFB    $04             ; multiply              r*r
        DEFB    $38
        pop     af
        jr      nc,IPW_LP        ; bit = 0
        push    af
        rst     28h
        DEFB    $E0             ; get-mem-0
        DEFB    $04             ; multiply              r*X
        DEFB    $38
        pop     af
        jr      IPW_LP
IPW_END: pop     bc
        inc     c
        ret     nz              ; positive exponent: done
        rst     28h
        DEFB    $A1
        DEFB    $01
        DEFB    $05             ; division              1/r
        DEFB    $38
        ret
IPW_GEN: jp      label_3851
