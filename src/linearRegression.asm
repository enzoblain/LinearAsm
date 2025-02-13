section .data
    ; Define linear regression constants
    linearRegression_max_iterations dq 10000
    linearRegression_learning_rate dq 0.01

    ; Define numbers that would be used
    linearRegression_sixteen dq 16.0
    linearRegression_eight dq 8.0

    ; Linear Regression Variables
    linearRegression_difference dq 0.0, 0.0, 0.0, 0.0, 0.0, 0x0A
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

    call calculDifference                                          ; Calculate the difference

    linearRegressionLoop:
        cmp rcx, qword [rel linearRegression_max_iterations]       ; Check if the max iterations has been reached
        jge endLinearRegressionLoop                                ; If yes, exit the loop

        push rcx                                                   ; Save the iteration counter

        call updateParameters                                      ; Update the parameters (weight and bias)

        call calculDifference                                      ; Calculate the difference

        call updatePredicted                                       ; Update the predicted values
        call calculateLoss                                         ; Calculate the loss

        pop rcx                                                    ; Restore the iteration counter
        inc rcx                                                    ; Increment the iteration counter

        jmp linearRegressionLoop                                   ; Else, continue the loop

    endLinearRegressionLoop:
        mov rax, [rel linearRegression_weight]                     ; Return the weight
        mov rdx, [rel linearRegression_bias]                       ; Return the bias

        ret

; --------------------- Calculate Difference ---------------------
; Calculate the difference between the predicted and the y values
calculDifference:
    xor rcx, rcx                                                   ; Initialize the iteration counter

    loopCalculDifference:
        lea rax, [rel linearRegression_predicted]                  ; Load predicted array pointer
        cmp qword [rax + rcx], 0x0A                                ; Check for backline
        je endLoopCalculDifference                                 ; If backline, end of array (convention)

        movsd xmm0, qword [rax + rcx]                              ; Load predicted value

        mov rdi, [rel linearRegression_y]                          ; Load y array pointer
        lea rax, [rdi + rcx]                                       ; Load y value pointer
        movsd xmm1, qword [rax]                                    ; Load y value

        subsd xmm0, xmm1                                           ; difference = predicted - y

        lea rax, [rel linearRegression_difference]                 ; Load difference array pointer
        movsd qword [rax + rcx], xmm0                              ; Store difference

        add rcx, 8                                                 ; Increment the iteration counter (next byte)

        jmp loopCalculDifference                                   ; Continue the loop

    endLoopCalculDifference:
        ret

; --------------------- Update Predicted Values ---------------------
; Update the predicted values using the weight and bias
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

        add rcx, 8                                                 ; Increment the iteration counter (next byte)

        jmp loopPredictionArray                                    ; Continue the loop

    endloopPredictionArray: 
        ret

; --------------------- Calculate Loss Function ---------------------
; Loss formula : loss = sum((predicted - y) ^ 2) / len(y)
calculateLoss:
    xor rcx, rcx                                                   ; Initialize the iteration counter

    loopLoss:
        lea rax, [rel linearRegression_difference]                 ; Load difference array pointer in rax 

        cmp qword [rax + rcx], 0x0A                                ; Check for backline
        je endLoopLoss                                             ; If backline, end of array (convention)                                       

        movsd xmm0, qword [rax]                                    ; Load (predicted - y)
        
        mulsd xmm0, xmm0                                           ; (predicted - y) ^ 2

        movsd xmm2, qword [rel linearRegression_loss]              ; Load loss
        addsd xmm2, xmm0                                           ; loss += (predicted - y) ^ 2

        movsd qword [rel linearRegression_loss], xmm3              ; Store loss

        add rcx, 8                                                 ; Increment the iteration counter (next byte)

        jmp loopLoss                                               ; Continue the loop

    endLoopLoss:
        movsd xmm0, qword [rel linearRegression_loss]              ; Load loss
        cvtsi2sd xmm1, rcx                                         ; Convert iteration counter to double
        divsd xmm0, xmm1                                           ; loss /= len(y)
        mulsd xmm0, qword [rel linearRegression_eight]             ; Divide by 8 because rcx is incremented by 8 for byte array
        movsd qword [rel linearRegression_loss], xmm0              ; Store loss

    ret

; --------------------- Update Parameters ---------------------
; Update the weight and bias using the derivative of the loss function
; Derivative of the bias : 2 * sum(predicted - y) / len(y)
; Derivative of the weight : 2 * sum((predicted - y) * x) / len(y)
updateParameters:
    xor rcx, rcx                                                   ; Initialize the iteration counter
    xorpd xmm0, xmm0                                               ; Initialize the derivaitve_weight to 0
    xorpd xmm1, xmm1                                               ; Initialize the derivaitve_bias to 0

    updateDerivatives:
        lea rax, [rel linearRegression_difference]                 ; Load difference array pointer in rax

        cmp qword [rax + rcx], 0x0A                                ; Check for backline
        je endUpdateDerivatives                                    ; If backline, end of array (convention)

        movsd xmm2, qword [rax + rcx]                              ; Load (predicted - y)

        mov rsi, [rel linearRegression_x]                          ; Load x array pointer in rsi
        lea rax, [rsi]                                             ; Load x array pointer
        movsd xmm3, qword [rax + rcx]                              ; Load x value

        addsd xmm1, xmm2                                           ; derivative_bias += (predicted - y)

        mulsd xmm2, xmm3                                           ; (predicted - y) * x
        addsd xmm0, xmm2                                           ; derivative_weight += (predicted - y) * x

        add rcx, 8                                                 ; Increment the iteration counter (next byte)
        jmp updateDerivatives                                      ; Continue the loop

    endUpdateDerivatives:
        cvtsi2sd xmm2, rcx                                         ; Convert iteration counter to double

        divsd xmm0, xmm2                                           ; derivative_weight /= len(y)
        divsd xmm1, xmm2                                           ; derivative_bias /= len(y)
        ; rcx = 8 * len(y) because it is incremented by 8 for byte array
        mulsd xmm0, qword [rel linearRegression_sixteen]           ; Multiply by 16 (8 * 2)
        mulsd xmm1, qword [rel linearRegression_sixteen]           ; Multiply by 16 (8 * 2)

        movsd qword [rel linearRegression_derivative_weight], xmm0 ; Store derivative_weight
        movsd qword [rel linearRegression_derivative_bias], xmm1   ; Store derivative_bias

        call updateWeight                                          ; Update the weight
        call updateBias                                            ; Update the bias

    ret

; --------------------- Update Weight ---------------------
updateWeight:
    movsd xmm0, qword [rel linearRegression_weight]                ; Load weight
    movsd xmm1, qword [rel linearRegression_derivative_weight]     ; Load derivative_weight
    movsd xmm2, qword [rel linearRegression_learning_rate]         ; Load learning_rate

    mulsd xmm1, xmm2                                               ; learning_rate * derivative_weight
    subsd xmm0, xmm1                                               ; weight -= learning_rate * derivative_weight

    movsd qword [rel linearRegression_weight], xmm0                ; Store weight

    ret

; --------------------- Update Bias ---------------------
updateBias:
    movsd xmm0, qword [rel linearRegression_bias]                   ; Load bias
    movsd xmm1, qword [rel linearRegression_derivative_bias]        ; Load derivative_bias
    movsd xmm2, qword [rel linearRegression_learning_rate]          ; Load learning_rate

    mulsd xmm1, xmm2                                                ; learning_rate * derivative_bias
    subsd xmm0, xmm1                                                ; bias -= learning_rate * derivative_bias

    movsd qword [rel linearRegression_bias], xmm0                   ; Store bias

    ret