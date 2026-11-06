; ---------------------------------------------------------------------------
; Calculator literal $3C: multiply by 2
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $3829-$3832   (10 bytes)
; Replaces: The pair duplicate, addition ($31 $0F) used wherever a value is doubled
; Author: ruijtunes (github.com/ruijtunes)   License: Free to use
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

;;
; ----------------------------------------------------------------------------
; MUL2: the calculator literal $3C, 'mul-by-2'. It replaces 'duplicate, addition' (2 bytes, about 2000 T-states)
; by one byte and about 290 T-states: the exponent of the top of the stack goes up by one.
; A small integer is first converted to floating point (RE-STACK); zero stays zero.
; Entry as for every unary literal: HL -> the top of the calculator stack. Changes only A (and the exponent byte).
; ----------------------------------------------------------------------------
MUL2:
	call	label_3297		; re-stack: a small integer becomes a floating-point number (a float is left as it is)
	ld	a,(hl)			; the exponent
	and	a
	ret	z			; zero: 2*0 = 0
	inc	(hl)			; times 2
	ret	nz
	rst	08h			; the exponent went from $FF to $00: overflow
	DEFB	$05			; report 6: Number too big
