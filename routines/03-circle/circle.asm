; ---------------------------------------------------------------------------
; CIRCLE: integer midpoint algorithm
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $2320-$2354, $238E-$23F6   (158 bytes)
; Replaces: CIRCLE at $2320
; Author: ruijtunes (github.com/ruijtunes)   License: Free to use
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

;

label_2320:
	rst	18h
	cp 	$2C
	jp	nz, label_1C8A

	rst	20h
	call	label_1C82
	call	label_1BEE

	rst	28h
        DEFB    $2A
        DEFB    $3D
        DEFB    $38

        ld      a,(hl)
        cp      $81
        jr      nc,label_233B

        rst     28h
        DEFB    $02
        DEFB    $38

        jr      label_22DC

;;; C-R-GRE-1  71 bytes ($233B  $2381)
label_233B:
       call   label_2314	; STK_TO_A      ;  A = radius
       EX AF,AF'
       call    label_2307       ;STK_TO_BC      ;  C=Xc, B=Yc
       EX AF,AF'
       ld      e,c
       ld      d,b                              ; (d,e) contains the center coordinates (yc, xc)
       ld      c,a                              ; x = r
       ld      b,0                              ; y = 0 ; (b,c) stores the current arc point coordinates (y,x)
       ld      h,b				; error HL= 0 (I need 16 bits)
       ld      l,b

       jp CIRCLE_LOOP              ; jump forward to the main loop of the circle routine.

Plot_circ:
            push    bc
            exx                                      ; keep the registers
            pop     bc
            call    label_22E5+4		     ; plot the point (in BC), without storing COORDS (saves 20 T-states per point)
            exx                                      ; recovers registers.
            ret


; ============================================================
; Circle routine (continued)
; ============================================================
CIRCLE_LOOP:
       push       hl        ; save HL (error) to use as temporary
       push       bc        ; y,x
;------
       LD    a,e
       ADD   c         ; cx+x
       LD    H,A       ; H = cx+x
       SUB   c
       SUB   c         ; cx+x - 2x = cx-x
       LD    L,A       ; L = cx-x
; ==================================================
; 1st OCTANT: (cx+x, cy+y)
; ==================================================
       LD A,b
       ADD A,d
       LD B,A      ; cy+y
       LD C,H      ; cx+x
       CALL  Plot_circ
; ==================================================
; 4th OCTANT: (cx-x, cy+y)
; ==================================================
       LD C,L      ; cx-x
       CALL  Plot_circ
; ==================================================
; 5th OCTANT: (cx-x, cy-y)
; ==================================================
    ;2cy - (cy+y) = cy - y
	ld a,d
	add a,a      ; 2cy
	sub b      ; 2cy - (cy+y)
	LD b,a      ; cy-y
        call  Plot_circ
; ==================================================
; 8th OCTANT: (cx+x, cy-y)
; ==================================================
       	ld c,h      ; cx+x

	call  Plot_circ
; ==================================================
       pop bc
       push bc
       LD   a,e
       ADD   b         ; cx+y
       LD    H,A       ; H = cx+y
       SUB   b
       SUB   b         ; cx+y - 2y = cx-y
       LD    L,A       ; L = cx-y
; ==================================================
; 2nd OCTANT: (cx+y, cy+x)
; ==================================================
       LD A,c
       ADD A,d
       LD B,A      ; cy+x
       LD C,H      ; cx+y
       CALL  Plot_circ
; ==================================================
; 3rd OCTANT: (cx-y, cy+x)
; ==================================================
       LD C,L      ; cx-y
       CALL  Plot_circ
; ==================================================
; 6th OCTANT: (cx-y, cy-x)
; ==================================================
	;2cy - (cy+x) = cy - x
	ld a,d
	add a,a      ; 2cy
	sub b      ; 2cy - (cy+x)
	LD b,a      ; cy-x
	call  Plot_circ
; ==================================================
; 7th OCTANT: (cx+y, cy-x)
; ==================================================
	LD c,H      ; cx+y
	call  Plot_circ
	ld	($5C7D),bc	; COORDS = the last pixel plotted (BC still holds it), once per iteration instead of once per point
;------
        pop    bc                               ; restore y,x to BC
        pop    hl                               ; restore error to HL	               ;
; --- actualiza e, y ---
        ld      a,c                             ; save x
; error += 1 + 2*y (B = y)
        inc     hl                               ; error += 1
        ld      c,b                              ; c <-- y
        ld      b,0                              ; BC = y
        add     hl,bc                            ; error += y
        add     hl,bc                            ; error += y (total: + 2*y)
        ld      b,c
	ld      c,a				 ; restore x to C
        inc     b                                ; y++

; Is error > x ?  T = error - x - 1  (C = x; y is saved in A)

        ld      a,b				     ; save y
        ld      b,0                              ; BC = x
        and     a
        sbc     hl,bc                            ; error - x
	dec     hl                               ; T = error - x - 1
        bit     7,h                              ; T >= 0 ?  (i.e. error > x)

	jr z,XDEC                                ; yes: x-- (and the carry is still clear)

; no: recover the error from T, keep x
        inc     hl
	add     hl,bc                   	     ; error = T + 1 + x
	ld      b,a                                  ; restore y
        jr      TSTOP
; yes: error' = error + 1 - 2x = T + 2 - x
	; x--
XDEC:	inc     hl
	inc     hl                      	  ; T + 2
        sbc     hl,bc                    	  ; - x
	ld      b,a				    ; restore y
	dec     c				    ; x--
TSTOP:
        LD    a,c
        CP    b         ; x vs y
        JR    NC,CIRCLE_LOOP
        JP    label_0D4D
