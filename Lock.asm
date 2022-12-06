.include "m328Pdef.inc"

.equ MAX_TRIES = 3
.equ CORRECT_PASS = 0b00001001
.equ LED7 = 0b10000000
.equ CHECK_PASS_BTN_PIN = 4

.def tmp = r16
.def input = r17
.def tries = r18

.macro CheckButton
                sbic PIND, @0
                rjmp Quit
WaitRelease:    sbis PIND, @0
                rjmp WaitRelease
                clr tmp
                bld tmp, @0
                eor input, tmp
Quit:           nop
.endmacro

.org 0x00
                jmp Reset

Reset:          ldi tmp, low(RAMEND)        ; Stack Pointer
                out SPL, tmp
                ldi tmp, high(RAMEND)
                out SPH, tmp
            
                ser tmp                     ; PORTB out
                out DDRB, tmp
            
                clr tmp                     ; PORTD in
                out DDRD, tmp
                ser tmp
                out PORTD, tmp

                set

PollingButtons: CheckButton 0
                CheckButton 1
                CheckButton 2
                CheckButton 3

                sbic PIND, CHECK_PASS_BTN_PIN
                rjmp PollingButtons
WaitRelease1:   sbis PIND, CHECK_PASS_BTN_PIN
                rjmp WaitRelease1
            
CheckPass:      ldi tmp, CORRECT_PASS
                eor tmp, input
                in tmp, SREG                ; Check if pass is correct
                sbrs tmp, 1
                rjmp IncTries

ShowLed:        ldi tmp, LED7
                out PORTB, tmp
                rjmp ShowLed

IncTries:       inc tries
                ldi tmp, MAX_TRIES          ; Check if tries exceeded
                eor tmp, tries
                breq Lock
                rjmp PollingButtons

Lock:           ldi tmp, 0xff
                out PORTB, tmp
                rjmp Lock
