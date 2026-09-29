; Problem 5: Balanced and Properly Nested Brackets Verifier
; Verifies (), {}, and [] brackets using a simulated stack in memory
; Outputs: "Balanced" or "Non-Balanced"

.MODEL SMALL
.STACK 100H

.DATA
    PROMPT      DB "Enter bracket expression: $"
    MSG_BAL     DB 0DH, 0AH, "Balanced", 0DH, 0AH, "$"
    MSG_NOT_BAL DB 0DH, 0AH, "Non-Balanced", 0DH, 0AH, "$"

    ; Input buffer for DOS INT 21h AH=0Ah
    BUFFER      DB 60, ?, 60 DUP('$')

    ; Simulated Stack
    STACK_ARR   DB 60 DUP(0)
    TOP         DW 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Prompt user
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H

    ; 2. Read string from keyboard
    LEA DX, BUFFER
    MOV AH, 0AH
    INT 21H

    ; Check if string is empty
    MOV CL, BUFFER+1
    MOV CH, 0
    CMP CX, 0
    JNE START_PROCESS

    ; Empty string is balanced
    LEA DX, MSG_BAL
    MOV AH, 09H
    INT 21H
    JMP EXIT_PROGRAM

START_PROCESS:
    ; Point SI to first entered character
    LEA SI, BUFFER+2
    MOV TOP, 0

CHECK_LOOP:
    MOV AL, [SI]

    ; Check for opening brackets -> Push to stack
    CMP AL, '('
    JE PUSH_CHAR
    CMP AL, '{'
    JE PUSH_CHAR
    CMP AL, '['
    JE PUSH_CHAR

    ; Check for closing brackets -> Pop and verify
    CMP AL, ')'
    JE CHECK_PAREN
    CMP AL, '}'
    JE CHECK_BRACE
    CMP AL, ']'
    JE CHECK_BRACKET

    ; Ignore other non-bracket characters
    JMP NEXT_CHAR

PUSH_CHAR:
    MOV BX, TOP
    MOV STACK_ARR[BX], AL
    INC TOP
    JMP NEXT_CHAR

CHECK_PAREN:
    CMP TOP, 0
    JE UNBALANCED       ; Stack underflow: closing bracket without opening
    DEC TOP
    MOV BX, TOP
    CMP STACK_ARR[BX], '('
    JNE UNBALANCED      ; Mismatch
    JMP NEXT_CHAR

CHECK_BRACE:
    CMP TOP, 0
    JE UNBALANCED
    DEC TOP
    MOV BX, TOP
    CMP STACK_ARR[BX], '{'
    JNE UNBALANCED
    JMP NEXT_CHAR

CHECK_BRACKET:
    CMP TOP, 0
    JE UNBALANCED
    DEC TOP
    MOV BX, TOP
    CMP STACK_ARR[BX], '['
    JNE UNBALANCED
    JMP NEXT_CHAR

NEXT_CHAR:
    INC SI
    DEC CX
    JNZ CHECK_LOOP

    ; End of string: stack must be empty for balanced expression
    CMP TOP, 0
    JNE UNBALANCED

    ; If top == 0, balanced!
    LEA DX, MSG_BAL
    MOV AH, 09H
    INT 21H
    JMP EXIT_PROGRAM

UNBALANCED:
    LEA DX, MSG_NOT_BAL
    MOV AH, 09H
    INT 21H

EXIT_PROGRAM:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
