section .data
    ; Define types of print
    stringType dq 0
    intType dq 1
    floatType dq 2
    intArrayType dq 3
    floatArrayType dq 4
    
    ; Define the welcome message
    welcomemsg db '+--------------------------------------------------+', 0x0A, \
                '|    LinearASM - Linear Regression in Assembly     |', 0x0A, \
                '|                Author: Enzo Blain                |', 0x0A, \
                '|                   Version: 1.1                   |', 0x0A, \
                '+--------------------------------------------------+', 0x0A, 0

    ; Define strings that would be used
    backline db 0x0A, 0

    ; Define tha arrays for the linear regression
    x dq 1.0, 2.0, 3.0, 4.0, 5.0, 0x0A
    y dq -0.5, -1.5, -2.5, -3.5, -4.5, 0x0A

section .bss
    saved_rsp resq 1          ; Save the stack pointer

section .text
    global _start

    ; Import functions from utils.asm
    extern print

    ; Import linear regression function
    extern linearRegression

_start:
    ; Print welcome message
    lea rdi, [rel welcomemsg] ; Load the address of the welcome message
    mov rsi, [rel stringType] ; Load the type of the print
    call print                ; Call the printString function

    lea rdi, [rel x]           ; Load the address of the x array
    lea rsi, [rel y]           ; Load the address of the y array
    call linearRegression     ; Call the linear regression function

_exit:
    mov [rel saved_rsp], rsp  ; Save the stack pointer
    mov rsp, [rel saved_rsp]  ; Restore the stack pointer
    and rsp, -16              ; Align stack pointer
    mov rdi, 0                ; Exit code 0
    mov rax, 0x02000001       ; Syscall number for sys_exit (macOS)
    syscall                   ; Exit the program
