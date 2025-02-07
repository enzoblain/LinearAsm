section .data
    welcomemsg db '+--------------------------------------------------+', 0x0A, \
                  '|    LinearASM - Linear Regression in Assembly     |', 0x0A, \
                  '|                Author: Enzo Blain                |', 0x0A, \
                  '|                  Version: 0.0.1                  |', 0x0A, \
                  '+--------------------------------------------------+', 0x0A, 0

    lgth db 'Length of the array :', 0
    v db 'Value ', 0
    points db ':'
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

_start:
    ; Print the welcome message
    mov rdi, 1
    lea rsi, [rel welcomemsg]
    mov rdx, 266
    mov rax, 0x02000004
    syscall

    ; Print the message
    mov rdi, 1
    lea rsi, [rel lgth]
    mov rdx, 22
    mov rax, 0x02000004
    syscall

    ; Calculate the length of the array
    lea rsi, [rel x]
    xor rdx, rdx          ; Clear rdx to store the length of the array

find_length:
    cmp byte [rsi + rdx], 0
    je length_found
    inc rdx
    jmp find_length

length_found:
    ; Preparing the data to be converted
    mov rax, rdx            ; Move the length of the array to rax
    lea rdi, [rel buffer]
    mov rcx, 10

    mov r8, rdx             ; Store the array length in r8

    call intToString

    ; Print the result (the string length as a number)
    mov rdi, 1              ; File descriptor (1 = stdout)
    lea rsi, [rel buffer]   ; Address of the buffer containing the number string
    mov rdx, 10             ; Maximum length of the buffer to print (could be less, but let's assume up to 10 digits)
    mov rax, 0x02000004     ; Syscall number for sys_write
    syscall                 ; Make the system call

    ; Backline
    mov rdi, 1
    lea rsi, [rel backline]
    mov rdx, 1
    mov rax, 0x02000004
    syscall

    xor r9, r9
    lea rbx, [rel x]        ; Load the base address of the array x into rbx

count:
    cmp r8, r9
    je _exit

    ; Print the value message
    mov rdi, 1
    lea rsi, [rel v]
    mov rdx, 6
    mov rax, 0x02000004
    syscall

    mov rax, r9
    lea rdi, [rel buffer]

    call intToString

    mov rdi, 1
    lea rsi, [rel buffer]
    mov rdx, 10
    mov rax, 0x02000004
    syscall

    ; Print points
    mov rdi, 1
    lea rsi, [rel points]
    mov rdx, 1
    mov rax, 0x02000004
    syscall

    ; Print the value of x[r9]
    movzx rax, byte [rbx + r9] ; Load the value of x[r9] into rax
    lea rdi, [rel buffer]
    mov rcx, 10
    call intToString

    mov rdi, 1
    lea rsi, [rel buffer]
    mov rdx, 10
    mov rax, 0x02000004
    syscall

    ; Print the backline
    mov rdi, 1
    lea rsi, [rel backline]
    mov rdx, 1
    mov rax, 0x02000004
    syscall

    inc r9
    jmp count

_exit:
    mov rdi, 0                ; Exit code
    mov rax, 0x02000001       ; Syscall number for sys_exit
    syscall                   ; Exit the program