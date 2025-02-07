section .text
    global print

print:                ; Need message at rsi and size at rdx
    mov rdi, 1

    xor rdx, rdx

find_length:
    cmp byte [rsi + rdx], 0
    je length_found
    inc rdx
    jmp find_length

length_found:
    mov rax, 0x02000004
    syscall

    ret
