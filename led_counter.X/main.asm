 .org 0x0000

    ldi r19, 0x01
    ldi r16, 0xFF
    out DDRD, r16
loop:
    out PORTD, r19
    rol r19 ; carry deve ser adicionado no bit oposto ao shift
    lsl r19
    call segundo
    rjmp loop
        
segundo:
    ldi r18, 100
loop1_segundo:
    ldi r17, 40
loop2_segundo:
    ldi r16, 250
loop3_segundo:
    call microsegundo
    dec r16
    brne loop3_segundo
    dec r17
    brne loop2_segundo
    dec r18 
    brne loop1_segundo
    ret
    
microsegundo: 
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop ; 8 nops
    ret ; 4 clks


