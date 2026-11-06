; ---------------------------------------------------------------------------
; DRAW x,y,angle: circular arcs
; ZX Spectrum 48K ROM replacement routine
; ROM address range(s): $2355-$2381, $23F7-$23FF, $2408-$24B6   (229 bytes)
; Replaces: DR-3-PRMS and the arc routine of the 1982 ROM (291 bytes)
; Author: ruijtunes (github.com/ruijtunes)   License: CC BY-NC 4.0 (see LICENSE)
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

DR_3_PRMS:
;label_238D:
	rst	20h
	call	label_1C82
	call	label_1BEE
ARC_YES:
; Entry: calculator stack = [dx,dy,A].  The old "A=0 -> straight line" test is gone:
; the guard below covers A=0 and every A=2*PI*k, also the ones for which the
; floating-point SIN(A/2) is not exactly zero (the 1982 routine fails on 21 of the
; first 60 multiples of 2*PI).  |SIN(A/2)| < 2^-14 is treated as zero: the radius
; would be > 16000 times the chord, i.e. a straight line to the pixel.
; The centre of the arc (Rx0,Ry0) does not depend on N, so it is computed first;
; its size R'=|Rx0|+|Ry0| then sets N (see ARC_SETUP).  Ry0 is parked in MEM4
; SIN/COS trash MEM0-MEM2.
	rst	28h
	DEFB	$C5                       ; MEM5=A (keep)                  [dx,dy,A]
	DEFB	$A2,$04                   ; half,mul       -> A/2
	DEFB	$31,$20,$01,$1F           ; dup,cos,exch,sin               [dx,dy,cos,sin]
	DEFB	$3D,$38                   ; re-stack, end-calc (HL -> sin)
	ld	a,(hl)                    ; exponent byte of sin(A/2) (0 if zero)
	cp	$73                       ; |sin| < 2^-14 ?
	jr	nc,ARC_NOT0
	jp	ARC_EXIT                  ; yes: straight line
ARC_NOT0:
	rst	28h
	DEFB	$05                       ; div            -> k' = cot(A/2) = 2k
	DEFB	$C2,$02                   ; MEM2=k' ; delete               [dx,dy]
	DEFB	$C0,$01,$C1               ; MEM0=dy ; exch ; MEM1=dx       [dy,dx]
	DEFB	$E0,$E2,$04,$E1,$03       ; dy*k' - dx
	DEFB	$A2,$04                   ; /2             -> Rx0          [dy,dx,Rx0]
	DEFB	$C3,$02                   ; MEM3=Rx0 ; delete              [dy,dx]
	DEFB	$38
	jp	ARC_SETUP


; ARC_EXIT: drop cos,sin and draw the straight line (7 bytes; in the gap before Mask_tab)
ARC_EXIT:
	rst	28h
	DEFB	$02,$02,$38               ; delete cos,sin                 [dx,dy]
	jp	label_24B7
	ASSERT $ <= $2400
; 0 free bytes remaining in this pocket
  ORG $2400


; ============================================================
; DRAW x,y,angle  --  arc via incremental rotation
; ============================================================
; BASIC's DRAW x,y,angle asks for an arc of radius r passing through
; (0,0) and (dx,dy). Instead of calling SIN/COS for every point (slow
; and error-prone), the arc's centre is computed ONCE, then a vector R
; (from the centre to the current point) is rotated by a fixed angle
; delta = angle/N, N times in a row: each rotation is just 4
; multiplications and 2 additions (cos/sin of delta are already ready
; from ARC_SETUP).
;
; If we just plotted point by point, the "rotated R" would keep
; accumulating rounding error, giving crooked arcs after a few
; segments. The fix (inspired by the ROM itself, in CD_PRMS1/DRAW):
; at each step compare the IDEAL point with the REAL point where the
; cursor actually landed (read from COORDS) and draw only the
; DIFFERENCE. That way one step's error never contaminates the next -
; each segment starts from where the screen really is, not from where
; the maths "thought" it was.
;
; The ideal point (ideal_X,ideal_Y) is kept on the calculator's OWN
; STACK, not in MEM.
;
; Entry: calculator stack = [dx, dy, angle]
; MEM1=Ry  MEM3=Rx  MEM4=cos(delta)  MEM5=sin(delta)
ARC_SETUP:
	rst	28h
	DEFB	$E2,$04,$0F               ; dx*k' + dy  (dy,dx come off the stack)
	DEFB	$A2,$04,$1B               ; /2, negate     -> Ry0
	DEFB	$C4,$2A                   ; MEM4=Ry0  ; abs      [|Ry0|]
	DEFB	$38

