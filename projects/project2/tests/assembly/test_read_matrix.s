.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"

.text
main:
    # Read matrix into memory
    addi a0 x0 4
    jal ra malloc
    mv s1 a0
    addi a0 x0 4
    jal ra malloc
    mv s2 a0
    la a0 file_path
    mv a1 s1
    mv a2 s2
    jal ra read_matrix

    # Print out elements of matrix
    lw a1 0(s1)
    lw a2 0(s2)
    jal ra print_int_array

    # Terminate the program
    mv a0 s1
    jal ra free
    mv a0 s2
    jal ra free
    jal exit