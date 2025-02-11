#!/bin/bash

# Assemble the source files for x86_64 architecture (macOS)
nasm -f macho64 src/utils.asm -o src/utils.o
nasm -f macho64 src/linearRegression.asm -o src/linearRegression.o
nasm -f macho64 main.asm -o main.o

# Link the object files using clang and specify _start as the entry point
clang -o main main.o src/utils.o src/linearRegression.o -nostartfiles -arch x86_64 -e _start -Wl,-platform_version,macos,10.15,11.0

# Check if linking was successful
if [ $? -eq 0 ]; then
    ./main # Run the executable
    # lldb ./main -o "breakpoint set --name breakpoint" -o "run" -o "register read xmm1 xmm3" -o "quit" -o "Y"

    # Clean up object and executable files
    rm main main.o src/utils.o src/linearRegression.o
else
    echo "Compilation failed!"
fi