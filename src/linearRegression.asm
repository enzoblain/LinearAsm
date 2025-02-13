section .data
    ; Define linear regression constants
    linearRegression_max_iterations dq 10000
    linearRegression_learning_rate dq 0.01

    ; Define numbers that would be used
    linearRegression_sixteen dq 16.0
    linearRegression_eight dq 8.0

    ; Linear Regression Variables
    linearRegression_predicted dq 0.0, 0.0, 0.0, 0.0, 0.0, 0x0A
    linearRegression_weight dq 0.0
    linearRegression_derivative_weight dq 0.0
    linearRegression_bias dq 0.0
    linearRegression_derivative_bias dq 0.0
    linearRegression_loss dq 0.0

section .bss
    ; Reserve space for the x and y arrays
    linearRegression_x resq 1
    linearRegression_y resq 1

section .text
    global linearRegression

; --------------------- Linear Regression Function ---------------------
; Needs to be called with rdi pointing to the x array and rsi pointing to the y array
; Returns the weight in rax and the bias in rdx
linearRegression:
    mov [rel linearRegression_x], rdi                              ; Save the pointer to the x array
    mov [rel linearRegression_y], rsi                              ; Save the pointer to the y array

    xor rcx, rcx                                                   ; Initialize the iteration counter

    linearRegressionLoop:
        cmp rcx, qword [rel linearRegression_max_iterations]       ; Check if the max iterations has been reached
        jge endLinearRegressionLoop                                ; If yes, exit the loop

        push rcx                                                   ; Save the iteration counter

        call updateWeight                                          ; Update the weight with gradient descent
        call updateBias                                            ; Update the bias with gradient descent

        call updatePredicted                                       ; Update the predicted values
        call calculateLoss                                         ; Calculate the loss

        pop rcx                                                    ; Restore the iteration counter
        inc rcx                                                    ; Increment the iteration counter

        jmp linearRegressionLoop                                   ; Else, continue the loop

    endLinearRegressionLoop:
        mov rax, [rel linearRegression_weight]                     ; Return the weight
        mov rdx, [rel linearRegression_bias]                       ; Return the bias

        ret

; --------------------- Update Predicted Values ---------------------
updatePredicted:
    xor rcx, rcx                                                   ; Initialize the iteration counter

    loopPredictionArray:
        mov rdi, [rel linearRegression_x]                          ; Copy x array pointer to rdi
        lea rax, [rdi + rcx]                                       ; Load array pointer
        breakpoint: 

        cmp qword [rax], 0x0A                                      ; Check for backline
        je endloopPredictionArray                                  ; If backline, end of array (convention)

        movsd xmm0, qword [rax]                                    ; Load x value
        movsd xmm1, qword [rel linearRegression_weight]            ; Load weight
        movsd xmm2, qword [rel linearRegression_bias]              ; Load bias

        mulsd xmm0, xmm1                                           ; x * weight
        addsd xmm0, xmm2                                           ; x * weight + bias
    
        lea rax, [rel linearRegression_predicted]                  ; Load predicted array pointer in rax
        movsd qword [rax + rcx], xmm0                              ; Store predicted value

        add rcx, 8                                                 ; Increment the iteration counter

        jmp loopPredictionArray                                    ; Continue the loop

    endloopPredictionArray: 
        ret

; --------------------- Calculate Loss Function ---------------------
calculateLoss:
    xor rcx, rcx                                                   ; Initialize the iteration counter

    loopLoss:
        mov rdi, [rel linearRegression_x]                          ; Load x array pointer
        lea rax, [rdi + rcx]                                       ; Load array pointer

        cmp qword [rax], 0x0A                                      ; Check for backline
        je endLoopLoss                                             ; If backline, end of array (convention)                                       

        movsd xmm0, qword [rax]                                    ; Load predicted value
        
        mov rdi, [rel linearRegression_y]                          ; Load y array pointer
        lea rax, [rdi + rcx]                                       ; Load y value pointer      

        movsd xmm1, qword [rax]                                    ; Load y value

        subsd xmm0, xmm1                                           ; predicted - y
        mulsd xmm0, xmm0                                           ; (predicted - y) ^ 2

        movsd xmm3, qword [rel linearRegression_loss]              ; Load loss
        addsd xmm3, xmm0                                           ; loss += (predicted - y) ^ 2

        movsd qword [rel linearRegression_loss], xmm3              ; Store loss

        add rcx, 8                                                 ; Increment the iteration counter

        jmp loopLoss                                               ; Continue the loop

    endLoopLoss:
        movsd xmm0, qword [rel linearRegression_loss]              ; Load loss
        cvtsi2sd xmm1, rcx                                         ; Convert iteration counter to double
        divsd xmm0, xmm1                                           ; loss /= len(y)
        mulsd xmm0, qword [rel linearRegression_eight]             ; Divide by 8 because rcx is incremented by 8 for byte array
        movsd qword [rel linearRegression_loss], xmm0              ; Store loss

    ret

