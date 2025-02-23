; Clock 25.175Mhz

;
;	Video Resolution:		320 x 480 @ 60 Hz
;
; Video setup VGA 
;     Video Resolution:		VGA Signal 640 x 480 @ 60 Hz Industry standard timing
;     Colors:				1 Color (white)
; Hardware
;     ATMEL ATMEGA328P-PU
;
; Created:     27/01/2025
; Last Update: xx/xx/2025

;  
;         0    |    0
;
;              |    *
;   |                      |
;              |
;
;              |
;


.include "m328Pdef.inc"					; include defs Atmega328p
.include "def.inc"						; include program defs

.include "vars.asm"

.cseg
; --- table vectors ---
.org	0x0000
	rjmp	start

.org	0x0018							; 
	rjmp	end_vertical_back_porch		; timer1_compb

.org	0x001c							;
	rjmp	handle_vga_line				; timer0_compa
; ---

; --- init start ---
.org	0x0034
start:
	cli

	.include	"setup.asm"

	sei

; --- init loop ---
loop:
	; --- sleep ---
	;in		r16,	smcr				; smcr is 0x00 (idle sleep mode)
	out		smcr,	one_reg				;							; 1c
	sleep								;							; 1c
	out		smcr,	zero_reg			; sleep cpu
	; ---
	lds		r16,	timsk0											; 2c
	cpse	r16,	zero_reg										; 1c +1c if true
	rjmp	loop						; infinite loop				; 2c

	.include "pong.asm"
	rjmp	loop
; --- 

; --- interrupt call ---
end_vertical_back_porch:											; 2c + 4c
	; Vertical Visible area
    ; ativa a rotina de tratar e imprimir os pixels dentro 
	; da area vertical visivel,
	; é desativado dentro da propria rotina
	ldi		r16,	1<<ocie0a			; enable timer 0 			; 1c
	sts		timsk0,	r16					; compare in ocr0a			; 2c

	reti															; 4c
; ---

; ---

; --- interrupt call (handle_vga_line) ---
end_visible_area:
	sts		timsk0,	zero_reg										; 2c
	
	out 	counterh,	zero_reg									; 1c
	out 	counterl,	zero_reg									; 1c

	reti															; 4c

	; 2c + 4c
handle_vga_line:													
	; -- Horizontal Back Porch (48c - 6c max) ---
	in		r25,	counterh										; 1c
	in		r24,	counterl										; 1c

	adiw	r25:r24,	0x01										; 2c

	out 	counterh,	r25											; 1c
	out 	counterl,	r24											; 1c

	; --- load counter line ---
	; chamada do counter para depois do line_scan_loop
	; economia de ciclos
	in		r27,	counterh										; 1c
	in		r26,	counterl										; 1c
	; ---

	subi	r24,	low (481)										; 1c 
	sbci 	r25,	high(481)										; 1c \_ +1c if true
	brpl	end_visible_area										; 1c /

	ldi		zh,		high(line_buffer + 39 + 2)	; TODO:					; 1c 
	ldi		zl,		low (line_buffer + 39 + 2)	; load buffer address	; 1c

	ld		r16,	-z		; carrega o primeiro valor no reg antes	; 2c
	
	ldi 	r17,	buffer_size										; 1c

	; melhora a linha vertical inicial
	sts		udr0,	zero_reg			; first value zero			; 2c
	ldi		r18,	1<<txen0			; 							; 1c
	sts		ucsr0b,	r18					; enable transmission		; 2c

	; tempo para carregar a primeira linha vazia
	nop nop nop nop nop nop nop nop nop nop nop nop nop nop

	; ---
line_scan_loop:
	; --- pixel printing routine --- 
	; 640 / (8 * 2) = 40 bytes

	; gastando tempo para realizar o shift left do udr0
	; 8 bits -> 8 shifts (clk/2 shift) -> 16c, considerando o sts

	sts		udr0,	r16												; 2c
	
	nop																; 1c
	nop																; 1c
	nop																; 1c
	nop																; 1c
	nop																; 1c
	nop																; 1c
	nop																; 1c 
	
	st		z,		zero_reg			; clear last byte buffer	; 2c

	ld		r16,	-z												; 2c

	dec		r17														; 1c \_ +1c if true
	brne	line_scan_loop											; 1c /

	sts		ucsr0b,	zero_reg			; disable tx 				; 1c
	; ---

	.include "handle_line_buffer.asm"
; ---
