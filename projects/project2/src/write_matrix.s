.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof, 
# this function exits with error code 53.
# If you receive an fwrite error or eof,
# this function exits with error code 54.
# If you receive an fclose error or eof,
# this function exits with error code 55.
# ==============================================================================
write_matrix:
    # Prologue
    addi sp sp -24
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)

    mv s0 a0
    mv s1 a1
    mv s2 a2
    mv s3 a3
    # open the file to write
    mv a1 s0
    addi t0 x0 1
    mv a2 t0
    jal ra fopen
    addi t0 x0 -1
    beq a0 t0 fopen_exit_53
    mv s0 a0  # s0 is the file descriptor

    # allocate a buffer of 8 bytes to hold row and col
    addi a0 x0 8
    jal ra malloc
    mv s4 a0
    sw s2 0(s4)  # s2 is the row
    sw s3 4(s4)  # s3 is the col

    # write row and col to file
    mv a1 s0
    mv a2 s4
    addi a3 x0 2
    addi a4 x0 4
    jal ra fwrite
    bne a0 a3 fwrite_exit_54

    # free int buffer
    mv a0 s4
    jal ra free

    # write array of size row * col to file
    mv a1 s0
    mv a2 s1
    mul a3 s2 s3
    addi a4 x0 4
    jal ra fwrite
    mul t0 s2 s3
    bne a0 t0 fwrite_exit_54

    # close the file
    mv a1 s0
    jal ra fclose
    bne a0 x0 fclose_exit_55

    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    addi sp sp 24
    ret
fopen_exit_53:
    addi a1 x0 53
    jal exit2
fwrite_exit_54:
    addi a1 x0 54
    jal exit2
fclose_exit_55:
    addi a1 x0 55
    jal exit2