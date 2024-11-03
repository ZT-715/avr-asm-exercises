.cseg
.org 0x34

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

init:
    ldi r20, high(RAMEND)
    sts SPH, r20
    ldi r20, low(RAMEND)
    sts SPL, r20

    ldi r16, 0xFF
    out DDRD, r16

    rcall LCD_init
    
    rcall delay_1s

    ldi r16, LIGAR_LCD
    rcall LCD_command
    rcall delay_1s

    ldi r16, LIMPAR_LCD
    rcall LCD_command
    rcall delay_1s

    ldi r16, RETORNA_CURSOR
    rcall LCD_command
    rcall delay_1s

main_loop:
    ldi r16, LINHA_1
    rcall LCD_position
    rcall delay_1s

    ldi r16, 0b0011_0001
    rcall LCD_char
    rcall delay_1s

    ldi r16, LINHA_2
    rcall LCD_position
    rcall delay_1s

    ldi r16, 0b0011_0010
    rcall LCD_char
    rcall delay_1s

    ldi r16, LINHA_3
    rcall LCD_position
    rcall delay_1s

    ldi r16, 0b0011_0011
    rcall LCD_char
    rcall delay_1s

    ldi r16, LINHA_4
    rcall LCD_position
    rcall delay_1s

    ldi r16, 0b0011_0100
    rcall LCD_char
    rcall delay_1s

rjmp main_loop

    

; r16 recives position 0-80
LCD_position:
    ori r16, POSICIONA_CURSOR
    rcall LCD_command
    ret

LCD_init:
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
    lsl r16
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

;r16 deve possuír os 4 bits a serem anviados em 0b1111_0000
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
