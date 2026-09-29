; Problem 1: Boot-level Password Verification System
; Simulates BIOS password check using INT 16h (keyboard BIOS interrupt)
; - Hidden input (no echo)
; - Hardcoded password
; - 3 retries limit before system lock

JUMPS
.MODEL SMALL
.STACK 100H

.DATA
    MSG_PROMPT  DB 0DH, 0AH, "Enter BIOS Password: $"
    MSG_OK      DB 0DH, 0AH, "Password Correct! Access Granted.$"
    MSG_WRONG   DB 0DH, 0AH, "Wrong Password! Tries left: $"
    MSG_LOCK    DB 0DH, 0AH, 0DH, 0AH, "System Locked! 3 wrong attempts.$"
    CRLF        DB 0DH, 0AH, "$"

    ; Hardcoded password and length
    PASSWORD    DB "1234"
    PASS_LEN    EQU 4

    INPUT_PASS  DB 10 DUP(?)
    TRIES       DB 3

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

LOGIN:
    ; Check if retries left
    CMP TRIES, 0
    JNE HAVE_TRIES
    JMP LOCK_SYSTEM

HAVE_TRIES:
    ; Print prompt
    LEA DX, MSG_PROMPT
    MOV AH, 09H
    INT 21H

    ; Read password character by character without echo using BIOS INT 16h
    MOV SI, 0           ; Index for input

READ_LOOP:
    MOV AH, 00H         ; BIOS read key without echo
    INT 16H             ; AL has ASCII char

    CMP AL, 0DH         ; Check if Enter key was pressed
    JE CHECK_PASS

    ; Store character into buffer
    MOV INPUT_PASS[SI], AL
    INC SI
    CMP SI, 10          ; Buffer limit
    JL READ_LOOP

CHECK_PASS:
    ; Check if length matches
    CMP SI, PASS_LEN
    JNE WRONG_PASS

    ; Compare input with hardcoded password
    MOV CX, PASS_LEN
    MOV DI, 0

CMP_LOOP:
    MOV AL, INPUT_PASS[DI]
    MOV BL, PASSWORD[DI]
    CMP AL, BL
    JNE WRONG_PASS
    INC DI
    LOOP CMP_LOOP

    ; If matched
    LEA DX, MSG_OK
    MOV AH, 09H
    INT 21H
    JMP EXIT_PRG

WRONG_PASS:
    DEC TRIES

    CMP TRIES, 0
    JE LOCK_SYSTEM

    ; Print wrong message and remaining tries
    LEA DX, MSG_WRONG
    MOV AH, 09H
    INT 21H

    MOV DL, TRIES
    ADD DL, '0'         ; Convert number to ASCII
    MOV AH, 02H
    INT 21H

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    JMP LOGIN

LOCK_SYSTEM:
    ; Lock system and halt
    LEA DX, MSG_LOCK
    MOV AH, 09H
    INT 21H

HALT_LOOP:
    HLT                 ; Halt processor
    JMP HALT_LOOP

EXIT_PRG:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
