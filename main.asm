section .data
    welcomemsg db '+--------------------------------------------------+', 0x0A, \
                '|    LinearASM - Linear Regression in Assembly     |', 0x0A, \
                '|                Author: Enzo Blain                |', 0x0A, \
                '|                  Version: 0.0.1                  |', 0x0A, \
                '+--------------------------------------------------+', 0x0A, 0

    lgth db 'Length of the array :', 0
    v db 'Value ', 0
    points db ':', 0
    backline db 0x0A, 0

    x dq 1.0, 2.0, 3.0, 4.0, 5.0, 0x0A
    y dq 1.0, 2.0, 3.0, 4.0, 5.0, 0x0A

    tes dq 3.65

section .text
    global _start

    ; Import functions from utils.asm
    extern printInt
    extern printString
    extern printFloat
    extern printIntArray
    extern printFloatArray

    extern linearRegression

_start:
    ; Print welcome message
    lea rsi, [rel welcomemsg]
    call printString

    lea r8, [rel x]
    lea r9, [rel y]
    call linearRegression

    lea rax, [rel r8]
    call printFloat

    lea rsi, [rel backline]
    call printString

    lea rax, [rel r9]
    call printFloat

_exit:
    mov rdi, 0                ; Exit code 0
    mov rax, 0x02000001       ; Syscall number for sys_exit (macOS)
    syscall                   ; Exit the program