; ---- ARC option: reduction of the angle (run-time flag) ---------------------
; FLAGS2 ($5C6A = 23658), bit 6 (unused by the ROM):
;   bit 6 = 0 : the angle is used as given (1982 behaviour; N saturates at 252).
;   bit 6 = 1 : |A| >= 2*PI is reduced keeping ONE full turn (A in [2PI,4PI)).
;   POKE 23658,PEEK 23658+64   : on        POKE 23658,PEEK 23658-64  : off
; ----------------------------------------------------------------------------

	bit	6,(iy+$30)                ; FLAGS2 bit 6 set: reduce the angle (keep one turn)
	jr	z,ARC_NOMOD

	rst	28h
	; Goal:  A'' = A - 2*PI*T ,   T = TRUNC(A/(2*PI)),   stored in MEM5.
	;        |A| < 2*PI : T = 0  -> A'' = A            (unchanged)
	;        |A| >= 2*PI: removes all the turns, sign kept (A'' in [0,2PI))
	; Stack below: [|Ry0|]; MEM5 holds A; MEM0 is free (dy is no longer needed).
	DEFB	$E5                       ; get_mem_5         A                       [|Ry0|, A]
	DEFB	$31                       ; duplicate                                 [.., A, A]
	DEFB	$A3                       ; stk_pi_div_2      PI/2                    [.., A, A, PI/2]
	DEFB	$3C		;;mul-by-2 (it was duplicate, addition)
	DEFB	$3C		;;mul-by-2 (it was duplicate, addition)
	DEFB	$C0                       ; st_mem_0          MEM0 = 2*PI (kept)      [.., A, A, 2PI]
	DEFB	$05                       ; division          U = A/(2*PI)            [.., A, U]
	DEFB	$3A                       ; truncate          T = TRUNC(U), toward 0  [.., A, T]
	;DEFB	$31                       ; duplicate                                 [.., A, T, T]
	;DEFB	$29                       ; sgn               SGN T (-1, 0 or +1)     [.., A, T, SGN T]
	;DEFB	$03                       ; subtract          T - SGN T (turns to drop) [.., A, T-SGN T]
	DEFB	$E0                       ; get_mem_0         2*PI                    [.., A, T-SGN T, 2PI]
	DEFB	$04                       ; multiply          2*PI*(T - SGN T)        [.., A, 2PI*(T-SGN T)]
	DEFB	$03                       ; subtract          A'' = A - 2PI*(T-SGN T) [|Ry0|, A'']
	DEFB	$C5                       ; st_mem_5          MEM5 = A'' (kept)       [|Ry0|, A'']
	DEFB	$02                       ; delete            only MEM5 keeps A''     [|Ry0|]
	DEFB	$38
; ----------------------------------------------------------------------------
ARC_NOMOD:
	rst	28h
	DEFB	$E3,$2A,$0F               ; + |Rx0|                        R' = |Rx0|+|Ry0|
	DEFB	$34,$36,$40,$0F           ; + 48                           R'+48  (constant 0.75*2^6) (constante em stk-data, 3 bytes + soma)
	DEFB	$E5,$04                   ; * A  (FP-TO-A ignores the sign)
	DEFB	$34,$2D,$00,$04           ; * 1/16                         A*(R'+48)/16 = |A|*(3 + R'/16)
	DEFB	$38
	call	label_2DD5                ; FP-TO-A: A=round(|x|); carry if |x| > 255
	jr	c,ARC_N_SAT
	add	a,4                       ; N = 4 + x
	ld	c,a
	jr	nc,ARC_N_OK
ARC_N_SAT:
	ld	bc,252                    ; saturate: N = 252, the 1982 limit (B=0)
ARC_N_OK:
	push	bc                        ; save N (loop counter)
	call	label_2D2B                ; push N onto the calculator stack
	rst	28h
	DEFB	$E5,$01,$05               ; A/N            -> delta
	DEFB	$31,$20,$01,$1F           ; dup,cos,exch,sin -> cosD,sinD
	DEFB	$C5,$02                   ; sinD -> MEM5
	DEFB	$C1,$02                   ; cosD -> MEM1   (loop: MEM1=cosD, MEM4=Ry)
	DEFB	$38
	; The ideal point (ideal_X,ideal_Y) starts at the starting point
	; itself and stays on the calculator STACK for the whole loop -
	; never in MEM, so it keeps full precision from start to finish.
	ld	hl, ($5C7D)
	ld	a, l
	push	hl                        ; STACK-A clobbers HL: keep COORDS
	call	label_2D28                ; push start_X          [start_X]   (STACK-A = LD C,A / LD B,0 / STACK-BC)
	pop	hl
	ld	a, h
	call	label_2D28                ; push start_Y   [ideal_X,ideal_Y]

	pop	bc                ; retrieve N (saved earlier)
	ld	b, c              ; B = segment counter
