section .data
    ; Define linear regression constants
    linearRegression_max_iterations dq 10000
    linearRegression_learning_rate dq 0.01

    ; Define numbers that would be used
    linearRegression_minus_one dq -1.0
    linearRegression_two dq 2.0

    ; Linear Regression Variables
    linearRegression_x dq 0.0, 0.0, 0.0, 0.0, 0.0, 0x0A
    linearRegression_y dq 0.0, 0.0, 0.0, 0.0, 0.0, 0x0A
    linearRegression_predicted dq 0.0, 0.0, 0.0, 0.0, 0.0, 0x0A
    linearRegression_weight dq 2.2
    linearRegression_derivative_weight dq 0.0
    linearRegression_bias dq 1.0
    linearRegression_derivative_bias dq 0.0
    linearRegression_loss dq 0.0

    floatArrayType dq 4

section .text
    global linearRegression
    extern print

; --------------------- Linear Regression Function ---------------------
; Needs to be called with rdi pointing to the x array and rsi pointing to the y array
; Returns the weight in rax and the bias in rdx
linearRegression:
    mov [rel linearRegression_x], rdi                       ; Save the x array
    mov [rel linearRegression_y], rsi                       ; Save the y array
    mov [rel linearRegression_predicted], rsi               ; Save the predicted array

    xor rcx, rcx                                            ; Initialize the iteration counter

    linearRegressionLoop:
        cmp rcx, qword [rel linearRegression_max_iterations] ; Check if the max iterations has been reached
        jge endLinearRegressionLoop                          ; If yes, exit the loop

        push rcx                                            ; Save the iteration counter

        call derivativeWeight
        call derivativeBias

        call updateWeight
        call updateBias

        call updatePredicted
        call calculateLoss

        pop rcx                                              ; Restore the iteration counter
        inc rcx                                              ; Increment the iteration counter

        jmp linearRegressionLoop                             ; Else, continue the loop

    endLinearRegressionLoop:
        lea rax, [rel linearRegression_weight]
        lea rdx, [rel linearRegression_bias]

        ret

; --------------------- Update Predicted Values ---------------------
updatePredicted:
    xor rcx, rcx                                              ; Initialize the iteration counter

    loopPredictionArray:
        mov rdi, [rel linearRegression_x]               ; Load predicted array pointer
        lea rax, [rdi + rcx * 8]                              ; Load array pointer
        breakpoint: 

        cmp qword [rax], 0x0A                                 ; Check for backline
        je endloopPredictionArray                             ; If backline, end of array (convention)

        movsd xmm0, qword [rax]                     ; Load x value
        movsd xmm1, qword [rel linearRegression_weight]       ; Load weight
        movsd xmm2, qword [rel linearRegression_bias]         ; Load bias

        mulsd xmm0, xmm1                                      ; x * weight
        addsd xmm0, xmm2                                      ; x * weight + bias
    
        lea rax, [rel linearRegression_predicted]             ; Load predicted array pointer
        movsd qword [rax + rcx * 8], xmm0                     ; Store predicted value

        inc rcx                                               ; Increment the iteration counter

        jmp loopPredictionArray                               ; Continue the loop

    endloopPredictionArray: 
        ret

; --------------------- Calculate Loss Function ---------------------
calculateLoss:
    xor rcx, rcx                                              ; Initialize the iteration counter

    loopLoss:
        mov rdi, [rel linearRegression_x]                     ; Load x array pointer
        lea rax, [rdi + rcx * 8]                              ; Load array pointer

        cmp qword [rax], 0x0A                                 ; Check for backline
        je endLoopLoss                                        ; If backline, end of array (convention)
        
        push rcx                                              ; Save the iteration counter                                         

        movsd xmm0, qword [rax]                               ; Load predicted value
        
        mov rdi, [rel linearRegression_y]                     ; Load y array pointer
        lea rax, [rdi + rcx * 8]                              ; Load y value pointer      

        movsd xmm1, qword [rax]                               ; Load y value

        subsd xmm0, xmm1                                      ; predicted - y
        mulsd xmm0, xmm0                                      ; (predicted - y) ^ 2

        movsd xmm3, qword [rel linearRegression_loss]         ; Load loss
        addsd xmm3, xmm0                                      ; loss += (predicted - y) ^ 2

        movsd qword [rel linearRegression_loss], xmm3         ; Store loss

        pop rcx                                               ; Restore the iteration counter
        inc rcx                                               ; Increment the iteration counter

        jmp loopLoss                                          ; Continue the loop

    endLoopLoss:
        movsd xmm0, qword [rel linearRegression_loss]         ; Load loss
        cvtsi2sd xmm1, rcx                                    ; Convert iteration counter to double
        divsd xmm0, xmm1                                      ; loss /= len(y)

        movsd qword [rel linearRegression_loss], xmm0         ; Store loss

    ret

