section .data
    ; Define types of print
    stringType dq 0
    intType dq 1
    floatType dq 2
    intArrayType dq 3
    floatArrayType dq 4

    ; Define strings that would be used
    backline db 0x0A, 0

    ; Define tha arrays for the linear regression
    x dq 1.0, 2.0, 3.0, 4.0, 5.0, 0x0A
    y dq -0.5, -1.5, -2.5, -3.5, -4.5, 0x0A

    ; Define the variables for the linear regression
    weight dq 0.0
    bias dq 0.0

section .bss
    saved_rsp resq 1          ; Save the stack pointer

section .text
    global _start

    ; Import functions from utils.asm
    extern print

    ; Import linear regression function
    extern linearRegression

_start:
    lea rdi, [rel x]           ; Load the address of the x array
    lea rsi, [rel y]           ; Load the address of the y array
    call linearRegression     ; Call the linear regression function

    mov [rel weight], rax        ; Save the weight
    mov [rel bias], rdx          ; Save the bias

    lea rdi, [rel weight]
    mov rsi, [rel floatType]
    call print

    lea rdi, [rel backline]
    mov rsi, [rel stringType]
    call print

    lea rdi, [rel bias]
    mov rsi, [rel floatType]
    call print

_exit:
    mov [rel saved_rsp], rsp  ; Save the stack pointer
    mov rsp, [rel saved_rsp]  ; Restore the stack pointer
    and rsp, -16              ; Align stack pointer
    mov rdi, 0                ; Exit code 0
    mov rax, 0x02000001       ; Syscall number for sys_exit (macOS)
    syscall                   ; Exit the program
