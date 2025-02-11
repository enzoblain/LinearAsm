; Constants
%define STDIN 0
%define STDOUT 1
%define STDERR 2

%define SYS_EXIT 0x02000001
%define SYS_WRITE 0x02000004

section .data
    ; Define types of print
    utils_stringType dq 0
    utils_intType dq 1
    utils_floatType dq 2
    utils_intArrayType dq 3
    utils_floatArrayType dq 4
    ; Define strings that would be used
    utils_backline db 0x0A, 0
    utils_negative_sign db '-', 0
    utils_point db '.', 0
    utils_space db ' ', 0
    utils_string_zero db '0', 0

    ; Define numbers that would be used
    utils_float_minus_one dq -1.0
    utils_float_one dq 1.0
    utils_float_ten dq 10.0
    utils_float_zero dq 0.0

    ; Define the coefficient for the decimal part
    utils_decimalpart dq 2                        ; Number of decimal part wanted

section .bss
    buffer resb 20                                ; Buffer for integer to string conversion

section .text
    ; Export functions
    global print
    global printInt
    global printString
    global printFloat
    global printIntArray
    global printFloatArray

; --------------------- Print Function ---------------------
; Needs to be called with rdi pointing to the string to print
; and rsi pointing to the type of the print
print:
    cmp rsi, [rel utils_stringType]               ; Check if string
    je printString                                ; If string, print string

    cmp rsi, [rel utils_intType]                  ; Check if integer
    je printInt                                   ; If integer, print integer

    cmp rsi, [rel utils_floatType]                ; Check if float
    je printFloat                                 ; If float, print float

    cmp rsi, [rel utils_intArrayType]             ; Check if integer array
    je printIntArray                              ; If integer array, print integer array

    cmp rsi, [rel utils_floatArrayType]           ; Check if float array
    je printFloatArray                            ; If float array, print float array

    ret

; --------------------- Print String Function ---------------------
; Needs to be called with rdi pointing to the string to print
printString:
    xor rcx, rcx                                  ; Reset counter
    mov rbx, rdi                                  ; Copy string pointer to preserve rsi

count_loop:
    cmp byte [rdi + rcx], 0                       ; Check for null terminator -> end of string
    je done_counting                              ; If null terminator, done counting

    inc rcx                                       ; Increment counter
    jmp count_loop                                ; Loop

done_counting:
    mov rdx, rcx                                  ; Set rdx to the length of the string
    mov rsi, rbx                                  ; Set rsi to the string pointer
    mov rax, SYS_WRITE                            ; sys_write (macOS)
    mov rdi, STDOUT                               ; STDOUT
    syscall                                       ; Call syscall

    ret

; --------------------- Print Integer Function ---------------------
; Needs to be called with rdi pointing to the integer to print
printInt:
    mov rdi, [rdi]                                ; Load integer
    cmp rdi, 0                                    ; Check if zero
    je printZero                                  ; If zero, print zero

    call negative_case_integer                    ; Check sign of integer 

    mov rdi, rax                                  ; Load integer to print
    call intToString                              ; Convert to string

    mov rdi, rax                                  ; Load address of string
    call printString                              ; Print it

    ret

printZero:
    lea rdi, [rel utils_string_zero]              ; Load zero
    call printString                              ; Print it

    ret
; --------------------- Print Float Function ---------------------
; Needs to be called with rdi pointing to the float to print
printFloat:
    ; Define decimal part wanted 
    movsd xmm0, [rel utils_float_one]             ; Load 10 to xmm0     
    mov rcx, [rel utils_decimalpart]              ; Load decimal part wanted to rsi

    decimal_coeff_loop:                           ; Get 10 power of decimal part wanted
        mulsd xmm0, [rel utils_float_ten]         ; Multiply xmm0 by 10
        dec rcx                                   ; Decrement rcx
        cmp rcx, 0                                ; Check if no more ten power to get
        jnz decimal_coeff_loop                    ; If not, loop
   
    movsd xmm1, qword [rdi]                       ; Load float to xmm1
    cvtsd2si rax, xmm1                            ; Convert float to int (trunc)
    cvtsi2sd xmm2, rax                            ; Store the entire part 

    mov rdi, rax                                  ; Load the entire part to rdi
    call negative_case_float                      ; Check sign of float

    ucomisd xmm1, xmm2                            ; Compare the float with the entire part
    jae good_trunc                                ; If the float is greater or equal to the entire part, the trunc is correct 

    addsd xmm2, qword [rel utils_float_minus_one] ; If the float is less than the entire part, decrement the entire part because the trunc is wrong
    ; Sometimes the trunc is wrong because of the floating point representation

