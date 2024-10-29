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


;r16 deve possuír os 4 bits a serem anviados em 0b1111_0000
LCD_L:
    out r16, PORTD
    call delay_45us
    sbi PORTD, E
    call delay_45us
    cbi PORTD, E
    call delay_45us
    ret

;r16 deve possuír os 4 bits a serem anviados em 0b1111_0000
LCD_H:
    out r16, PORTD
    call delay_45us
    sbi PORTD, E
    call delay_45us
    cbi PORTD, E
    call delay_45us
    ret

delay_45us:
    ldi r20, 240
    loop0:
        dec r20
        brne loop0
    ret

delay_500us:
    ldi r21, 12
    loop1:
        dec r21
        call delay_50us
        brne loop1
    ret

delay_2ms:
    ldi r22, 45
    loop2:
        dec r22
        call delay_50us
        brne loop2
    ret
