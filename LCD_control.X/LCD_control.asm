.cseg
.org 0x34

.equ RS = 2
.equ E = 3
.equ PD = PORTD

.equ LIMPAR_LCD = 0b0000_0001
.equ MODO_ENTRADA = 0b0000_0111
.equ DESLIGAR_LCD = 0b0000_1000
.equ LIGAR_LCD = 0b0000_1111
.equ CONFIG_LCD = 0b0010_0100

init:
    ldi r16, 0xFF
    out DDRD, r16
    rcall LCD_init
nops:
    nop
rjmp nops

LCD_init:
    ldi r16, 0b0011_0000
    rcall LCD_H
    rcall delay_5ms
    rcall LCD_H
    rcall delay_500us
    rcall LCD_H
    rcall delay_45us
    ldi r16, CONFIG_LCD
    rcall LCD_H
    rcall delay_45us
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

; r16 loaded with command
; TODO: check if flags E and R are correct
LCD_command:
    push r20
    mov r20, r16
    andi r16, 0b1111_0000
    rcall LCD_H
    mov r16, r20
    lsl r16
    lsl r16
    lsl r16
    lsl r16
    rcall LCD_L
ret

;r16 deve possuír os 4 bits a serem anviados em 0b1111_0000
LCD_L:
    out PORTD, r16
    call delay_45us
    sbi PORTD, E
    call delay_45us
    cbi PORTD, E
    call delay_45us
    ret

;r16 deve possuír os 4 bits a serem anviados em 0b1111_0000
LCD_H:
    out PORTD, r16 
    call delay_45us
    sbi PORTD, E
    call delay_45us
    cbi PORTD, E
    call delay_45us
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
    ldi r20, 12
    loop1:
        dec r20
        call delay_45us
        brne loop1
    pop r20
    ret

delay_2ms:
    push r20
    ldi r20, 45
    loop2:
        dec r20
        call delay_45us
        brne loop2
    pop r20
    ret

delay_5ms:
    push r20
    ldi r20, 110
    loop3:
        dec r20
        call delay_45us
        brne loop3
    pop r20
    ret