good_trunc:
    subsd xmm1, xmm2                              ; Get the decimal part
    mulsd xmm1, xmm0                              ; Multiply the decimal part by 10^decimalpart to get the wanted decimal part

    cvttsd2si rax, xmm2                           ; Convert the entire part to int to print it
    sub rsp, 8                                    ; Allocate space for the entire part
    mov [rsp], rax                                ; Save the entire part
    lea rdi, [rsp]                                ; Load the address of the entire part
    call printInt                                 ; Print the entire part
    add rsp, 8                                    ; Free the space for the entire part

    lea rdi, [rel utils_point]                    ; Load the point
    call printString                              ; Print the point

    divsd xmm0, [rel utils_float_ten]             ; Divide the decimal part by 10 to get the next decimal part

    leading_zero_loop:
        ucomisd xmm1, xmm0                        ; Compare the decimal part with the decimal part wanted
        ja done_leading_zero                      ; If the decimal part is greater than the decimal part wanted, no leading zero
                                                  ; Else, print a leading zero
        lea rdi, [rel utils_string_zero]          ; Load the zero
        call printString                          ; Print the zero

        divsd xmm0, [rel utils_float_ten]         ; Divide the decimal part by 10 to get the next decimal part

    done_leading_zero:
        cvttsd2si rax, xmm1                       ; Convert the decimal part to int to print it
        sub rsp, 8                                ; Allocate space for the decimal part
        mov [rsp], rax                            ; Save the decimal part
        lea rdi, [rsp]                            ; Load the address of the decimal part
        call printInt                             ; Print the decimal part
        add rsp, 8                                ; Free the space for the decimal part

        ret

    ret

; --------------------- Check sign of integer ---------------------
; Need to be called with rdi containing the integer to check
negative_case_integer:
    cmp rdi, 0                                    ; Check if negative
    jge positive_case                             ; If not, jump to positive case

    neg rdi                                       ; Make the integer positive
    push rdi                                      ; Save the positive integer

    lea rdi, [rel utils_negative_sign]            ; Load negative sign string
    call printString                              ; Print it

    pop rdi                                       ; Restore rax

positive_case:
    mov rax, rdi                                  ; Return the positive integer

    ret

; --------------------- Check sign of float ---------------------
; Need to be called with rdi containing the entire part of the float
negative_case_float:
    cmp rdi, 0                                    ; Check if negative
    jge positive_case_float                       ; If not, jump to positive case

    lea rdi, [rel utils_negative_sign]            ; Load negative sign string
    call printString                              ; Print it

    mulsd xmm1, qword [rel utils_float_minus_one] ; If the float is negative, make the number positive
    mulsd xmm2, qword [rel utils_float_minus_one] ; If the float is negative, make the entire part positive

positive_case_float:
    ret 

; --------------------- Integer to String Conversion ---------------------
; Needs to be called with rax containing the integer to convert
intToString:
    mov rax, rdi                                  ; Load integer to convert
    lea rdi, [rel buffer + 9]                     ; Point to end of buffer
    mov byte [rdi], 0                             ; Null-terminate string
    dec rdi                                       ; Move back

    continue_conversion:
        mov rcx, 10                               ; Base 10
        test rax, rax                             ; Check if zero
        jnz convert_loop

        mov byte [rdi], '0'                       ; Special case: if rax == 0
        
        ret

convert_loop:
    xor rdx, rdx                                  ; Clear rdx

    div rcx                                       ; Divide rax by 10
    add dl, '0'                                   ; Convert remainder to ASCII
    mov [rdi], dl                                 ; Store character
    dec rdi                                       ; Move backwards

    test rax, rax                                 ; Check if quotient is 0
    jnz convert_loop                              ; If not, continue

    inc rdi                                       ; Move pointer to start of number

    mov rax, rdi                                  ; Return pointer to start of number
    
    ret  


; --------------------- Print Integer Array Function ---------------------
; Needs to be called with rdi pointing to the array to print
printIntArray:
    xor rcx, rcx                                  ; Reset counter   

    loopIntArray:
        lea rax, [rdi + rcx * 8]                  ; Load array pointer to the rdx element

        cmp qword [rax], 0x0A                     ; Check for backline
        je endLoopIntArray                        ; If backline, end of array (convention)
        
        push rcx                                  ; Save counter
        push rdi                                  ; Save array pointer

        lea rdi, [rax]                            ; Load adress of element
        call printInt                             ; Print element

        lea rdi, [rel utils_space]                ; Load space
        call printString                          ; Print space

        pop rdi                                   ; Restore array pointer
        pop rcx                                   ; Restore counter
        inc rcx                                   ; Increment counter

        jmp loopIntArray                          ; Loop

    endLoopIntArray: 

        ret

; --------------------- Print Float Array Function ---------------------
; Needs to be called with rdi pointing to the array to print
printFloatArray:
    xor rcx, rcx                                  ; Reset counter   

    loopFloatArray:
        lea rax, [rdi + rcx * 8]                  ; Load array pointer to the rdx element

        cmp qword [rax], 0x0A                     ; Check for backline -> end of array (convention)
        je endloopFloatArray

        push rcx                                  ; Save counter
        push rdi                                  ; Save array pointer

        lea rdi, [rax]                            ; Load adress of element
        call printFloat                           ; Print element

        lea rdi, [rel utils_space]                ; Load space
        call printString                          ; Print space

        pop rdi                                   ; Restore array pointer
        pop rcx                                   ; Restore counter
        inc rcx                                   ; Increment counter

        jmp loopFloatArray                        ; Loop

    endloopFloatArray: 

        ret