#!/bin/bash

# Assemble the source files for x86_64 architecture (macOS)
nasm -f macho64 src/intToString.asm -o src/intToString.o
nasm -f macho64 src/print.asm -o src/print.o
nasm -f macho64 main.asm -o main.o

# Link the object files using clang and specify _start as the entry point
clang -o main main.o src/intToString.o src/print.o -nostartfiles -arch x86_64 -e _start -Wl,-platform_version,macos,10.15,11.0

# Check if linking was successful
if [ $? -eq 0 ]; then
    ./main # Run the executable

    # Clean up object and executable files
    rm main main.o src/intToString.o src/print.o
else
    echo "Compilation failed!"
fi