.def row = r21
.def column = r22
.def select = r23
.def row_change = r24


.equ RS = 2
.equ E = 3
.equ PD = PORTD

.equ LIMPAR_LCD = 0b0000_0001
.equ MODO_ENTRADA = 0b0000_0110
.equ DESLIGAR_LCD =  0b0000_1000
.equ LIGAR_LCD = 0b0000_1111
.equ CONFIG_LCD = 0b0010_1000
.equ POSICIONA_CURSOR = 0b1000_0000 ; 1AAA_AAAA
.equ CURSOR_R = 0b0001_0100
.equ CURSOR_L = 0b0001_0000
.equ RETORNA_CURSOR = 0b0000_0010

.equ LINHA_1 = 0x00
.equ LINHA_3 = 0x14
.equ LINHA_2 = 0x40
.equ LINHA_4 = 0x54

.cseg
DISPLAY_TXT: .db " Peso: 00.00 Kg",0," TARE",0," F2",0," F3",0,0,0

LCD_init:
    clr r16
    out DDRB, r16  

    ; PCI for PORTB
    ldi r16, (1 << PCIE0) 
    sts PCICR , r16

    ldi r16, (1 << PCINT0) | (1 << PCINT1) | (1 << PCINT2) 
    sts PCMSK0, r16

    ldi r16, 0xFF
    out DDRD, r16

    rcall LCD_conn
    
    rcall delay_1s

    ldi r16, LIGAR_LCD
    rcall LCD_command
    rcall delay_45ms

    ldi r16, LIMPAR_LCD
    rcall LCD_command
    rcall delay_45ms

    ldi zh, high(DISPLAY_TXT << 1)
    ldi zl, low(DISPLAY_TXT << 1)

    ldi r16, 0b0000_0111 
    out PORTB, r16

    ldi row, 0
    ldi column, 0

screen0:
    mov r16, row
    ldi r17, 0
    rcall LCD_position_cursor
    
    inc row

    lpm r16, Z
    ldi r17, 0
    cpse r16, r17 ; se fim de linha duplo
    rjmp screen0_loop
    ret

screen0_loop:
    lpm r16, Z+
    cpi r16, 0
    breq screen0
    rcall LCD_char
    
    rjmp screen0_loop

LCD_row_change:
    sbrc row_change, 0
    inc row
    sbrc row_change, 1
    dec row
    andi row, 0b0000_0011
    clr row_change
ret

LCD_select:
    clr select

;    cpi row, 0
;    breq LED1
;
;    cpi row, 1
;    breq LED2
;
;    cpi row, 2
;    breq LED3

    ret


LCD_mark:
    cpi r16, 0
    breq LED_X

    LED_V:
    ldi r16, '0'
    rjmp write_mark

    LED_X:
        ldi r16, '1'
    write_mark:
        rcall LCD_char
        ret

; r16 recives line 0-3
; r17 receives column 0-20
LCD_position_cursor:
    cpi r16, 0
    breq line_1

    cpi r16, 1
    breq line_2

    cpi r16, 2
    breq line_3

    cpi r16, 3
    breq line_4

line_1:
    ori r17, LINHA_1
    rjmp LCD_pos
line_2:
    ori r17, LINHA_2
    rjmp LCD_pos
line_3:
    ori r17, LINHA_3
    rjmp LCD_pos
line_4:
    ori r17, LINHA_4
    rjmp LCD_pos

; r17 recives position 0-80 (original LCD mapping)
LCD_pos:
    ori r17, POSICIONA_CURSOR
    mov r16, r17
    rcall LCD_command
    ret

LCD_conn:
    rcall delay_45ms
    ldi r16, 0b0011_0000
    rcall LCD_4bits

    rcall delay_5ms

    ldi r16, 0b0011_0000
    rcall LCD_4bits
    rcall delay_500us

    ldi r16, 0b0011_0000
    rcall LCD_4bits
    rcall delay_45us

    ldi r16, CONFIG_LCD
    andi r16, 0b1111_0000
    rcall LCD_4bits
    rcall delay_45us

    ldi r16, CONFIG_LCD
    rcall LCD_command
    rcall delay_45us

    ldi r16, DESLIGAR_LCD
    rcall LCD_command
    rcall delay_45us

    ldi r16, LIMPAR_LCD
    rcall delay_2ms

    ldi r16, MODO_ENTRADA
    rcall LCD_command
    rcall delay_45us
ret

; r16 receives char to be displayed
LCD_char:
    push r20
    mov r20, r16
    andi r16, 0b1111_0000
    sbi PORTD, RS
    rcall LCD_4bits
    mov r16, r20
    lsl r16
    lsl r16
    lsl r16
    lsl r16 ; change switch with 4 'lsl' by nibble 'swap'
    andi r16, 0b1111_0000
    rcall LCD_4bits
    cbi PORTD, RS
    pop r20
ret

; r16 loaded with command
LCD_command:
    push r20
    mov r20, r16
    andi r16, 0b1111_0000
    rcall LCD_4bits
    mov r16, r20
    lsl r16
    lsl r16
    lsl r16
    lsl r16
    andi r16, 0b1111_0000
    rcall LCD_4bits
    pop r20
ret

;r16 deve possu�r os 4 bits a serem anviados em 0b1111_0000
LCD_4bits:
    push r20
    in r20, PIND
    andi r20, 0b0000_1111
    or r16, r20
    out PORTD, r16 
    call delay_45us
    sbi PORTD, E
    call delay_45us
    cbi PORTD, E
    call delay_45us
    pop r20
    ret

delay_45us:
    push r20
    ldi r20, 240
    loop0:
        dec r20
        brne loop0
    pop r20
    ret

delay_500us:
    push r20
    ldi r20, 11
    loop1:
        call delay_45us
        dec r20
        brne loop1
    pop r20
    ret

delay_2ms:
    push r20
    ldi r20, 45
    loop2:
        call delay_45us
        dec r20
        brne loop2
    pop r20
    ret

delay_5ms:
    push r20
    ldi r20, 110
    loop3:
        call delay_45us
        dec r20
        brne loop3
    pop r20
    ret

delay_45ms:
    push r20
    ldi r20, 9
    loop4:
        call delay_5ms
        dec r20
        brne loop4
    pop r20
    ret

delay_1s:
    push r20
    ldi r20, 200
    loop5:
        call delay_5ms
        dec r20
        brne loop5
    pop r20
    ret

switch_isr:
    in r18, PINB         
   
 ; Check each pin
    sbrs r18, 0          
    inc select

    sbrs r18, 1          
    ldi row_change, 1

    sbrs r18, 2          
    ldi row_change, 2

    reti

