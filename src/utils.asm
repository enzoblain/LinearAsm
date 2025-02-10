section .data
    negative_sign db '-', 0
    utils_backline db 0x0A, 0

section .bss
    buffer resb 20

section .text
    global printInt
    global printString
    global trunc

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
; Needs to be called with rax containing the address of the integer to print
printInt:
    cmp rax, 0                    ; Check if negative
    jl negative_case

continueInt:
    push rax                      ; Save rax
    call intToString              ; Convert to string

    mov rsi, rdi                  ; Load converted string pointer
    call printString              ; Print it
    
    pop rax                       ; Restore rax

    lea rsi, [rel utils_backline]
    call printString

    ret

negative_case:
    neg rax                        ; Make rax positive
    push rax                       ; Save rax

    lea rsi, [rel negative_sign]
    call printString

    pop rax                        ; Restore rax

    jmp continueInt

; --------------------- Integer to String Conversion ---------------------
; Needs to be called with rax containing the address of the integer to convert
intToString:
    lea rdi, [rel buffer + 9]      ; Point to end of buffer
    mov byte [rdi], 0              ; Null-terminate string
    dec rdi                        ; Move back


    continue_conversion:
        mov rcx, 10                ; Base 10
        test rax, rax              ; Check if zero
        jnz convert_loop

        mov byte [rdi], '0'        ; Special case: if rax == 0
        
        ret

convert_loop:
    xor rdx, rdx                   ; Clear rdx

    div rcx                        ; Divide rax by 10
    add dl, '0'                    ; Convert remainder to ASCII
    mov [rdi], dl                  ; Store character
    dec rdi                        ; Move backwards

    test rax, rax                  ; Check if quotient is 0
    jnz convert_loop               ; If not, continue

    inc rdi                        ; Move pointer to start of number
    
    ret

; --------------------- Truncate Double to Integer ---------------------
; Needs to be called with rax containing the address of the double to truncate
trunc:
    movsd xmm1, qword [rax]         ; Load float into xmm1
    cvtsd2si rdi, xmm1              ; Trunc float to int

    ret