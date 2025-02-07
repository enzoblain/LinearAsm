# Filename without extension
FILENAME="main"

# Assemble the source file
as -arch arm64 -o $FILENAME.o $FILENAME.s

# Link the object file to create the executable
ld -macos_version_min 15.0 -o $FILENAME $FILENAME.o -lSystem -syslibroot $(xcrun --show-sdk-path) -e _main

# Check if linking was successful
if [ $? -eq 0 ]; then
    ./"$FILENAME" # Run the executable

    # Clean up
    rm $FILENAME.o $FILENAME
else
    echo "Compilation failed!"
fi