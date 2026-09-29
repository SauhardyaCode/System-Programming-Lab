; Problem 3: FCFS Disk Scheduling Algorithm
; Calculates total head movement for a given request queue

JUMPS
.MODEL SMALL
.STACK 100H

.DATA
    MSG_HEAD    DB 0DH, 0AH, "Enter Initial Head Position: $"
    MSG_N       DB 0DH, 0AH, "Enter Number of Requests (N): $"
    MSG_REQ     DB "Enter Request: $"
    MSG_SEEK    DB " -> Seek Distance = $"
    MSG_TOTAL   DB 0DH, 0AH, "Total Head Movement: $"
    CRLF        DB 0DH, 0AH, "$"

    INITIAL_HEAD DW ?
    CURRENT_HEAD DW ?
    N            DW ?
    TOTAL_SEEK   DW 0
    REQ_ARR      DW 20 DUP(?)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Input initial head position
    LEA DX, MSG_HEAD
    MOV AH, 09H
    INT 21H
    CALL READ_NUM
    MOV INITIAL_HEAD, AX
    MOV CURRENT_HEAD, AX

    ; 2. Input number of requests N
    LEA DX, MSG_N
    MOV AH, 09H
    INT 21H
    CALL READ_NUM
    MOV N, AX

    ; 3. Input request values
    MOV CX, N
    MOV SI, 0
READ_LOOP:
    PUSH CX
    LEA DX, MSG_REQ
    MOV AH, 09H
    INT 21H
    CALL READ_NUM
    MOV REQ_ARR[SI], AX
    ADD SI, 2
    POP CX
    LOOP READ_LOOP

    ; 4. Calculate FCFS Disk Scheduling
    MOV CX, N
    MOV SI, 0
    MOV TOTAL_SEEK, 0

CALC_LOOP:
    PUSH CX

    MOV AX, REQ_ARR[SI] ; AX = next cylinder
    MOV BX, CURRENT_HEAD

    ; Calculate |AX - BX|
    CMP AX, BX
    JAE NO_NEG
    ; If BX > AX
    SUB BX, AX
    MOV DX, BX          ; DX = distance
    JMP GOT_DIFF

NO_NEG:
    SUB AX, BX
    MOV DX, AX          ; DX = distance

GOT_DIFF:
    ; Add distance to TOTAL_SEEK
    ADD TOTAL_SEEK, DX

    ; Update current head to new request position
    MOV AX, REQ_ARR[SI]
    MOV CURRENT_HEAD, AX

    ADD SI, 2
    POP CX
    LOOP CALC_LOOP

    ; 5. Print Total Seek
    LEA DX, MSG_TOTAL
    MOV AH, 09H
    INT 21H

    MOV AX, TOTAL_SEEK
    CALL PRINT_NUM

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    ; Exit
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

    MOV BX, 0           ; Result
INPUT_LOOP:
    MOV AH, 01H         ; Read char with echo
    INT 21H

    CMP AL, 0DH         ; Check Enter key
    JE DONE_READ

    SUB AL, '0'         ; Convert ASCII to digit
    MOV AH, 0
    PUSH AX

    MOV AX, BX
    MOV CX, 10
    MUL CX              ; AX = BX * 10
    POP DX
    ADD AX, DX          ; AX = AX + digit
    MOV BX, AX
    JMP INPUT_LOOP

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

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN
