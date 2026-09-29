; Problem 2: Simple Command-Line Shell Emulator
; Interprets DIR, TYPE, COPY, and EXIT commands using DOS INT 21h

JUMPS
.MODEL SMALL
.STACK 100H

.DATA
    PROMPT      DB 0DH, 0AH, "SHELL> $"
    MSG_WELCOME DB "=== 8086 MASM Shell Emulator ===", 0DH, 0AH
                DB "Commands: DIR, TYPE <file>, COPY <src> <dst>, EXIT", 0DH, 0AH, "$"
    MSG_UNKNOWN DB 0DH, 0AH, "Bad command! (Use DIR, TYPE, COPY, or EXIT)$"
    MSG_EXIT    DB 0DH, 0AH, "Exiting shell... Bye!$", 0DH, 0AH
    CRLF        DB 0DH, 0AH, "$"

    ; Mock file listing for DIR command
    MSG_DIR     DB 0DH, 0AH, "Directory of C:\SHELL", 0DH, 0AH
                DB "  README.TXT    150 bytes", 0DH, 0AH
                DB "  DATA.TXT      200 bytes", 0DH, 0AH
                DB "  PROGRAM.ASM   500 bytes", 0DH, 0AH
                DB "    3 File(s)   850 bytes$"

    ; Content for TYPE command
    MSG_TYPE    DB 0DH, 0AH, "Contents of file:", 0DH, 0AH
                DB "  [Mock File Content: Hello, this is 8086 MASM Lab!]$"

    ; Output for COPY command
    MSG_COPY    DB 0DH, 0AH, "        1 file(s) copied.$"

    ; Input buffer for INT 21h AH=0Ah
    IN_BUF      DB 50, ?, 50 DUP(?)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Print welcome message
    LEA DX, MSG_WELCOME
    MOV AH, 09H
    INT 21H

SHELL_LOOP:
    ; Print prompt
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H

    ; Read user command
    LEA DX, IN_BUF
    MOV AH, 0AH
    INT 21H

    ; Check if user just pressed Enter (length is 0)
    MOV CL, IN_BUF+1
    CMP CL, 0
    JE SHELL_LOOP

    ; SI points to start of typed text
    LEA SI, IN_BUF+2

    ; -------------------------------------------------------------
    ; 1. Check for DIR (or dir)
    ; -------------------------------------------------------------
    MOV AL, [SI]
    CMP AL, 'D'
    JE CHECK_DIR
    CMP AL, 'd'
    JE CHECK_DIR
    JMP CHECK_TYPE_CMD

CHECK_DIR:
    MOV AL, [SI+1]
    CMP AL, 'I'
    JE CHECK_DIR_R
    CMP AL, 'i'
    JNE CHECK_TYPE_CMD
CHECK_DIR_R:
    MOV AL, [SI+2]
    CMP AL, 'R'
    JE DO_DIR
    CMP AL, 'r'
    JE DO_DIR
    JMP CHECK_TYPE_CMD

DO_DIR:
    LEA DX, MSG_DIR
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

    ; -------------------------------------------------------------
    ; 2. Check for TYPE (or type)
    ; -------------------------------------------------------------
CHECK_TYPE_CMD:
    MOV AL, [SI]
    CMP AL, 'T'
    JE CHECK_TYPE_Y
    CMP AL, 't'
    JNE CHECK_COPY_CMD
CHECK_TYPE_Y:
    MOV AL, [SI+1]
    CMP AL, 'Y'
    JE CHECK_TYPE_P
    CMP AL, 'y'
    JNE CHECK_COPY_CMD
CHECK_TYPE_P:
    MOV AL, [SI+2]
    CMP AL, 'P'
    JE CHECK_TYPE_E
    CMP AL, 'p'
    JNE CHECK_COPY_CMD
CHECK_TYPE_E:
    MOV AL, [SI+3]
    CMP AL, 'E'
    JE DO_TYPE
    CMP AL, 'e'
    JE DO_TYPE
    JMP CHECK_COPY_CMD

DO_TYPE:
    LEA DX, MSG_TYPE
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

    ; -------------------------------------------------------------
    ; 3. Check for COPY (or copy)
    ; -------------------------------------------------------------
CHECK_COPY_CMD:
    MOV AL, [SI]
    CMP AL, 'C'
    JE CHECK_COPY_O
    CMP AL, 'c'
    JNE CHECK_EXIT_CMD
CHECK_COPY_O:
    MOV AL, [SI+1]
    CMP AL, 'O'
    JE CHECK_COPY_P
    CMP AL, 'o'
    JNE CHECK_EXIT_CMD
CHECK_COPY_P:
    MOV AL, [SI+2]
    CMP AL, 'P'
    JE CHECK_COPY_Y
    CMP AL, 'p'
    JNE CHECK_EXIT_CMD
CHECK_COPY_Y:
    MOV AL, [SI+3]
    CMP AL, 'Y'
    JE DO_COPY
    CMP AL, 'y'
    JE DO_COPY
    JMP CHECK_EXIT_CMD

DO_COPY:
    LEA DX, MSG_COPY
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

    ; -------------------------------------------------------------
    ; 4. Check for EXIT (or exit)
    ; -------------------------------------------------------------
CHECK_EXIT_CMD:
    MOV AL, [SI]
    CMP AL, 'E'
    JE CHECK_EXIT_X
    CMP AL, 'e'
    JNE BAD_CMD
CHECK_EXIT_X:
    MOV AL, [SI+1]
    CMP AL, 'X'
    JE CHECK_EXIT_I
    CMP AL, 'x'
    JNE BAD_CMD
CHECK_EXIT_I:
    MOV AL, [SI+2]
    CMP AL, 'I'
    JE CHECK_EXIT_T
    CMP AL, 'i'
    JNE BAD_CMD
CHECK_EXIT_T:
    MOV AL, [SI+3]
    CMP AL, 'T'
    JE DO_EXIT
    CMP AL, 't'
    JE DO_EXIT
    JMP BAD_CMD

DO_EXIT:
    LEA DX, MSG_EXIT
    MOV AH, 09H
    INT 21H
    MOV AH, 4CH
    INT 21H

BAD_CMD:
    LEA DX, MSG_UNKNOWN
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

MAIN ENDP
END MAIN
