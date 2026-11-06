; ---------------------------------------------------------------------------
; RND: integer generator
; ZX Spectrum 48K ROM replacement routine -- excerpt of the ROM source
; ROM address range(s): $25F8-$2624   (45 bytes)
; Replaces: RND (S-RND) at $25F8
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

;************************************************************************************->
; RND based on SAM Coupe ROM 3.0 Last official release, source code on github https://github.com/simonowen/samrom/tree/master
; SAM ROM by (Andrew J.A. Wright 1989-90); Dr. Andy Wright
; In 2008, he granted permission for all of his SAM Coupe titles and ROMs to be freely redistributed
; Dr. Wright was known for developing and selling BetaBASIC
; This RND implementation is much faster than the original ZX Spectrum implementation (more than 5x) using only integer operations
;***************************************************************************************

; ALGORITHM LCG - Linear Congruential Generator
; X_(n+1)=(aX_n+c) mod m
; m - the "modulus" ; a - the "multiplier"; c - the "increment" are integer constants
; that specify the generator
; X0 is the "seed" or "start value"
; ZX81, ZX Spectrum uses m=2^16+1, a =75, c=0
; SAM uses X_(n+1) = (254 Ã (X_n + 1) mod 65537)-1 = (254ÃX_n + 253) mod 65537
; m=65537 is a Fermat(4) prime 2^16+1
; 254 like 75 is a primitive root modulo 65537 ; c= 253
; Output: (X_n -1)/2^16   in [0,1[
;************************************************************************************
label_25F8:
	CALL	label_2530
	JR	z, label_2625
label_25FD:
	LD B,0			; B=0, used as zero operand in SBC to propagate
                        	; carry without adding value

	LD HL,($5C76)   	; HL = X_n  (current SEED from system variable)
 	LD E,$FD		; E = 253 = c
 	LD D,L			; D = L  
                     		; 

 	LD A,H			; A = H  (high byte of X_n, saved for 32-bit arithmetic)
 	ADD HL,HL		; 
				;  (overflow)
 	SBC A,B			; A = H - carry  (B=0)
                      		; captures the overflow bit into A
                       		; A:HL now holds 2ÃX_n as a 32-bit value
 	EX DE,HL  	
	SBC HL,DE		
 							; carry_out = borrow from low 16-bit subtraction

 	SBC A,B			; A = A - 0 - carry_out  (B=0)
                        	; propagates borrow into high byte
                        	; A now holds high byte of the 32-bit result

	LD C,A			; C = A  â  BC = A (since B=0, C is low byte)
	SBC HL,BC		; HL = HL - A - carry
                       		; subtracting A completes the mod 65537 reduction
 	JR NC,IMRND1		; if no borrow, result is in [0, 65536], skip adjustment
 	INC HL			; result was negative (HL wrapped), add 1
                        	; keeps result in [0, 65536]

IMRND1: LD ($5C76),HL  		; store X_(n+1) in SEED for next starting point.

	LD C,L
	LD B,H
	call	label_2D2B
	rst	28h
	DEFB    $3D         	;re-stack, its exponent is therefore available.
				;EXP WILL BE 00 IF ZERO, ELSE 81-90H
	DEFB    $38

	LD A, (HL)
	SUB $10
	JR c,label_2625
	LD (HL), A	        ; new expoent

	;  2 bytes shorter than original ZX Spectrum RND implementation
	nop
	nop
