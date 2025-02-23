    ; --- Horizontal Front Porch + Sync Pulse (96c + 16c max) ---

	; ldi		zh,		high(line_buffer)	;							; (1c)
	; ldi		zl,		low(line_buffer)	; loads buffer address		; (1c)

	; Chamada do counter para r27:r26 feita antes do line_scan_loop
	; para economia de ciclos

	; --- middle line ---
	ldi		r16,	0x04 - 0x01			; 							; (1c)
	add		r16,	r26					; alinhas as linhas			; (1c)

	ldi		r17,	0b0001_1000			; 24 						; (1c)

	sbrc	r16,	0x03				; % 2^3						; (1c) +1c if true
	std		z + buffer_size/2 + 1,	r17	; TODO: +1 temp.			; (2c)
	; ---

	; --- paddle 1 ---
	movw	r25:r24,	r27:r26			; get counter line			; (1c)

	; if(counter >= paddle_pos_1 and counter <= paddle_pos_1 + paddle_size)
	sub		r24,	paddle_pos_1l									; (1c)
	sbc		r25,	paddle_pos_1h									; (1c) \_ +1c if true
	brmi	paddle_1_default										; (1c) /
	
	sbiw	r25:r24,	paddle_size									; (2c) \_ +1c if true
	brpl	paddle_1_default										; (1c) /

	ldi		r16,	0b0000_1111										; (1c)
	std		z + 1,	r16												; (2c)

paddle_1_default:
	; ---

	; --- paddle 2 ---
	movw	r25:r24,	r27:r26			; get counter line			; (1c)
	
	; if (counter >= paddle_pos_2 and counter <= paddle_pos_2 + paddle_size)
	sub		r24,	paddle_pos_2l									; (1c)
	sbc		r25,	paddle_pos_2h									; (1c) \_ +1c if true
	brmi	paddle_2_default										; (1c) /

	sbiw	r25:r24,	paddle_size									; (2c) \_ +1c if true
	brpl	paddle_2_default										; (1c) /

	ldi		r16,	0b1111_0000										; (1c)
	std		z + 40,	r16												; (2c)

paddle_2_default:
	; ---

	; --- ball ---
	; TODO: se for o ultimo a usar o valor da contagem
	;movw	r25:r24,	r27:r26										; (1c)

	; if(counter >= position_ball_y and counter <= position_ball_y + ball_size)
	sub		r26,	ball_position_yl								; (1c)
	sbc		r27,	ball_position_yh								; (1c) \_ +1c if true
	brmi	ball_default											; (1c) /

	sbiw	r27:r26,	ball_size									; (1c) \_ +1c if true
	brpl	ball_default											; (1c) /

	movw	r23:r22,	ball_position_xh:ball_position_xl			; (1c)

	mov		r16,	r22												; (1c)
	
	andi	r16,	0b0000_0111			; "resto" da divisão		; (1c)

	ldi		r17,	0b0000_0000			; 							; (1c)
	ldi		r18,	0b0000_1111			; bola caso "resto" = 0		; (1c)

	; max if r16 = 7
position_ball_loop:						
	dec		r16							; 							; (1c) \_ +1c if true
	brlt	position_ball_break_loop	; desloca a posição dos 	; (1c) /
	lsl		r18							; bits da bola				; (1c)
	rol		r17							; para diferentes			; (1c)
	rjmp 	position_ball_loop			; "restos"					; (2c)

position_ball_break_loop:
	lsr		r23							; position_ball_x_max = 	; (1c)
	ror		r22							; = 0b1_01000000			; (1c)
	lsr		r22							;							; (1c)
	lsr		r22							; position_ball_x / 8		; (1c)

	add		zl,		r22												; (1c)
	adc		zh,		zero_reg										; (1c)

	ld		r16,	z												; (2c)
	or		r16,	r18												; (1c)

	st		z,		r16												; (2c)

	ldd		r16,	z + 1											; (2c)
	or		r16,	r17												; (1c)

	std		z + 1,	r16												; (2c)

ball_default:
    ; ---

	reti															; (4c)
