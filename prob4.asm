; Problem 4: Sort an Array of N Elements
; Takes N from user, reads N elements, and sorts them using Bubble Sort

JUMPS
.MODEL SMALL
.STACK 100H

.DATA
    MSG_N       DB 0DH, 0AH, "Enter array size N: $"
    MSG_ELEM    DB "Enter element: $"
    MSG_SORTED  DB 0DH, 0AH, "Sorted Array: $"
    SPACE       DB " $"
    CRLF        DB 0DH, 0AH, "$"

    N           DW ?
    ARR         DW 20 DUP(?)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Input size N
    LEA DX, MSG_N
    MOV AH, 09H
    INT 21H
    CALL READ_NUM
    MOV N, AX

    ; If N == 0 or N == 1, nothing to sort
    CMP AX, 0
    JNE HAVE_ELEMENTS
    JMP EXIT_PRG

HAVE_ELEMENTS:
    ; 2. Input N elements
    MOV CX, N
    MOV SI, 0
INPUT_LOOP:
    PUSH CX
    LEA DX, MSG_ELEM
    MOV AH, 09H
    INT 21H
    CALL READ_NUM
    MOV ARR[SI], AX
    ADD SI, 2
    POP CX
    LOOP INPUT_LOOP

    ; 3. Bubble Sort (Ascending Order)
    MOV CX, N
    DEC CX              ; Outer loop runs N - 1 times
    CMP CX, 0
    JLE DISPLAY_RESULT  ; If N = 1, already sorted

OUTER_LOOP:
    PUSH CX
    MOV BX, CX          ; Inner loop count
    MOV SI, 0

INNER_LOOP:
    MOV AX, ARR[SI]
    MOV DX, ARR[SI+2]

    CMP AX, DX
    JLE NO_SWAP         ; If ARR[SI] <= ARR[SI+2], don't swap

    ; Swap elements
    MOV ARR[SI], DX
    MOV ARR[SI+2], AX

NO_SWAP:
    ADD SI, 2
    DEC BX
    JNZ INNER_LOOP

    POP CX
    LOOP OUTER_LOOP

DISPLAY_RESULT:
    ; 4. Display Sorted Array
    LEA DX, MSG_SORTED
    MOV AH, 09H
    INT 21H

    MOV CX, N
    MOV SI, 0
PRINT_LOOP:
    MOV AX, ARR[SI]
    CALL PRINT_NUM

    LEA DX, SPACE
    MOV AH, 09H
    INT 21H

    ADD SI, 2
    LOOP PRINT_LOOP

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

EXIT_PRG:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -------------------------------------------------------------
; Simple Procedure to Read an Integer from Keyboard into AX
; -------------------------------------------------------------
READ_NUM PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 0
READ_LOOP:
    MOV AH, 01H         ; Read char with echo
    INT 21H

    CMP AL, 0DH         ; Enter key
    JE DONE_READ

    SUB AL, '0'         ; ASCII to integer
    MOV AH, 0
    PUSH AX

    MOV AX, BX
    MOV CX, 10
    MUL CX              ; AX = BX * 10
    POP DX
    ADD AX, DX          ; AX = AX + digit
    MOV BX, AX
    JMP READ_LOOP

DONE_READ:
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AX, BX
    POP DX
    POP CX
    POP BX
    RET
READ_NUM ENDP

; -------------------------------------------------------------
; Simple Procedure to Print Integer in AX
; -------------------------------------------------------------
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 0
    JNE CONVERT

    ; Print '0' directly
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP PRINT_DONE

CONVERT:
    MOV CX, 0
    MOV BX, 10

DIV_LOOP:
    MOV DX, 0
    DIV BX              ; AX = AX / 10, DX = remainder
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIV_LOOP

PRINT_DIGITS:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PRINT_DIGITS

PRINT_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN
