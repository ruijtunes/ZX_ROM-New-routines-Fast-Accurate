; ---------------------------------------------------------------------------
; Editor: letter-by-letter keywords and the tokenizer
; ZX Spectrum 48K ROM replacement routine
; ROM address range(s): $38F7-$39F0, $3CA0-$3CC5   (288 bytes)
; Replaces: The K mode of the keyboard decoding (keyword tables) and the keyword-from-key path of the editor
; Author: ruijtunes (github.com/ruijtunes)   License: Free to use
; The routine assembles inside the ROM source (sjasmplus) at the addresses given here.
; ---------------------------------------------------------------------------

; THE 'EDITOR' WITH LETTER-BY-LETTER ENTRY OF THE BASIC WORDS
;   There is a single mode: the keywords are typed as letters, in any case
;   (print, PRINT, Print), and the editor is the original one.  When ENTER is
;   pressed - and only for a program line or a direct command, never for INPUT -
;   the words of the line are replaced by their tokens, once, before the syntax
;   check.  VAL and VAL$ do the same with their string.  The words are looked up in
;   the token table of the ROM at $0095, so there is no table of its own.
;
;   A word is turned into a token when
;     - it starts where a word can start: not inside a string, not after REM,
;       not in a number (digits, '.', exponent) and not inside an identifier;
;     - all its letters are there, in either case (XOR (HL) / AND $DF);  a space
;       in the table word ("GO TO", "OPEN #") is optional in the text;
;     - it is not followed by a letter, '_' or '$'  (printer, print_out, print$ are
;       not PRINT; print1, print: are).  Words that end in '$', '=', '>' or '#'
;       need no such test.  FN and DEF FN may be followed by the one-letter name of
;       the function (FNa(3), FNa$(3)), but not by a longer name (FNORD is a variable).
;   If a word fails the test the search goes on with the next word of the table
;   ("IN" is skipped for INK and INPUT, "AT" for ATN) and, if no word fits, the whole
;   identifier is skipped.
NEWEDITOR:
label_3901:
	call	SETLMODE			; L mode; leaves HL = FLAGS
	dec	l			; HL = ERR_NR
	ld	(hl), $FF		; 'OK'
	call	label_0F2C		; the original EDITOR prepares the line
	bit	5, (iy + $37)		; FLAGX: is it INPUT?
	ret	nz			    ; yes: the line stays as it was typed
	ld	hl, ($5C59)		; E_LINE
	ld	b, 1			; B = 1: delete the spaces around a word that becomes a token
					; and on to TOKENIZE
; THE 'TOKENIZE' ROUTINE
;   Enter with HL pointing to the text, which ends with a carriage return, and
;   B = 1 to have the spaces around a new token deleted (all those before it, and one
;   after it when the word ends in a letter, because LIST adds its own), B = 0 not to.
TOKENIZE:
TK_LOOP:
	ld	a, (hl)
	cp	$0D
	ret	z			; end of the text
	cp	$22			; a quote: skip the string
	jr	z, TK_STR
	cp	$0E			; an invisible number: skip the marker and its 5 bytes
	jr	z, TK_MARK
	cp	$EA			; REM: the rest of the line is a comment
	ret	z
	cp	'<'
	jr	z, TK_WORD		; <=  <>
	cp	'>'
	jr	z, TK_WORD
	cp	'0'
	jr	c, TK_STEP
	cp	':'
	jr	c, TK_NUM		; a digit
	call	TK_LET			; a letter?
	jr	c, TK_WORD
TK_STEP:
	inc	hl
	jr	TK_LOOP
; ---- a string: up to the closing quote
TK_STR:
	inc	hl
	ld	a, (hl)
	cp	$0D
	ret	z			; no closing quote: nothing else to do
	cp	$22
	jr	nz, TK_STR
	jr	TK_STEP
; ---- an invisible number
TK_MARK:
	ld	de, 6
	add	hl, de
	jr	TK_LOOP
; ---- a number: digits and '.'  (an exponent such as E5 is scanned as a word that matches nothing)
TK_NUM:
	ld	a, (hl)
	cp	'.'
	jr	z, TK_NUM1
	sub	'0'
	cp	10
	jr	nc, TK_LOOP
TK_NUM1:
	inc	hl
	jr	TK_NUM
; ---- a possible word
TK_WORD:
	push	hl			; the start of the word
	ld	de, label_0095 + 1	; first word of the table, after the '?' step-over byte
	ld	c, $A5			; its token (RND)