; ------------------------------------------------------------
; Main loop: one rotation + one segment per turn
; ------------------------------------------------------------
; Each turn: (1) rotate (Rx,Ry) by delta, giving the arc's next point
; relative to the centre; (2) add that rotation's DIFFERENCE
; (new_R - old_R) to the ideal point, which keeps accumulating on the
; stack; (3) compare with the cursor's REAL position (COORDS) and draw
; only that difference - the closed loop that stops one segment's
; rounding error from contaminating the next.
;
; MEM0 and MEM2 here just act as temporary "courier" to carry a value
; from the top of the stack down to a deeper position (the calculator
; only swaps the top 2 values with EXCH, there's no direct way to swap
; something 3 deep); they never need to survive a call to DRAW-LINE.
ARC_LOOP:
	push	bc                ; save the counter (draw-line uses BC)
	rst	28h
	; rotate (Rx,Ry) by delta -> (new_Rx,new_Ry)
	DEFB	$E3, $E1, $04             ; Rx*cosD
	DEFB	$E4, $E5, $04             ; Ry*sinD
	DEFB	$03                       ; subtract      -> new_Rx        [ideal_X,ideal_Y,new_Rx]
	DEFB	$E3, $E5, $04             ; Rx*sinD
	DEFB	$E4, $E1, $04             ; Ry*cosD
	DEFB	$0F                       ; addition      -> new_Ry        [ideal_X,ideal_Y,new_Rx,new_Ry]
	; delta_Ry = new_Ry-old_Ry, already saving new_Ry to MEM4 for the next turn
	DEFB	$31                       ; dup                             [...,new_Rx,new_Ry,new_Ry]
	DEFB	$E4                       ; old_Ry (MEM4 still intact)
	DEFB	$03                       ; subtract -> delta_Ry            [...,new_Rx,new_Ry,delta_Ry]
	DEFB	$01                       ; exch                            [...,new_Rx,delta_Ry,new_Ry]
	DEFB	$C4                       ; MEM4=new_Ry (doesn't consume)
	DEFB	$02                       ; delete                          [ideal_X,ideal_Y,new_Rx,delta_Ry]
	; delta_Rx = new_Rx-old_Rx, already saving new_Rx to MEM3
	DEFB	$01                       ; exch                            [ideal_X,ideal_Y,delta_Ry,new_Rx]
	DEFB	$31                       ; dup                             [...,delta_Ry,new_Rx,new_Rx]
	DEFB	$E3                       ; old_Rx (MEM3 still intact)
	DEFB	$03                       ; subtract -> delta_Rx            [...,delta_Ry,new_Rx,delta_Rx]
	DEFB	$01                       ; exch                            [...,delta_Ry,delta_Rx,new_Rx]
	DEFB	$C3                       ; MEM3=new_Rx (doesn't consume)
	DEFB	$02                       ; delete                          [ideal_X,ideal_Y,delta_Ry,delta_Rx]
	; add the deltas to the ideal point (buried 2 positions below);
	; MEM0/MEM2 just act as a courier to reach it
	DEFB	$C0                       ; MEM0=delta_Rx (doesn't consume)
	DEFB	$02                       ; delete                          [ideal_X,ideal_Y,delta_Ry]
	DEFB	$C2                       ; MEM2=delta_Ry (doesn't consume)
	DEFB	$02                       ; delete                          [ideal_X,ideal_Y]
	DEFB	$01                       ; exch                            [ideal_Y,ideal_X]
	DEFB	$E0                       ; delta_Rx
	DEFB	$0F                       ; add -> new ideal_X              [ideal_Y,ideal_X]
	DEFB	$01                       ; exch                            [ideal_X,ideal_Y]
	DEFB	$E2                       ; delta_Ry
	DEFB	$0F                       ; add -> new ideal_Y              [ideal_X,ideal_Y]
	DEFB	$38

	; segment = ideal - real position (COORDS); we duplicate ideal_X
	; and ideal_Y BEFORE spending them on the subtraction, so they
	; survive for the next turn - only the copy gets consumed.
	rst	28h
	DEFB	$31                       ; dup                                [ideal_X,ideal_Y,ideal_Y]
	DEFB	$38
	ld	hl, ($5C7D)
	push	hl
	ld	a, h
	call	label_2D28                ; push actual Y  [ideal_X,ideal_Y,ideal_Y,actual_Y]
	rst	28h
	DEFB	$03                       ; sub -> seg_dy (only the copy is spent) [ideal_X,ideal_Y,seg_dy]
	DEFB	$C0, $02                  ; MEM0=seg_dy (park it for now)
	DEFB	$01                       ; exch                                [ideal_Y,ideal_X]
	DEFB	$31                       ; dup                                 [ideal_Y,ideal_X,ideal_X]
	DEFB	$38
	pop	hl
	ld	a, l
	call	label_2D28                ; push actual X  [ideal_Y,ideal_X,ideal_X,actual_X]
	rst	28h
	DEFB	$03                       ; sub -> seg_dx (only the copy is spent) [ideal_Y,ideal_X,seg_dx]
	DEFB	$C2, $02                  ; MEM2=seg_dx (park it)
	DEFB	$01                       ; exch                                [ideal_X,ideal_Y]  <- survive!
	DEFB	$E2                       ; seg_dx
	DEFB	$E0                       ; seg_dy
	DEFB	$38                       ; end-calc                            [ideal_X,ideal_Y,seg_dx,seg_dy]
	call	label_24B7        	  ; DRAW-LINE only spends the top 2 (the segment);
					  ; ideal_X,ideal_Y stay buried for the next turn
	pop	bc
	djnz	ARC_LOOP

	; after the LAST turn, ideal_X,ideal_Y are still buried on the
	; calculator's stack (only the segment was ever consumed, never them).

	rst	28h
	DEFB	$02, $02                  ; delete,delete -> []
	DEFB	$38
	ret
; ============================================================

	ASSERT $ <= $24B7
