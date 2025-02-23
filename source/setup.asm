    ; --- init regs ---
    eor		zero_reg,	zero_reg 			; zero reg
    eor 	one_reg, 	one_reg 			; 
    inc		one_reg							; one reg
    ; ---

    ; --- Initializing the stack pointer ---
	ldi		r16,	high(ramend)
	out		sph,	r16
	ldi		r16,	low (ramend)
	out		spl,	r16
	; ---

    ; --- rgb and sync pins output define ---
    ldi     r16,    (1<<ddb5)|(1<<ddb1)                             ;
    out     ddrb,   r16                                             ; oc1a and led pin
    ldi     r16,    1<<pb2                                          ;
    out     portb,  r16                                             ; pull-up button
    ldi     r16,    (1<<ddd5)|(1<<ddd1)                             ;
    out     ddrd,   r16                                             ; oc0b and rgb pin
    ; ---

    ; --- Setup Scan Pixels ---
    ; use usart with a master spi mode (mspim)
    ; clock / 2

    ldi     r16,    (1<<umsel01)|(1<<umsel00)                       ; enable usart master spi (mspim)
    sts     ucsr0c, r16                                             ; msb first

    sts     ubrr0h, zero_reg
    sts     ubrr0l, zero_reg
    ; ---
    
    ; --- button paddles ---
    ldi     r16,    (1<<refs0)
    sts     admux,  r16

    ; Prescale configurado para 8
    ; F_CPU / (25 * prescale) < 200kHz
    ldi     r16,    (1<<aden)|(1<<adps1)|(1<<adps0)
    sts     adcsra, r16

    ; Desabilita as entradas digitais dos pinos analógicos
    ldi     r16,    (1<<adc5d)|(1<<adc4d)|(1<<adc3d)|(1<<adc2d)|(1<<adc1d)|(1<<adc0d)
    sts     didr0,  r16

    ; Desabilita as entradas digitais dos ain1 e ain0
    ldi     r16,    (1<<ain1d)|(1<<ain0d)
    sts     didr1,  r16
    ; ---

    ; --- Setup Horizontal Sync ---
    ; Timer 0
    ; clk / 8

    ;                        ocr0b  ocr0a
    ;      --------------------+-----+---- ...
    ; oc0a ____________________       ____ ...
    ;                          |     |
    ;                          |_____|

    ldi     r16,    (1<<com0b1)|(1<<wgm01)|(1<<wgm00)               ; 
    out     tccr0a, r16                                             ; 
    ldi     r16,    (1<<wgm02)|(1<<cs01)                            ; enable fast pwm
    out     tccr0b, r16                                             ; prescaling clk / 8

    ; 704 / 8 - 1 = 87
    ; 800 / 8 - 1 = 99
    ldi     r16,    87                                              ;
    out     ocr0b,  r16                                             ; set ocr0b with Horizontal Pulse Init
    ldi     r16,    99                                              ; set ocr0a with Horizontal Pulse End
    out     ocr0a,  r16                                             ;
    ; ---

    ; --- Setup Vertical Sync
    ; Timer 1
    ; clk / 8

    ;              ocr1b     ocr1a  icr1
    ;      ----------+---------+-----+---- ...
    ; oc1a ____________________       ____ ...
    ;                          |     |
    ;                          |_____| 

    ldi     r16,    (1<<com1a1)|(1<<wgm11)                          ; 
    sts     tccr1a, r16                                             ; 
    ldi     r16,    (1<<wgm13)|(1<<wgm12)|(1<<cs11)                 ; enable fast pwm
    sts     tccr1b, r16                                             ; prescaling clk / 8

    ; (800 * 32 / 8)  - 1 =  3199
    ; (800 * 523 / 8) - 1 = 52299
    ; (800 * 525 / 8) - 1 = 52499
    ldi     r16,    high(3199 - 2)                                  ;
    sts     ocr1bh, r16                                             ;
    ldi     r16,    low (3199 - 2)                                  ;
    sts     ocr1bl, r16                                             ;

    ldi     r16,    high(52299)
    sts     ocr1ah, r16
    ldi     r16,    low (52299)
    sts     ocr1al, r16

    ldi     r16,    high(52499)
    sts     icr1h,  r16
    ldi     r16,    low (52499)
    sts     icr1l,  r16

    ldi     r16,    (1<<ocie1b)                                     ;
    sts     timsk1,  r16                                            ; enable timer 1 compare in ocr1b
    ; ---

    ; --- clear and sync timers
    out     tcnt0,  zero_reg
    sts     tcnt1h, zero_reg
    sts     tcnt1l, zero_reg

    ldi     r16,    1<<psrsync
    out     gtccr,  r16
    ; ---

    ; --- clear line counter ---
    out		counterh,	zero_reg
	out		counterl,	zero_reg
    ; ---

    ; --- setup gpior0 ---
    ldi     r16,    0b0000_0101 ; velocity x and y = 1
    out     gpior0, r16
    ; ---
    
    eor     r0,     r0

    movw    paddle_pos_1h:paddle_pos_1l,        r1:r0
    movw    paddle_pos_2h:paddle_pos_2l,        r1:r0

    ldi     r25,    high((h_res / 4) + 10)
    ldi     r24,    low ((h_res / 4) + 10)

    movw    ball_position_xh:ball_position_xl,  r25:r24

    ldi     r25,    high(v_res / 2 - ball_size / 2)
    ldi     r24,    low (v_res / 2 - ball_size / 2)

    movw    ball_position_yh:ball_position_yl,  r25:r24

