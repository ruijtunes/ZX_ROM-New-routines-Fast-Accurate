; ---------------------------------------------------------------------------
; SQR: Júlia's method plus one Newton step
; ZX Spectrum 48K ROM replacement routine 
; ROM address range(s): $384A-$3850, $386E-$38D7   (113 bytes)
; Replaces: SQR at $384A (it was x ** 0.5)
; Author: ruijtunes (github.com/ruijtunes)   License: CC BY-NC 4.0 (see LICENSE)
; The routine ; assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

; THE 'SQUARE ROOT' FUNCTION  (Offset $28: 'sqr')
;   The entry stays at $384A, in the 7 bytes of the original routine (which went into to-power):
;   re-stack, fetch the exponent, test for zero and jump to the rest of the routine, which starts
;   at SQR_REST with the RET Z of that test.
SQR:
	RST	28h			;; FP-CALC                    x
	DEFB	$3D			;;re-stack                    x  (full f.p. form)
	DEFB	$38
	LD	A,(HL)			; A = e  (end-calc leaves HL -> exponent byte of the value on top)
	AND	A
	JR	SQR_REST		; to the RET Z that completes the test


; THE 'SQUARE ROOT' FUNCTION   (Offset $28: 'sqr')   - Julia's method + one Newton-Raphson step, 111 bytes
;   sqr x ~ n + (x - n^2)/(2n+1) (Julia's regression, in integer arithmetic) followed by ONE
;   Newton-Raphson step.  Replaces the original routine (x ** 0.5 through to-power) and the
;   Newton-Raphson loop with its iteration counter and its toggle.  Uses calculator mem-3 (the original routine, through LN and EXP, wrote mem-0 to mem-3).

SQR_REST:
         RET Z             ; return if so - with zero on the stack (A = e, flags set at the entry, $384A)

; --- 1. Read the mantissa as x' = M + F/65536 and work out the exponent ----

         INC HL
         LD D,(HL)
         BIT 7,D           ; negative argument?
         JP NZ,label_371A   ; REPORT_A: 'Invalid argument'
         INC HL
         LD E,(HL)
         INC HL
         LD B,(HL)
         INC HL
         LD C,(HL)         ; DE:BC = 32-bit mantissa
         SET 7,D           ; restore the implicit leading 1
                           ; even e: x' = DE:BC / 65536   in [2^15, 2^16)
         SRL A             ; A = e/2,  carry = e odd
         JR NC,SQ_EVEN
         SRL D             ; odd e: x' = DE:BC / 131072  in [2^14, 2^15)
         RR E
         RR B
         RR C              ;        (lowest bit dropped: < 0.5 ulp of sqr x)
         INC A             ;        A = (e+1)/2
SQ_EVEN:     ADD A,64          ; A = exponent byte of sqr x = 136 + k
         PUSH AF
         PUSH BC           ; save F = fraction of x'
                           ; DE = M = INT x'   (16384 <= M < 65536)

; --- 2. Julia's progression: largest n with n^2 <= M ----------------------
;     Start from the known square 128^2 = 16384.
;     Each step: n = n+1 and R = R - (n + (n+1)) while R stays >= 0.

         LD A,D
         SUB 64            ; M >= 16384, so no borrow: carry = 0
         LD H,A
         LD L,E            ; HL = R = M - 128^2
         LD BC,255         ; BC = 2n-1 for n = 128
SQ_LOOP:     INC BC
         INC BC            ; BC = 2n+1 = n + (n+1)
         SBC HL,BC         ; R = M - (n+1)^2
         JR NC,SQ_LOOP        ; still >= 0: (n+1)^2 <= M, go on
                           ; exit: (n+1)^2 > M >= n^2,  BC = 2n+1
         ADD HL,BC         ; undo last step: HL = M - n^2  (0..2n)
         POP DE            ; DE = F
                           ; x' - n^2 = HL + DE/65536

; --- 3. Shortcut for perfect squares: x' - n^2 = 0 -------------------------

         LD A,H
         OR L
         OR D
         OR E
         JR Z,SQ_EXACT        ; x' = n^2 exactly

; --- 4. Julia's regression:  Q = INT((x' - n^2) * 65536 / (2n+1)) ---------
;     Restoring division of HL:DE by BC. HL < BC, so the quotient has
;     16 bits; they are shifted into DE as the dividend bits move out.

         LD A,16           ; 16 quotient bits
SQ_DIV:      SLA E
         RL D              ; next dividend bit -> carry
         ADC HL,HL         ; remainder = 2 * remainder + bit  (< 1022)
         SBC HL,BC         ; try to subtract 2n+1  (carry is 0 here)
         INC E             ; assume quotient bit = 1
         JR NC,SQ_DNEXT
         ADD HL,BC         ; did not fit: restore,
         DEC E             ; quotient bit = 0
SQ_DNEXT:    DEC A
         JR NZ,SQ_DIV         ; DE = Q

;     Build r = n + Q/65536 = 0.1nnnnnnn QQQQQQQQ QQQQQQQQ 00000000 * 2^8,
;     scaled by 2^k, directly as a 5-byte number.

         LD A,E
         SRL C             ; C = INT((2n+1)/2) AND $FF = n AND $7F
                           ; (n >= 128: its top bit is the implicit 1,
                           ;  replaced by the sign bit 0)
         LD E,C            ; E = 1st mantissa byte
         LD C,A            ; D:C = Q = 2nd and 3rd mantissa bytes
         LD B,0            ; 4th mantissa byte
         POP AF            ; A = exponent = 136 + k
         CALL label_2AB6    ; stack r ~ sqr x             x, r

; --- 5. One Newton-Raphson step:   r = (x/r + r) / 2 ------------------------

         RST $28           ;; FP-CALC                    x, r
         DEFB $C3          ;;st-mem-3                    x, r       (mem-3 = r)
         DEFB $05          ;;division                    x/r
         DEFB $E3          ;;get-mem-3                   x/r, r
         DEFB $0F          ;;addition                    x/r + r
         DEFB $38
                           ; HL -> exponent byte of x/r + r
         DEC (HL)          ; exponent - 1:               (x/r + r) / 2
         RET               ; return with square root on the stack

; --- 3a. Exact square:  sqr x = n * 2^k -------------------------------------
;     Here D = E = 0.

SQ_EXACT:    SRL C             ; C = n AND $7F
         LD E,C            ; E = 1st mantissa byte
         LD C,D
         LD B,D            ; other mantissa bytes = 0
         POP AF            ; A = exponent = 136 + k
         CALL label_2AB6    ; stack n * 2^k               x, sqr x
         RST $28
         DEFB $01          ;;exchange                    sqr x, x
         DEFB $02          ;;delete                      sqr x
         DEFB $38
         RET               ; return with square root on the stack
