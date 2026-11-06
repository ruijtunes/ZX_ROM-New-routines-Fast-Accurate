; ---------------------------------------------------------------------------
; PLOT-SUB: a lookup table for the pixel mask
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $22E5-$2306, $2400-$2407   (42 bytes)
; Replaces: PLOT-SUB at $22E5
; Author: ruijtunes (github.com/ruijtunes)   License: Free to use
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

; B = Y pixel position
; C = X pixel position
;
;## Semantics
;| `OVER` | `INVERSE` | Action                              |
;| :----: | :-------: | ----------------------------------- |
;|   0    |     0     | Set pixel                           |
;|   1    |     0     | Toggle pixel (XOR)                  |
;|   0    |     1     | Reset pixel                         |
;|   1    |     1     | Recompute attribute, leave pixel    |

label_22E5:
	ld 	($5C7D), bc	     ; store new x/y values in COORDS for attribute update
label_22E9:			     ; entry used by CIRCLE (Plot_circ): the same plot without the COORDS store
	call	$22AA ;PIXEL_ADD     ; compute screen address in HL and pixel bit index in A

; New optimization with LUT for the PLOT routine.
   	;ld   bc, Mask_tab
	;add  a,c

	ld b, Mask_tab >> 8
    	ld   c, a                     ; turn pixel index into an offset into Mask_tab
    	ld   a, (bc)                  ; read mask where target bit is 0, others are 1
;----
    	ld      b, a    	     ; keep the mask in B for later pixel operations.
	ld	a, (hl)	             ; load the current screen byte for this pixel

	ld	c, (iy + $57)
	bit	0, c
	jr	nz, label_22FD	     ; skip clearing step when OVER=1
				     ; OVER=0 path: clear only the selected pixel bit
	and 	b	             ; blank the target bit while preserving the others

label_22FD:
	bit	2, c	             ; INVERSE flag set? if so, leave pixel reset
	jr	nz, label_2303       ; skip set/toggle logic when inverse=1
	xor 	b	             ; set/toggle the target bit using the zero-mask
	cpl   			     ; restore the other 7 bits to their original values

label_2303:
	ld	(hl), a
	jp	$0BDB
	nop 			     ; 3 free byte for alignment
	nop
	nop


Mask_tab:
;; lookup table with mask for plot
   	DEFB    $7F   		    ;01111111 ($7F)
	DEFB    $BF   		    ;10111111 ($BF)
	DEFB    $DF   		    ;11011111 ($DF)
	DEFB    $EF   		    ;11101111 ($EF)
	DEFB    $F7   		    ;11110111 ($F7)
	DEFB    $FB   		    ;11111011 ($FB)
	DEFB    $FD   		    ;11111101 ($FD)
	DEFB 	$FE   		    ;11111110 ($FE)
