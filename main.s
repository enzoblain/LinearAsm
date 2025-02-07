.section __TEXT,__cstring
message: .asciz "Hello, World!\n"  ; Message to display

.section __TEXT,__text,regular,pure_instructions
.globl _main
.p2align 2
_main:
    adrp x0, message@PAGE      ; Load the address of the message in x0
    add x0, x0, message@PAGEOFF
    bl _printf                 ; Call printf to display the message

    mov w0, 0                  ; Return 0 for success
    bl _exit                   ; Exit the program
