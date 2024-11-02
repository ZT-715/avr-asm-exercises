.equ RS = 2
.equ E = 3
.equ PD = PORTD

.equ LIMPAR_LCD = 0b0000_0001
.equ MODO_ENTRADA = 0b0000_0111
.equ DESLIGAR_LCD =  0b0000_1000
.equ LIGAR_LCD = 0b0000_1111
.equ CONFIG_LCD = 0b0010_0000

.cseg
.org 0x00

init:
    ldi r20, high(RAMEND)
    sts SPH, r20
    ldi r20, low(RAMEND)
    sts SPL, r20

    ldi r16, 0xFF
    out DDRD, r16

nops:
    rcall LCD_init
    nop
    rcall delay_1s
    ldi r16, LIGAR_LCD
    rcall LCD_command
    rcall delay_1s
    ldi r16, 0b0000_0010
    rcall LCD_command
    rcall delay_1s
    
    rjmp nops


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
; r16 loaded with command
; TODO: check if flags E and R are correct
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
    out PORTD, r16 
    call delay_45us
    sbi PORTD, E
    call delay_45us
    cbi PORTD, E
    call delay_45us
    clr r16
    out PORTD, r16
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
