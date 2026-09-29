; Problem 2: Command-Line Shell Emulator
; Interprets DIR, TYPE, COPY, and EXIT commands
; Implements real file I/O operations using DOS INT 21h (AH=3Dh, 3Ch, 3Fh, 40h, 3Eh)

.MODEL SMALL
.STACK 100H

.DATA
    PROMPT          DB 0DH, 0AH, "SHELL> $"
    MSG_WELCOME     DB "=== 8086 MASM Shell Emulator ===", 0DH, 0AH
                    DB "Commands: DIR, TYPE <file>, COPY <src> <dst>, EXIT", 0DH, 0AH, "$"
    MSG_UNKNOWN     DB 0DH, 0AH, "Bad command! (Use DIR, TYPE, COPY, or EXIT)$"
    MSG_EXIT        DB 0DH, 0AH, "Exiting shell... Bye!$", 0DH, 0AH
    CRLF            DB 0DH, 0AH, "$"

    ; Simulated mock file directory listing
    MSG_DIR         DB 0DH, 0AH, "Directory of C:\SHELL", 0DH, 0AH
                    DB "  README.TXT     160 bytes", 0DH, 0AH
                    DB "  DATA.TXT       105 bytes", 0DH, 0AH
                    DB "  PROGRAM.ASM    180 bytes", 0DH, 0AH
                    DB "    3 File(s)    445 bytes$"

    ; Status and error messages
    MSG_COPY_OK     DB 0DH, 0AH, "        1 file(s) copied.$"
    MSG_NOT_FND     DB 0DH, 0AH, "File not found.$"
    MSG_CANT_CREATE DB 0DH, 0AH, "Error: Cannot create destination file.$"
    MSG_SYN_TYPE    DB 0DH, 0AH, "Syntax: TYPE <filename>$"
    MSG_SYN_COPY    DB 0DH, 0AH, "Syntax: COPY <source> <destination>$"
    MSG_TYPE_HDR    DB 0DH, 0AH, "--- File Content ---", 0DH, 0AH, "$"

    ; Command input buffer (DOS INT 21h AH=0Ah)
    IN_BUF          DB 80, ?, 80 DUP(?)

    ; Filename buffers (null-terminated ASCIZ strings for DOS file calls)
    FNAME1          DB 25 DUP(0)
    FNAME2          DB 25 DUP(0)

    ; File handles and I/O buffer
    FILE_H1         DW 0
    FILE_H2         DW 0
    IO_BUF          DB 64 DUP(0)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Display welcome banner
    LEA DX, MSG_WELCOME
    MOV AH, 09H
    INT 21H

SHELL_LOOP:
    ; Display prompt
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H

    ; Read user command
    LEA DX, IN_BUF
    MOV AH, 0AH
    INT 21H

    ; Check if user pressed Enter without typing
    MOV CL, IN_BUF+1
    MOV CH, 0
    CMP CX, 0
    JE SHELL_LOOP

    ; SI points to typed text
    LEA SI, IN_BUF+2
    MOV AL, [SI]

    ; -------------------------------------------------------------
    ; Central Command Dispatcher
    ; -------------------------------------------------------------
    CMP AL, 'D'
    JE CHECK_DIR
    CMP AL, 'd'
    JE CHECK_DIR

    CMP AL, 'T'
    JE CHECK_TYPE
    CMP AL, 't'
    JE CHECK_TYPE

    CMP AL, 'C'
    JE CHECK_COPY
    CMP AL, 'c'
    JE CHECK_COPY

    CMP AL, 'E'
    JE CHECK_EXIT
    CMP AL, 'e'
    JE CHECK_EXIT

    JMP BAD_CMD

CHECK_DIR:
    MOV AL, [SI+1]
    OR AL, 20H          ; Convert char to lowercase
    CMP AL, 'i'
    JNE BAD_CMD
    MOV AL, [SI+2]
    OR AL, 20H
    CMP AL, 'r'
    JNE BAD_CMD
    JMP DO_DIR

CHECK_TYPE:
    MOV AL, [SI+1]
    OR AL, 20H
    CMP AL, 'y'
    JNE BAD_CMD
    MOV AL, [SI+2]
    OR AL, 20H
    CMP AL, 'p'
    JNE BAD_CMD
    MOV AL, [SI+3]
    OR AL, 20H
    CMP AL, 'e'
    JNE BAD_CMD
    JMP DO_TYPE

