.def counter = r1
.cseg
.org 0x0

; Define porta D como saída
ldi r16, 0xFF
out DDRD, r16

; PORTD = LOW
clr r16
out PORTD, r16

; Incrementa D para pinb0 pressionado
loop:
    in r31, PINB
    andi r31, 1
    cpi r31, 1
    breq loop
    inc counter
    out PORTD, counter
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
    