; --------------------- Calculate Derivative Weight ---------------------
calculDerivativeWeight:
    xor rcx, rcx                                                   ; Initialize the iteration counter

    xorpd xmm0, xmm0                                               ; Set xmm0 to 0
    movsd qword [rel linearRegression_derivative_weight], xmm0     ; Set derivative_weight to 0

    calculDerivativeWeightLoop:
        lea rax, [rel linearRegression_predicted]                  ; Load predicted array pointer in rax

        cmp qword [rax + rcx], 0x0A                                ; Check for backline
        je endCalculDerivativeWeight                               ; If backline, end of array (convention)

        movsd xmm0, qword [rax + rcx]                              ; Load predicted value

        mov rsi, [rel linearRegression_y]                          ; Load y array pointer in rsi
        lea rax, [rsi]                                             ; Load y array pointer
        movsd xmm1, qword [rax + rcx]                              ; Load y value

        mov rsi, [rel linearRegression_x]                          ; Load x array pointer in rsi
        lea rax, [rsi]                                             ; Load x array pointer
        movsd xmm2, qword [rax + rcx]                              ; Load x value

        subsd xmm0, xmm1                                           ; predicted - y
        mulsd xmm0, xmm2                                           ; (predicted - y) * x

        movsd xmm3, qword [rel linearRegression_derivative_weight] ; Load derivative_weight
        addsd xmm3, xmm0                                           ; derivative_weight += (predicted - y) * x

        movsd qword [rel linearRegression_derivative_weight], xmm3 ; Store derivative_weight

        add rcx, 8                                                 ; Increment the iteration counter

        jmp calculDerivativeWeightLoop                             ; Continue the loop

    endCalculDerivativeWeight:
        movsd xmm0, qword [rel linearRegression_derivative_weight] ; Load derivative_weight
        cvtsi2sd xmm1, rcx                                         ; Convert iteration counter to double
        divsd xmm0, xmm1                                           ; derivative_weight /= len(y)
        mulsd xmm0, qword [rel linearRegression_sixteen]           ; Divide by 16 because rcx is incremented by 8 for byte array and formula is 2 * sum(x * (predicted - y))
        movsd qword [rel linearRegression_derivative_weight], xmm0 ; Store derivative_weight

    ret

calculDerivativeBias:
    xor rcx, rcx                                                   ; Initialize the iteration counter

    xorpd xmm0, xmm0                                               ; Set xmm0 to 0
    movsd qword [rel linearRegression_derivative_bias], xmm0       ; Set derivative_bias to 0

    calculDerivativeBiasLoop:
        lea rax, [rel linearRegression_predicted]                  ; Load predicted array pointer in rax

        cmp qword [rax + rcx], 0x0A                                ; Check for backline
        je endCalculDerivativeBias                                 ; If backline, end of array (convention)

        movsd xmm0, qword [rax + rcx]                              ; Load predicted value

        mov rsi, [rel linearRegression_y]                          ; Load y array pointer in rsi
        lea rax, [rsi]                                             ; Load y array pointer
        movsd xmm1, qword [rax + rcx]                              ; Load y value

        mov rsi, [rel linearRegression_x]                          ; Load x array pointer in rsi
        lea rax, [rsi]                                             ; Load x array pointer
        movsd xmm2, qword [rax + rcx]                              ; Load x value

        subsd xmm0, xmm1                                           ; predicted - y

        movsd xmm3, qword [rel linearRegression_derivative_bias]   ; Load derivative_bias
        addsd xmm3, xmm0                                           ; derivative_bias += (predicted - y)

        movsd qword [rel linearRegression_derivative_bias], xmm3   ; Store derivative_bias
        
        add rcx, 8                                                 ; Increment the iteration counter

        jmp calculDerivativeBiasLoop                               ; Continue the loop

    endCalculDerivativeBias:
        movsd xmm0, qword [rel linearRegression_derivative_bias]   ; Load derivative_bias
        cvtsi2sd xmm1, rcx                                         ; Convert iteration counter to double
        divsd xmm0, xmm1                                           ; derivative_bias /= len(y)
        mulsd xmm0, qword [rel linearRegression_sixteen]           ; Divide by 16 because rcx is incremented by 8 for byte array and formula is 2 * sum(predicted - y)

        movsd qword [rel linearRegression_derivative_bias], xmm0   ; Store derivative_bias

        ret

; --------------------- Update Weight ---------------------
updateWeight:
    call calculDerivativeWeight                                    ; Calculate the derivative of the weight

    movsd xmm0, qword [rel linearRegression_weight]                ; Load weight
    movsd xmm1, qword [rel linearRegression_derivative_weight]     ; Load derivative_weight
    movsd xmm2, qword [rel linearRegression_learning_rate]         ; Load learning_rate

    mulsd xmm1, xmm2                                               ; learning_rate * derivative_weight
    subsd xmm0, xmm1                                               ; weight -= learning_rate * derivative_weight

    movsd qword [rel linearRegression_weight], xmm0                ; Store weight

    ret

; --------------------- Update Bias ---------------------
updateBias:
    call calculDerivativeBias                                       ; Calculate the derivative of the bias

    movsd xmm0, qword [rel linearRegression_bias]                   ; Load bias
    movsd xmm1, qword [rel linearRegression_derivative_bias]        ; Load derivative_bias
    movsd xmm2, qword [rel linearRegression_learning_rate]          ; Load learning_rate

    mulsd xmm1, xmm2                                                ; learning_rate * derivative_bias
    subsd xmm0, xmm1                                                ; bias -= learning_rate * derivative_bias

    movsd qword [rel linearRegression_bias], xmm0                   ; Store bias

    ret