CHECK_COPY:
    MOV AL, [SI+1]
    OR AL, 20H
    CMP AL, 'o'
    JNE BAD_CMD
    MOV AL, [SI+2]
    OR AL, 20H
    CMP AL, 'p'
    JNE BAD_CMD
    MOV AL, [SI+3]
    OR AL, 20H
    CMP AL, 'y'
    JNE BAD_CMD
    JMP DO_COPY

CHECK_EXIT:
    MOV AL, [SI+1]
    OR AL, 20H
    CMP AL, 'x'
    JNE BAD_CMD
    MOV AL, [SI+2]
    OR AL, 20H
    CMP AL, 'i'
    JNE BAD_CMD
    MOV AL, [SI+3]
    OR AL, 20H
    CMP AL, 't'
    JNE BAD_CMD
    JMP DO_EXIT

BAD_CMD:
    LEA DX, MSG_UNKNOWN
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

    ; -------------------------------------------------------------
    ; Action 1: DIR (Display Mock File Listing)
    ; -------------------------------------------------------------
DO_DIR:
    LEA DX, MSG_DIR
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

    ; -------------------------------------------------------------
    ; Action 2: TYPE <filename> (Real DOS File Read using INT 21h)
    ; -------------------------------------------------------------
DO_TYPE:
    ADD SI, 4           ; Skip "TYPE"
    CALL GET_ARG1

    ; Check if filename was provided
    CMP FNAME1[0], 0
    JE TYPE_SYNTAX_ERR

    ; Open file for reading via DOS INT 21h AH=3Dh
    LEA DX, FNAME1
    MOV AL, 00H         ; Read only
    MOV AH, 3DH
    INT 21H
    JC TYPE_NOT_FOUND   ; CF=1 means file open error

    MOV FILE_H1, AX     ; Save file handle

    ; Print header
    LEA DX, MSG_TYPE_HDR
    MOV AH, 09H
    INT 21H

READ_FILE_LOOP:
    MOV BX, FILE_H1
    MOV CX, 64          ; Read up to 64 bytes per chunk
    LEA DX, IO_BUF
    MOV AH, 3FH         ; DOS Read from file
    INT 21H
    JC CLOSE_TYPE_FILE
    CMP AX, 0           ; AX = 0 means End of File (EOF)
    JE CLOSE_TYPE_FILE

    ; Write chunk directly to screen using stdout (Handle 1)
    MOV CX, AX          ; Number of bytes read
    MOV BX, 1           ; 1 = stdout
    LEA DX, IO_BUF
    MOV AH, 40H         ; DOS Write to handle
    INT 21H
    JMP READ_FILE_LOOP

CLOSE_TYPE_FILE:
    MOV BX, FILE_H1
    MOV AH, 3EH         ; DOS Close file
    INT 21H

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

TYPE_NOT_FOUND:
    LEA DX, MSG_NOT_FND
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

TYPE_SYNTAX_ERR:
    LEA DX, MSG_SYN_TYPE
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

    ; -------------------------------------------------------------
    ; Action 3: COPY <source> <destination> (Real DOS Copy via INT 21h)
    ; -------------------------------------------------------------
DO_COPY:
    ADD SI, 4           ; Skip "COPY"
    CALL GET_ARG1
    CMP FNAME1[0], 0
    JE COPY_SYNTAX_ERR

    CALL GET_ARG2
    CMP FNAME2[0], 0
    JE COPY_SYNTAX_ERR

    ; 1. Open Source File (DOS INT 21h AH=3Dh)
    LEA DX, FNAME1
    MOV AL, 00H         ; Read-only
    MOV AH, 3DH
    INT 21H
    JC COPY_SRC_ERR
    MOV FILE_H1, AX     ; Source handle

    ; 2. Create Destination File (DOS INT 21h AH=3Ch)
    LEA DX, FNAME2
    MOV CX, 00H         ; Normal attribute
    MOV AH, 3CH
    INT 21H
    JC COPY_DST_ERR
    MOV FILE_H2, AX     ; Destination handle

    ; 3. Copy Loop: Read from Source and Write to Destination
