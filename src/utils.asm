%define STDIN 0
%define STDOUT 1
%define STDERR 2

%define SYS_EXIT 0x02000001
%define SYS_WRITE 0x02000004

section .data
    utils_negative_sign db '-', 0
    utils_backline db 0x0A, 0
    utils_point db '.', 0
    utils_zero db '0', 0
    utils_zero_float dq 0.0
    utils_minus_one dq -1.0

    utils_coeff dq 10.0
    utils_decimalpart dq 2

section .bss
    buffer resb 20

section .text
    global printInt
    global printString
    global printFloat

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
    mov rax, SYS_WRITE           ; sys_write (macOS)
    mov rdi, STDOUT              ; STDOUT
    syscall                      

    ret

; --------------------- Print Integer Function ---------------------
; Needs to be called with rax containing the integer to print
printInt:
    call negative_case_integer            ; Check sign of integer 

    call intToString              ; Convert to string

    mov rsi, rdi                  ; Load converted string pointer
    call printString              ; Print it

    ret

; --------------------- Check sign of integer ---------------------
; Need to be called with rax containing the integer to check
negative_case_integer:
    cmp rax, 0                    ; Check if negative
    jge positive_case

    neg rax                        ; Make rax positive
    push rax                       ; Save rax

    lea rsi, [rel utils_negative_sign]
    call printString

    pop rax                        ; Restore rax

positive_case:
    ret

; --------------------- Check sign of float ---------------------
; Need to be called with xmm1 containing the float to check
negative_case_float:
    movsd xmm3, qword [rel utils_zero_float]

    ucomisd xmm1, xmm3                 ; Compare the float with 0
    ja positive_case_float

    lea rsi, [rel utils_negative_sign]
    call printString

    mulsd xmm1, qword [rel utils_minus_one]     ; Make xmm1 positive

positive_case_float:
    ret 

; --------------------- Integer to String Conversion ---------------------
; Needs to be called with rax containing the integer to convert
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

; --------------------- Print Float Function ---------------------
; Needs to be called with rax containing the adress of the float to print
printFloat:
    movsd xmm0, [rel utils_coeff]        

    mov rsi, [rel utils_decimalpart]

    decimal_coeff_loop:            ; Get 10 power of decimal part wanted
        mulsd xmm0, [rel utils_coeff]
        dec rsi
        cmp rsi, 1
        jnz decimal_coeff_loop
   
    movsd xmm1, qword [rax]        ; Load float to xmm1

    call negative_case_float        ; Check sign of float

    cvtsd2si rax, xmm1             ; Convert float to int (trunc)
    cvtsi2sd xmm2, rax             ; Store the entire part 

    subsd xmm1, xmm2               ; Get the decimal part
    mulsd xmm1, xmm0               ; Multiply the decimal part by 10^decimalpart to get the wanted decimal part

    cvtsd2si rax, xmm2             ; Convert the entire part to int to print it
    call printInt

    lea rsi, [rel utils_point]
    call printString

    divsd xmm0, [rel utils_coeff]

    leading_zero_loop:             ; Check if there is leading zero    
        ucomisd xmm1, xmm0         ; Compare the decimal part with the decimal part wanted
        jp done_leading_zero
        ja done_leading_zero       ; If the decimal part is greater than the decimal part wanted, no leading zero
                                   ; Else, print a leading zero
        lea rsi, [rel utils_zero]
        call printString

        divsd xmm0, [rel utils_coeff]   ; Divide the decimal part by 10 to get the next decimal part

    done_leading_zero:
        cvttsd2si rax, xmm1             ; Convert the decimal part to int to print it
        call printInt

    ret