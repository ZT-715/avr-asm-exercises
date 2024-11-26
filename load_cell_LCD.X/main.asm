.cseg
.org 0x00                
    jmp init          
.org 0x06
    jmp switch_isr  ; PCI2 interrupt service routine
.org 0x01C
    jmp OCR0A_isr
    jmp OCR0B_isr
    jmp TOV0_isr
    
.org 0x02A
    ;jmp ADC_isr
.org 0x034

#include "AD_config.asm"
#include "LCD_control.asm"
#include "Switches.asm"
#include "timer.asm"

.def TAREL = r28 
.def TAREH = r29 
.def TARE_SIGN = r24 

init:
;stack_init
    ldi r20, high(RAMEND)
    out SPH, r20
    ldi r20, low(RAMEND)
    out SPL, r20

    call switch_config
    call AD_config
    call LCD_init
    call timer0_config

main:
    ldi row, 2
    ldi column, 0
    clr r15

    clr TAREH
    clr TAREL

    sei
main_loop:

    mov r16, row
    mov r17, column
    call LCD_position_cursor

    cpse switch_toggled, r15
    call LCD_switch_handle

; Weight

    cpse tc0_overflow, r15; sample time 16 KHz
    call update_weight

rjmp main_loop

update_weight:
    ldi r16, 0
    ldi r17, 6
    call LCD_position_cursor

    call AD_read
    call AD_tare
    call dubble_dabble
    call LCD_write_weight 

    clr tc0_overflow
ret

; dubble_dabble for 10 bits left justfied
; load I/O in r17 (high) and r16 (low)
dubble_dabble:
    push r20
    push r26
    push r27
    clr r26
    clr r27
    ldi r20, 10
    
dd_loop:
        lsl r16
        rol r17
        rol r26
        rol r27
   
        dec r20
        breq dd_end

        movw r19:r18, r27:r26

        dd_nb1:
            andi r18, 0x0F
            cpi r18, 5
            brlo dd_nb2
            adiw r27:r26, 3

        dd_nb2:
            mov r18,r26
            swap r18
            andi r18, 0x0F
            cpi r18, 05
            brlo dd_nb3
            adiw r27:r26, 0x30

        dd_nb3:
            andi r19, 0x0F
            cpi r19, 05
            brlo dd_nb4

            push r20
            ldi r20, 3
            add r27, r20
            pop r20

        dd_nb4:
            mov r19, r27
            swap r19
            andi r19, 0x0F
            cpi r19, 05
            brlo dd_nx
            
            push r20
            ldi r20, 0x30
            add r27, r20
            pop r20
        
        dd_nx:
        rjmp dd_loop

    dd_end:
    movw r17:r16, r27:r26
    pop r27
    pop r26
    pop r20
 ret

; Valores em r17 (high) e r16 (low)
LCD_write_weight:

    push r16
    mov r16, TARE_sign
    call LCD_char
    pop r16

    movw r19:r18, r17:r16

    swap r17
    swap r16

    andi r17, 0x0F ; 1st
    andi r19, 0x0F ; 2nd
    andi r16, 0x0F ; 3rd
    andi r18, 0x0F ; 4th 
    
    ldi r20, '0'
    add r16, r20
    add r17, r20
    add r18, r20
    add r19, r20
    
    push r16

    mov r16, r17
    call LCD_char
    mov r16, r19
    call LCD_char
    ldi r16, '.'    
    call LCD_char
    pop r16
    call LCD_char
    mov r16, r18
    call LCD_char

ret

LCD_switch_handle:
    
    in r16, pinb
    andi r16, 0b0000_0111
    cpi r16, 0b0000_0111
    brne end_sh

    sbrc switch_toggled, 0
    call tare
    sbrc switch_toggled, 1
    ldi r16, 'B'
    sbrc switch_toggled, 2
    ldi r16, 'C'
    call lcd_char
    
    clr switch_toggled
end_sh:
ret

tare:
    call AD_read
    movw TAREH:TAREL, r17:r16
ret

AD_tare:
    ldi TARE_SIGN, ' '


    cp r16, TAREL
    cpc  r17, TAREH
    brlo tare_negative

tare_positve:    
    sub r16, TAREL
    sbc r17, TAREH
    
    ret

tare_negative:
    movw r19:r18, r17:r16    
    movw r17:r16, TAREH:TAREL
    sub r16, r18
    sbc r17, r19

    ldi TARE_SIGN, '-'
ret


LCD_select:

;    cpi row, 0
;    breq LED1
;
;    cpi row, 1
;    breq LED2
;
;    cpi row, 2
;    breq LED3

    ret

