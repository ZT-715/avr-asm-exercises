.org 0x0000
.cseg
    ldi r19, 0b1000_0000
    mov r1, r19
    ldi r16, 0xFF
    ldi r20, 8
    out DDRD, r16
loop:
    out PORTD, r19
    asr r19 
    dec r20
    brne delay
    eor r19, r1
    ldi r20, 8
delay:
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


