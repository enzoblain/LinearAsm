section .text
    global intToString

intToString:                ; Need int in rax and return in rdi
    xor rdx, rdx            ; Clear rdx for division
    div rcx                 ; Divide rax by 10 (stores quotient in rax, remainder in rdx)
    add dl, '0'             ; Convert the remainder to ASCII
    mov [rdi], dl           ; Store the character in the buffer
    inc rdi                 ; Move the pointer to the next byte in buffer
    test rax, rax           ; Test if quotient is 0
    jnz intToString         ; If quotient is not zero, continue

    ret