COPY_STREAM_LOOP:
    MOV BX, FILE_H1
    MOV CX, 64
    LEA DX, IO_BUF
    MOV AH, 3FH         ; Read chunk from source
    INT 21H
    JC CLOSE_COPY_FILES
    CMP AX, 0           ; EOF?
    JE CLOSE_COPY_FILES

    ; Write chunk to destination
    MOV CX, AX          ; Number of bytes read
    MOV BX, FILE_H2
    LEA DX, IO_BUF
    MOV AH, 40H         ; Write to destination
    INT 21H
    JC CLOSE_COPY_FILES
    JMP COPY_STREAM_LOOP

CLOSE_COPY_FILES:
    MOV BX, FILE_H1
    MOV AH, 3EH         ; Close source
    INT 21H

    MOV BX, FILE_H2
    MOV AH, 3EH         ; Close destination
    INT 21H

    LEA DX, MSG_COPY_OK
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

COPY_SRC_ERR:
    LEA DX, MSG_NOT_FND
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

COPY_DST_ERR:
    ; Close source handle if destination creation failed
    MOV BX, FILE_H1
    MOV AH, 3EH
    INT 21H
    LEA DX, MSG_CANT_CREATE
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

COPY_SYNTAX_ERR:
    LEA DX, MSG_SYN_COPY
    MOV AH, 09H
    INT 21H
    JMP SHELL_LOOP

    ; -------------------------------------------------------------
    ; Action 4: EXIT
    ; -------------------------------------------------------------
DO_EXIT:
    LEA DX, MSG_EXIT
    MOV AH, 09H
    INT 21H
    MOV AH, 4CH
    INT 21H

MAIN ENDP

; -----------------------------------------------------------------
; Subroutine: GET_ARG1
; Extracts first argument string from [SI] into FNAME1 (null-terminated)
; -----------------------------------------------------------------
GET_ARG1 PROC
    PUSH CX
    PUSH DI

    ; Clear FNAME1 buffer
    MOV CX, 25
    LEA DI, FNAME1
CLEAR_ARG1:
    MOV BYTE PTR [DI], 0
    INC DI
    LOOP CLEAR_ARG1

    ; Skip leading spaces
SKIP_ARG1_SP:
    MOV AL, [SI]
    CMP AL, ' '
    JNE COPY_ARG1_CHARS
    INC SI
    JMP SKIP_ARG1_SP

COPY_ARG1_CHARS:
    LEA DI, FNAME1
READ_ARG1:
    MOV AL, [SI]
    CMP AL, ' '
    JE DONE_ARG1
    CMP AL, 0DH         ; Enter key
    JE DONE_ARG1
    CMP AL, 0           ; End of string
    JE DONE_ARG1
    MOV [DI], AL
    INC SI
    INC DI
    JMP READ_ARG1

DONE_ARG1:
    MOV BYTE PTR [DI], 0 ; Null terminator
    POP DI
    POP CX
    RET
GET_ARG1 ENDP

; -----------------------------------------------------------------
; Subroutine: GET_ARG2
; Extracts second argument string from [SI] into FNAME2 (null-terminated)
; -----------------------------------------------------------------
GET_ARG2 PROC
    PUSH CX
    PUSH DI

    ; Clear FNAME2 buffer
    MOV CX, 25
    LEA DI, FNAME2
CLEAR_ARG2:
    MOV BYTE PTR [DI], 0
    INC DI
    LOOP CLEAR_ARG2

    ; Skip leading spaces
SKIP_ARG2_SP:
    MOV AL, [SI]
    CMP AL, ' '
    JNE COPY_ARG2_CHARS
    INC SI
    JMP SKIP_ARG2_SP

COPY_ARG2_CHARS:
    LEA DI, FNAME2
READ_ARG2:
    MOV AL, [SI]
    CMP AL, ' '
    JE DONE_ARG2
    CMP AL, 0DH
    JE DONE_ARG2
    CMP AL, 0
    JE DONE_ARG2
    MOV [DI], AL
    INC SI
    INC DI
    JMP READ_ARG2

DONE_ARG2:
    MOV BYTE PTR [DI], 0 ; Null terminator
    POP DI
    POP CX
    RET
GET_ARG2 ENDP

END MAIN
