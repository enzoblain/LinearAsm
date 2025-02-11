section .data
    linearRegression_max_iterations dq 10000
    linearRegression_learning_rate dq 0.01

    linearRegression_predicted dq 0.0, 0.0, 0.0, 0.0, 0.0, 0x0A
    linearRegression_weight dq 2.2
    linearRegression_derivative_weight dq 0.0
    linearRegression_bias dq 1.0
    linearRegression_derivative_bias dq 0.0
    linearRegression_loss dq 0.0
    linearRegression_previous_loss dq -1000000000000000.0

    linearRegression_minus_one dq -1.0
    linearRegression_two dq 2.0

    linearRegression_backline db 0x0A, 0

section .text
    global linearRegression
    extern printInt
    extern printFloat
    extern printFloatArray
    extern printString

; --------------------- Linear Regression Function ---------------------
; Needs to be called with r8 pointing to the x array and r9 pointing to the y array
; Returns the weight in r8 and the bias in r9
linearRegression:
    xor rdx, rdx 

    linearRegressionLoop:
        push rdx

        cmp rdx, qword [rel linearRegression_max_iterations]
        jge endLinearRegressionLoop

        call derivativeWeight
        call derivativeBias

        call updateWeight
        call updateBias

        call updatePredicted
        call calculateLoss

        pop rdx

        movsd xmm0, qword [rel linearRegression_previous_loss]
        movsd xmm1, qword [rel linearRegression_loss]

        movsd qword [rel linearRegression_previous_loss], xmm1

        subsd xmm0, xmm1

        call floatAsboluteValue

        inc rdx

        jmp linearRegressionLoop

    endLinearRegressionLoop:
        pop rdx 

        lea r8, [rel linearRegression_weight]
        lea r9, [rel linearRegression_bias]

        ret

; --------------------- Update Predicted Values ---------------------
; Needs to be called with r8 pointing to the x array
updatePredicted:
    xor rdx, rdx

    loopPredictionArray:
        push rdx

        lea rax, [r8]                ; Load array pointer
        shl rdx, 3                   ; Multiply index by 8 (because of qword)
        add rax, rdx                 ; Add index to pointer to get the address of the element

        movsd xmm0, qword [rax]         ; Load x value
        movsd xmm1, qword [rel linearRegression_weight] ; Load weight
        movsd xmm2, qword [rel linearRegression_bias] ; Load bias

        mulsd xmm0, xmm1              ; x * weight
        addsd xmm0, xmm2              ; x * weight + bias

        push rax

        lea rax, [rel linearRegression_predicted]    
        add rax, rdx

        movsd qword [rax], xmm0      ; Store predicted value

        pop rax

        pop rdx
        inc rdx

        cmp qword [rax + 8], 0x0A        ; Check for backline -> end of array (convention)
        je endloopPredictionArray   

        jmp loopPredictionArray

    endloopPredictionArray: 

    ret

; --------------------- Calculate Loss Function ---------------------
; Needs to be called with r8 pointing to the x array and r9 pointing to the y array
calculateLoss:
    xor rdx, rdx

    loopLoss:
        push rdx
    
        lea rax, [rel linearRegression_predicted]
        shl rdx, 3
        add rax, rdx

        movsd xmm0, qword [rax]         ; Load predicted value
        
        lea rax, [r9]
        add rax, rdx

        movsd xmm1, qword [rax]         ; Load y value

        subsd xmm0, xmm1                ; predicted - y
        mulsd xmm0, xmm0                ; (predicted - y) ^ 2

        movsd xmm3, qword [rel linearRegression_loss]
        addsd xmm3, xmm0                ; loss += (predicted - y) ^ 2

        movsd qword [rel linearRegression_loss], xmm3

        cmp qword [rax + 8], 0x0A
        je endLoopLoss

        pop rdx
        inc rdx

    jmp loopLoss

    endLoopLoss:
        pop rdx
        add rdx, 1

        movsd xmm0, qword [rel linearRegression_loss]
        cvtsi2sd xmm1, rdx
        divsd xmm0, xmm1               ; loss /= len(y)

        movsd qword [rel linearRegression_loss], xmm0

    ret

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

        lea rax, [r9]
        add rax, rdx

        movsd xmm1, qword [rax]         ; Load y value

        lea rax, [r8]
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

        lea rax, [r9]
        add rax, rdx

        movsd xmm1, qword [rax]         ; Load y value

        lea rax, [r8]
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
; Needs to be called with rxmm0 pointing to the float value
floatAsboluteValue:
    cvtsd2si rax, xmm0

    cmp rax, 0
    jge endAbsoluteValue

    movsd xmm1, qword [rel linearRegression_minus_one]
    mulsd xmm0, xmm1

    endAbsoluteValue:
        ret