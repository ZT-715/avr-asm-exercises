.cseg
.org 0x34

.equ RS = 2
.equ E = 3
.equ PD = PORTD

.equ LIMPAR_LCD = 0b0000_0001
.equ MODO_ENTRADA = 0b0000_0111
.equ DESLIGAR_LCD = 0b0000_1000
.equ LIGAR_LCD = 0b0000_1100
.equ CONFIG_LCD = 0b0010_0100


;r16 deve possuír os 4 bits a serem anviados em 0b1111_0000
LCD_L:
    out r16, PORTD
    call delay
    sbi PORTD, E
    call delay
    cbi PORTD, E
    call delay
    return

;r16 deve possuír os 4 bits a serem anviados em 0b1111_0000
LCD_H:
    out r16, PORTD
    call delay
    sbi PORTD, E
    call delay
    cbi PORTD, E
    call delay
    ret



