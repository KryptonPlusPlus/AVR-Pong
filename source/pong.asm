    sbic    pong_state, run
    rjmp    run_pong

    ldi     r16,    low (v_res / 2)
    ldi     r17,    high(v_res / 2)
    mov     ball_position_yh,   r17     ; 
    mov     ball_position_yl,   r16     ; reset position y

    ldi     r16,    low (h_res / 4 + 8 + ball_size / 2 - 1)
    ldi     r17,    high(h_res / 4 + 8 + ball_size / 2 - 1)
    mov     ball_position_xh,   r17     ; 
    mov     ball_position_xl,   r16     ; reset position x

    ; reset pong_state
    ldi      r16,   (1<<velx0)|(1<<vely0)
    out     pong_state, r16

    sbis    pinb,   pb2                 ; if press button
    sbi     pong_state, run
    
run_pong:
    ; --- init adc ---
    ; 25c
    lds     r16,    adcsra
    ori     r16,    1<<adsc
    sts     adcsra, r16
    ; --- 

    ; --- move ball x ---
	movw	r25:r24,	ball_position_xh:ball_position_xl			; 1c
    
    subi    r24,    low (paddle_displacement)
    sbci    r25,    high(paddle_displacement)
    brge    x_1

    sbi     pong_state, dirx
x_1:
	movw	r25:r24,	ball_position_xh:ball_position_xl			; 1c

    subi    r24,    low ((h_res / 2) - (ball_size / 2))
    sbci    r25,    high((h_res / 2) - (ball_size / 2))
    brlt    x_2

    ; so precisa fazer o teste de colisao para o paddle da esquerda
    ; o outro segue a bola, logo sempre vai acertar

    movw	r25:r24,    ball_position_yh:ball_position_yl

    cbi     pong_state, run   

    sub     r24,    paddle_pos_2l
    sbc     r25,    paddle_pos_2h
    brlt    end_collision_paddle

    subi    r24,    low (paddle_size - ball_size / 2)
    sbci    r25,    high(paddle_size - ball_size / 2)
    brge    end_collision_paddle

    ; acertou o paddle, continua o jogo
    sbi     pong_state, run
    ; aumenta a velocidade x sempre q acerta o paddle
    in      r16,    pong_state
   
    andi    r16,    velxmax             ; testa se atingiu a velocidade máxima
    subi    r16,    velxmax             ; 0bxxx111xx
    breq    end_collision_paddle
    
    in      r16,    pong_state
    subi    r16,    -(1<<velx0)         ; adiciona 1 na velocidade x
    out     pong_state, r16

end_collision_paddle:

    cbi     pong_state, dirx
x_2:
    in      r16,    pong_state          ;
    lsr     r16                         ;
    lsr     r16                         ;
    andi    r16,    0b111               ; get x velocity

    sbic    pong_state, dirx
    ldi     r17,    0x00 

    sbis    pong_state, dirx
    neg     r16
    sbis    pong_state, dirx
    ldi     r17,    0xff

    add     ball_position_xl,    r16
    adc     ball_position_xh,    r17 
    ; ---

    ; --- move ball y --- 
    movw	r25:r24,    ball_position_yh:ball_position_yl  			; 1c

    subi    r24,    0                   ;
    sbci    r25,    0                   ;
    brge    y_1                         ; teste vertical em 0

    sbi     pong_state, diry
y_1:
    movw	r25:r24,    ball_position_yh:ball_position_yl  			; 1c

    subi    r24,    low (v_res - ball_size) ;
    sbci    r25,    high(v_res - ball_size) ;
    brlt    y_2                             ; teste vertical em v_res - ball_size

    cbi     pong_state, diry    
y_2:
    in      r16,    pong_state              ;
    andi    r16,    (1<<vely1)|(1<<vely0)   ; get y velocity

    sbic    pong_state, diry
    ldi     r17,    0x00 

    sbis    pong_state, diry            ;
    neg     r16                         ;
    sbis    pong_state, diry            ;
    ldi     r17,    0xff                ; complemento de dois

    add     ball_position_yl,   r16
    adc     ball_position_yh,   r17 
    ; ---

    ; --- move paddle_1 --- 
    movw	r25:r24,	ball_position_yh:ball_position_yl			; 1c
    sbiw    r25:r24,    paddle_size / 2 - ball_size / 2

    movw	r27:r26,	ball_position_yh:ball_position_yl			; 1c
    
    sbiw    r27:r26,    paddle_size / 2
    brge    paddle_top_test_1

    ldi     r25,        0
    ldi     r24,        0

paddle_top_test_1:
    subi    r26,        low (v_res - paddle_size)   ; ja foi feita uma sub de
    sbci    r27,        high(v_res - paddle_size)   ; paddle_size / 2
    brlt    paddle_lower_test_1

    ldi     r24,        low (v_res - paddle_size)
    ldi     r25,        high(v_res - paddle_size)

paddle_lower_test_1:
    movw    paddle_pos_1h:paddle_pos_1l,    r25:r24
    ; ---   

    ; --- move paddle_2 ---
    ; paddle range        [0 : vres - paddle_size - 1] = [0 : 416]
    ; potentiometer range [0 : 511 * 0.8125] = [0 : 415.18]
    ; 0.8125 = 1 - 1/8 - 1/16
    lds     r24,    adcl
    lds     r25,    adch

    lsr     r25                         ; 
    ror     r24                         ; adc / 2 -> [0 : 511]
    
    movw    r27:r26,    r25:r24

    lsr     r27                         ; 
    ror     r26                         ; 
    lsr     r26                         ; 
    lsr     r26                         ; r27:r26 / 8

    sub     r24,    r26                 ;
    sbc     r25,    r27                 ; 1 - 1/8

    lsr     r26                         ; r27:r26 / 16

    sub     r24,    r26                 ;
    sbc     r25,    r27                 ; 1 - 1/8 - 1/16

    movw	paddle_pos_2h:paddle_pos_2l,	r25:r24
    ; ---