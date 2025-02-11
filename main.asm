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

    x dq 1, 2, 3, 4, 5, 0x0A
    y dq 5, 4, 3, 2, 1, 0x0A
    predicted TIMES 6 db 0

    max_iterations dq -1000
    learning_rate dq 0.01
    convergence_threshold dq 0.00001

section .text
    global _start
    extern printInt
    extern printString
    extern printFloat
    extern printIntegerArray

_start:
    ; Print welcome message
    lea rsi, [rel welcomemsg]
    call printString

    lea rdi, [rel x]
    call printIntegerArray

_exit:
    mov rdi, 0                ; Exit code 0
    mov rax, 0x02000001       ; Syscall number for sys_exit (macOS)
    syscall                   ; Exit the program