; --------------------- Calculate Derivative Weight ---------------------
derivativeWeight:
    xor rdx, rdx

    movsd xmm0, qword [rel linearRegression_derivative_weight]
    xorpd xmm0, xmm0

    movsd qword [rel linearRegression_derivative_weight], xmm0

    derivativeWeightLoop:
        push rdx

        lea rax, [rel linearRegression_predicted]
        shl rdx, 3
        add rax, rdx

        movsd xmm0, qword [rax]         ; Load predicted value

        mov rsi, [rel linearRegression_y]
        lea rax, [rsi]
        add rax, rdx

        movsd xmm1, qword [rax]         ; Load y value

        mov rsi, [rel linearRegression_x]
        lea rax, [rsi]
        add rax, rdx

        movsd xmm2, qword [rax]         ; Load x value

        subsd xmm0, xmm1                ; predicted - y
        mulsd xmm0, xmm2                ; (predicted - y) * x

        movsd xmm3, qword [rel linearRegression_derivative_weight]
        addsd xmm3, xmm0                ; derivative_weight += (predicted - y) * x

        movsd qword [rel linearRegression_derivative_weight], xmm3

        pop rdx
        inc rdx

        cmp qword [rax], 0x0A
        je endDerivativeWeight

        jmp derivativeWeightLoop

    endDerivativeWeight:
        dec rdx

        movsd xmm0, qword [rel linearRegression_derivative_weight]
        cvtsi2sd xmm1, rdx
        divsd xmm0, xmm1               ; derivative_weight /= len(y)
        mulsd xmm0, qword [rel linearRegression_two] ; derivative_weight *= 2

        movsd qword [rel linearRegression_derivative_weight], xmm0

    ret

derivativeBias:
    xor rdx, rdx

    movsd xmm0, qword [rel linearRegression_derivative_bias]
    xorpd xmm0, xmm0

    movsd qword [rel linearRegression_derivative_bias], xmm0

    derivativeBiasLoop:
        push rdx

        lea rax, [rel linearRegression_predicted]
        shl rdx, 3
        add rax, rdx

        movsd xmm0, qword [rax]         ; Load predicted value

        mov rsi, [rel linearRegression_y]
        lea rax, [rsi]
        add rax, rdx

        movsd xmm1, qword [rax]         ; Load y value

        mov rsi, [rel linearRegression_x]
        lea rax, [rsi]
        add rax, rdx

        movsd xmm2, qword [rax]         ; Load x value

        subsd xmm0, xmm1                ; predicted - y

        movsd xmm3, qword [rel linearRegression_derivative_bias]
        addsd xmm3, xmm0                ; derivative_bias += (predicted - y)

        movsd qword [rel linearRegression_derivative_bias], xmm3
        
        pop rdx
        inc rdx

        cmp qword [rax], 0x0A
        je endDerivativeBias

        jmp derivativeBiasLoop

    endDerivativeBias:
        dec rdx

        movsd xmm0, qword [rel linearRegression_derivative_bias]
        cvtsi2sd xmm1, rdx
        divsd xmm0, xmm1               ; derivative_bias /= len(y)
        mulsd xmm0, qword [rel linearRegression_two] ; derivative_bias *= 2

        movsd qword [rel linearRegression_derivative_bias], xmm0

        ret

; --------------------- Update Weight ---------------------
updateWeight:
    movsd xmm0, qword [rel linearRegression_weight]
    movsd xmm1, qword [rel linearRegression_derivative_weight]
    movsd xmm2, qword [rel linearRegression_learning_rate]

    mulsd xmm1, xmm2             ; learning_rate * derivative_weight
    subsd xmm0, xmm1             ; weight -= learning_rate * derivative_weight

    movsd qword [rel linearRegression_weight], xmm0

    ret

; --------------------- Update Bias ---------------------
updateBias:
    movsd xmm0, qword [rel linearRegression_bias]
    movsd xmm1, qword [rel linearRegression_derivative_bias]
    movsd xmm2, qword [rel linearRegression_learning_rate]

    mulsd xmm1, xmm2             ; learning_rate * derivative_bias
    subsd xmm0, xmm1             ; bias -= learning_rate * derivative_bias

    movsd qword [rel linearRegression_bias], xmm0

    ret

; --------------------- Absolute Value Function ---------------------
floatAsboluteValue:
    cvtsd2si rax, xmm0

    cmp rax, 0
    jge endAbsoluteValue

    movsd xmm1, qword [rel linearRegression_minus_one]
    mulsd xmm0, xmm1

    endAbsoluteValue:

        ret