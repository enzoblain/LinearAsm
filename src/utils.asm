section .bss
    buffer resb 10 ; Reserve space to store the length as string (up to 10 digits)

section .text
    global printString
    global printInt
    extern _start

; --------------------- Print String Function ---------------------
; Needs to be called with rsi pointing to the string to print
printString:
    mov rdx, 0                   ; Reset length counter
    mov rbx, rsi                 ; Copy string pointer to preserve rsi

count_loop:
    cmp byte [rsi + rdx], 0      ; Check for null terminator -> end of string
    je done_counting

    inc rdx                      
    jmp count_loop

done_counting:
    mov rsi, rbx                 ; Set rsi back to his original value
    mov rax, 0x02000004          ; sys_write (macOS)
    mov rdi, 1                   ; STDOUT
    syscall                      

    ret

; --------------------- Print Integer Function ---------------------
printInt:
    push rax                      ; Save rax
    call intToString              ; Convert to string

    mov rsi, rdi                  ; Load converted string pointer
    call printString              ; Print it
    
    pop rax                       ; Restore rax

    ret

; --------------------- Integer to String Conversion ---------------------
intToString:
    lea rdi, [rel buffer + 9]     ; Point to end of buffer
    mov byte [rdi], 0             ; Null-terminate string
    dec rdi                       ; Move back

    mov rcx, 10                   ; Base 10
    test rax, rax                 ; Check if zero
    jnz convert_loop

    mov byte [rdi], '0'           ; Special case: if rax == 0
    ret

convert_loop:
    xor rdx, rdx                  ; Clear rdx
    div rcx                       ; Divide rax by 10
    add dl, '0'                   ; Convert remainder to ASCII
    mov [rdi], dl                 ; Store character
    dec rdi                       ; Move backwards

    test rax, rax                 ; Check if quotient is 0
    jnz convert_loop               ; If not, continue

    inc rdi                        ; Move pointer to start of number
    
    ret