TK_ENT:
	pop	hl
	push	hl			; HL = start of the word
	ld	a, (de)
	xor	(hl)
	and	$DF			; same first letter, whatever the case?
	jr	nz, TK_SKIP
TK_CMP:
	ld	a, (de)
	and	$7F
	cp	' '
	jr	nz, TK_CH
	ld	a, (hl)			; a space in the table word is optional in the text
	cp	' '
	jr	nz, TK_NSP
	inc	hl
TK_NSP:
	inc	de
	jr	TK_CMP
TK_CH:
	xor	(hl)
	and	$DF
	jr	nz, TK_SKIP
	inc	hl
	ld	a, (de)
	inc	de
	rla				; carry = that was the last character of the word
	jr	nc, TK_CMP
;   the whole word is there.  HL -> next character of the text, DE -> next word of the table
	dec	de
	ld	a, (de)
	inc	de
	and	$7F			; last character of the word
	cp	'$'
	jr	z, TK_OK		; INKEY$ SCREEN$ VAL$ STR$ CHR$
	cp	'='
	jr	z, TK_OK		; <=  >=
	cp	'>'
	jr	z, TK_OK
	cp	'#'
	jr	z, TK_OK		; OPEN #  CLOSE #
	ld	a, (hl)
	cp	'$'
	jr	z, TK_NXT		; print$
	cp	'_'
	jr	z, TK_NXT		; print_out
	call	TK_LET
	jr	nc, TK_OKL		; not a letter: the word ends here
	ld	a, c			; a letter follows: only FN and DEF FN may take the name of a function
	cp	$A8
	jr	z, TK_FN
	cp	$CE
	jr	nz, TK_NXT		; printer
TK_FN:
	inc	hl
	ld	a, (hl)			; the character after that letter
	dec	hl
	cp	'$'
	jr	z, TK_OKL		; FNa$(
	call	TK_ALNUM
	jr	c, TK_NXT		; a longer name, FNORD is a variable
;   a word: put the token in place of its first letter and close the gap
	jr	TK_OKL
;   not this word: on to the next one of the table
TK_SKIP:
	ld	a, (de)
	inc	de
	rla
	jr	nc, TK_SKIP
TK_NXT:
	inc	c			; token of the next word
	jr	nz, TK_ENT
	jp	TK_NOKW			; no word fits
;   a word: put the token in place of its first letter and close the gap
TK_OKL:
	ld	a, b			; a word that ends in a letter: LIST prints a space after it,
	and	a			; so one space typed after it is deleted
	jr	z, TK_OK
	ld	a, (hl)
	cp	' '
	jr	nz, TK_OK
	inc	hl
TK_OK:
	pop	de			; DE = start of the word
	push	bc			; the token (C) and the flag (B)
	ld	a, b
	and	a
	jr	z, TK_PUT
TK_BK:
	dec	de			; the spaces before the word go too
	ld	a, (de)
	cp	' '
	jr	z, TK_BK
	inc	de
TK_PUT:
	ld	a, c
	ld	(de), a			; the token replaces the first character
	inc	de
	push	de			; where to go on
	or	a
	sbc	hl, de			; HL = number of bytes that are left over
	ld	b, h
	ld	c, l
	ex	de, hl			; HL = first of them
	ld	a, b
	or	c
	call	nz, label_19E8		; RECLAIM-2: delete BC bytes at HL
	pop	hl
	pop	bc
	ld	a, c
	cp	$EA
	ret	z			; REM: the rest of the line is a comment
	jp	TK_LOOP


; ---- no word fits: skip the whole identifier (or the '<' / '>')
TK_NOKW:
	pop	hl			; the start of the word
	ld	a, (hl)
	call	TK_LET
	jp	nc, TK_STEP		; '<' or '>'
TK_ID:
	inc	hl
	ld	a, (hl)
	call	TK_ALNUM
	jr	c, TK_ID
	jp	TK_LOOP
; ---- carry set if A is a letter, a digit or '_'  (A is destroyed)
TK_ALNUM:
	cp	'_'
	scf
	ret	z
	cp	'0'
	jr	c, TK_NO
	cp	':'
	ret	c
; ---- carry set if A is a letter  (A is destroyed)
TK_LET:
	or	$20
	sub	'a'
	cp	26
	ret
TK_NO:
	and	a
	ret
