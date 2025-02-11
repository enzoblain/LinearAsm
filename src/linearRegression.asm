section .data
    linearRegression_max_iterations dq -1000
    linearRegression_learning_rate dq 0.01
    linearRegression_convergence_threshold dq 0.00001

    linearRegression_predicted dq 0.0, 0.0, 0.0, 0.0, 0.0, 0x0A
    linearRegression_weight dq 2.2
    linearRegression_bias dq 1.0

section .text
    global linearRegression
    extern printFloatArray

; --------------------- Linear Regression Function ---------------------
; Needs to be called with r8 pointing to the x array and r9 pointing to the y array
linearRegression:


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

        cmp qword [rax + 8], 0x0A        ; Check for backline -> end of array (convention)
        je endloopPredictionArray   

        pop rdx
        inc rdx

        jmp loopPredictionArray

    endloopPredictionArray: 
        pop rdx
        
    ret