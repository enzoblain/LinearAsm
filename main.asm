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

section .bss
    char resb 1    ; Reserve space to store 1 byte
    buffer resb 10 ; Reserve space to store the length as string (up to 10 digits)

section .data
    x db 1, 2, 3, 4, 5, 0
    y db 5, 4, 3, 2, 1, 0

section .text
    global _start
    extern intToString
    extern print

_start:
    ; Print the welcome message
    lea rsi, [rel welcomemsg]
    call print

    lea rsi, [rel lgth]
    call print

    ; Calculate the length of the array
    lea rsi, [rel x]
    xor rdx, rdx

find_length:
    cmp byte [rsi + rdx], 0
    je length_found
    inc rdx
    jmp find_length

length_found:
    ; Preparing the data to be converted
    mov rax, rdx
    lea rdi, [rel buffer]

    mov r8, rdx             ; Store the array length in r8

    call intToString

    lea rsi, [rel buffer]   ; Load the address of the array length (string) into rsi
    call print

    lea rsi, [rel backline]
    call print

    xor r9, r9
    lea rbx, [rel x]

count:
    cmp r8, r9
    je _exit

    lea rsi, [rel v]
    call print

    mov rax, r9
    lea rdi, [rel buffer]

    call intToString

    lea rsi, [rel buffer]   ; Load the address of the index (string) into rsi
    call print

    lea rsi, [rel points]
    call print

    movzx rax, byte [rbx + r9]
    lea rdi, [rel buffer]

    call intToString

    lea rsi, [rel buffer]   ; Load the address of the array[index] (string) into rsi
    call print


    lea rsi, [rel backline]
    call print

    inc r9
    jmp count

_exit:
    mov rdi, 0                ; Exit code
    mov rax, 0x02000001       ; Syscall number for sys_exit
    syscall                   ; Exit the program