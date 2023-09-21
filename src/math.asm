SECTION "Arithmetic", ROM0

; DOES NOT SAVE wArythmeticVariable
; function calculating modulo (SHOULD be working)
; the divident goes into [wArithmeticVariable] (higher bits go first, max 2 bytes)
; the divisor goes into [wArithmeticModifier]
; the quotient will be in [wArithmeticResult] (higher bits go first, max 2 bytes)
Modulo::

    call Divide

    ; save variable for later
    ld a, [wArithmeticVariable]
    ld b, a
    ld a, [wArithmeticVariable+1]
    ld c, a

    ; move division result as a new variable
    ld a, [wArithmeticResult]
    ld [wArithmeticVariable], a
    ld a, [wArithmeticResult+1]
    ld [wArithmeticVariable+1], a

    call Multiply

    ; load multiplication result
    ld a, [wArithmeticResult]
    ld h, a
    ld a, [wArithmeticResult+1]
    ld l, a

    ; sub bc, hl
    ld a, c
    sub a, l
    ld c, a
    jp nc, Modulo.skipCarry

    dec b

.skipCarry:

    ld a, b
    sub a, h
    ld b, a

    ld a, b
    ld [wArithmeticResult], a
    ld a, c
    ld [wArithmeticResult+1], a

    ret

; saves wArythmeticVariable
; function calculating multily (SHOULD be working)
; the multiplicand goes into [wArithmeticVariable] (higher bits go first, max 2 bytes)
; the multiplier goes into [wArithmeticModifier]
; the product will be in [wArithmeticResult] (higher bits go first, max 2 bytes)
Multiply::
    ld hl, 0
    ld a, [wArithmeticVariable]
    ld d, a
    ld a, [wArithmeticVariable+1]
    ld e, a
    ld a, [wArithmeticModifier]

WhileMultiplier:
    cp a, 0
    jp z, WhileMultiplier.end

    add hl, de
    dec a
    jp WhileMultiplier
.end
    ld a, h
    ld [wArithmeticResult], a
    ld a, l
    ld [wArithmeticResult+1], a

    ret
    
; saves wArythmeticVariable
; function divides numbers (SHOULD work for any numbers)
; the divident goes into [wArithmeticVariable] (higher bits go first, max 2 bytes)
; the divisor goes into [wArithmeticModifier]
; the quotient will be in [wArithmeticResult] (higher bits go first, max 2 bytes)
; to change limit of bytes for Variable change number of reserved bytes for Variable and Result, 
; change number of repetitions near the end of divide function and clear more result positions
Divide::
    ld a, 0
    ld [wArithmeticResult], a
    ld [wArithmeticResult+1], a
    ; e counts number of passes
    ld e, 0
    ; c is a counter for the amount we currently have
    ; set c to zero
    ld c, 0
    ld d, 0

DivideAfterInit:
    ; set b to highest bit
    ld b, %10000000
    
    ; iterate over bits 
WhileBits:
    ; check if b is equal to zero
    xor a
    cp a, b
    jp z, WhileBits.end

    ; check if bit at position b is on
    ld hl, wArithmeticVariable
    add hl, de
    ld a, [hl]
    and b

    ; skip if it's not
    jp z, WhileBits.noBit

    ; add one to c if it is
    inc c

.noBit:

    ; check if c is large enough
    ; if divisor <= c
    ld a, [wArithmeticModifier]
    ; jump if a > c
    sub a, 1
    cp a, c
    jp nc, WhileBits.notBigger

    ld hl, wArithmeticResult
    add hl, de
    ld a, [hl]
    add a, b
    ld [hl], a
    
    ld a, c
    ld hl, wArithmeticModifier
    sub a, [hl]
    ld c, a
    
.notBigger:

    srl b           ; divide b by 2
    sla c           ; multiply c by 2

    jp WhileBits
.end:
    ; add one to e
    inc e

    ; if 2 > e
    ld a, 1
    cp a, e
    jp nc, DivideAfterInit
    
    ret


SECTION "ArithmeticVariables", WRAM0

wArithmeticVariable:: ds 2
wArithmeticResult:: ds 2
wArithmeticModifier:: ds 1
