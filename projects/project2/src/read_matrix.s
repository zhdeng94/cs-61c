.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive an fopen error or eof, 
# this function exits with error code 50.
# If you receive an fread error or eof,
# this function exits with error code 51.
# If you receive an fclose error or eof,
# this function exits with error code 52.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)

    # store the pointers
    mv s4 a1
    mv s5 a2

    # open file
    mv a1 a0
    mv a2 x0
    jal ra fopen
    addi t0 x0 -1
    beq a0 t0 fopen_exit_50
    mv s0 a0  # s0 is the file descriptor

    # read number of row and col
    # allocate 4 byte to hold an int
    addi a0 x0 4
    jal ra malloc
    mv s1 a0  # s1 is the pointer to int
    # read the No. of row
    mv a1 s0
    mv a2 s1
    addi a3 x0 4
    jal ra fread
    addi t0 x0 4
    bne a0 t0 fread_exit_51 # read error
    lw s2 0(s1)  # s2 is the No. of row
    # read the No. of col
    mv a1 s0
    mv a2 s1
    addi a3 x0 4
    jal ra fread
    addi t0 x0 4
    bne a0 t0 fread_exit_51 # read error
    lw s3 0(s1)  # s3 is the No. of col
    # free the 4 byte heap memory for the int
    mv a0 s1
    jal ra free

    # allocate memory of an array of size row * col
    mul a0 s2 s3
    slli a0 a0 2
    jal ra malloc
    mv s1 a0  # s1 is now pointer to matrix
    # read the matrix
    mv a1 s0
    mv a2 s1
    mul a3 s2 s3
    slli a3 a3 2
    jal ra fread
    mul t0 s2 s3
    slli t0 t0 2
    bne a0 t0 fread_exit_51 # read error

    # close the file
    mv a1 s0
    jal ra fclose
    bne a0 x0 fclose_exit_52

    mv a0 s1
    sw s2 0(s4)
    sw s3 0(s5)
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    addi sp sp 28
    ret
fopen_exit_50:
    addi a1 x0 50
    jal exit2
fread_exit_51:
    addi a1 x0 51
    jal exit2
fclose_exit_52:
    addi a1 x0 52
    jal exit2