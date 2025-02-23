; r0                - 
; r1                - zero_reg
; r2                - one_reg
; r3                - 
; r4                -
; r5                -
; r6                -
; r7                - 
; r8                - \_ paddle_position_1
; r9                - /
; r10               - \_ paddle_position_2
; r11               - /
; r12               - \_ ball_position_x
; r13               - /
; r14               - \_ ball_position_y
; r15               - /
; r16               - registrador de uso geral
; r17               - registrador de uso geral
; r18               - registrador de uso geral
; r19               - registrador de uso geral
; r20               -
; r21               -
; r22               -
; r23               -
; r24               - \_ temp. operations counter line value (handle_vga_line)
; r25               - /
; r26 (xl)/r27 (xh) - temp. counter line value (handle_vga_line)
; r28 (yl)/r29 (yh) - 
; r30 (zl)/r31 (zh) - 

; gpior2 - \_ counter line
; gpior1 - /
; gpior0 - pong game state 

; --- pong state (gpior0) ---
.equ    pong_state  = gpior0

.equ    vely0   = 0
.equ    vely1   = 1
.equ    velx0   = 2
.equ    velx1   = 3
.equ    velx2   = 4
.equ    dirx    = 5
.equ    diry    = 6
.equ    run     = 7

.equ    velxmax = (1<<velx2)|(1<<velx1)|(1<<velx0)
; ---

.def    zero_reg    =   r1
.def    one_reg     =   r2

.def    ball_position_yh    = r15
.def    ball_position_yl    = r14

.def    ball_position_xh    = r13
.def    ball_position_xl    = r12

.def    paddle_pos_2h       = r11
.def    paddle_pos_2l       = r10

.def    paddle_pos_1h       = r9
.def    paddle_pos_1l       = r8

.equ	counterl	=	gpior2          ; 
.equ	counterh	=	gpior1          ; counter line reg

.equ	buffer_size	= 40

.equ    paddle_size = 63
.equ    ball_size   = 8

.equ    paddle_displacement = 16

.equ    h_res   = 640
.equ    v_res   = 480

