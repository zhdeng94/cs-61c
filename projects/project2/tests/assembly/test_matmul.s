.import ../../src/matmul.s
.import ../../src/utils.s
.import ../../src/dot.s

# static values for testing
.data
m0: .word 1 2 -1 3 4 -5 3 -2 8 0 1 5
m1: .word 3 1 -4 6 2 -9 2 0 3 5 6 -6 -1 0 3 -8 1 9 3 7
d: .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 # allocate static space for output

.text
main:
    # Load addresses of input matrices (which are in static memory), and set their dimensions
    la a0 m0
    li a1 3
    li a2 4
    la a3 m1
    li a4 4
    li a5 5
    la a6 d

    # Call matrix multiply, m0 * m1
    jal ra matmul

    # Print the output (use print_int_array in utils.s)
    mv a0 a6
    li a1 3
    li a2 5
    jal ra print_int_array

    # Exit the program
    jal exit