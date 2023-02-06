.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>


    # Prologue
    addi sp sp -52
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    sw s7 32(sp)
    sw s8 36(sp)
    sw s9 40(sp)
    sw s10 44(sp)
    sw s11 48(sp)

    # save input args
    mv s0 a0
    mv s1 a1
    mv s2 a2

    # Check for correct command line args
    addi t0 x0 5
    bne s0 t0 command_args_exit_49

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    addi a0 x0 4
    jal ra malloc
    mv s3 a0  # s3 is a pointer to the row of m0
    addi a0 x0 4
    jal ra malloc
    mv s4 a0  # s4 is a pointer to the col of m0
    lw a0 4(s1)  # load argv[1] 
    mv a1 s3
    mv a2 s4
    jal ra read_matrix
    mv s5 a0  # s5 is the pointer to m0

    # Load pretrained m1
    addi a0 x0 4
    jal ra malloc
    mv s6 a0  # s6 is a pointer to the row of m1
    addi a0 x0 4
    jal ra malloc
    mv s7 a0  # s7 is a pointer to the col of m1
    lw a0 8(s1)  # load argv[2] 
    mv a1 s6
    mv a2 s7
    jal ra read_matrix
    mv s8 a0  # s8 is the pointer to m1

    # Load input matrix
    addi a0 x0 4
    jal ra malloc
    mv s9 a0  # s9 is a pointer to the row of input
    addi a0 x0 4
    jal ra malloc
    mv s10 a0  # s10 is a pointer to the col of input
    lw a0 12(s1)  # load argv[3] 
    mv a1 s9
    mv a2 s10
    jal ra read_matrix
    mv s11 a0  # s11 is the pointer to input

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    lw t0 0(s3)
    lw t1 0(s10)
    mul a0 t0 t1
    slli a0 a0 2
    jal ra malloc
    mv t0 a0  # t0 is pointer to d
    mv a0 s5
    lw a1 0(s3)
    lw a2 0(s4)
    mv a3 s11
    lw a4 0(s9)
    lw a5 0(s10)
    mv a6 t0

    addi sp sp -4
    sw t0 0(sp)
    jal ra matmul
    lw t0 0(sp)
    addi sp sp 4

    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    lw t1 0(s3)
    lw t2 0(s10)
    mul a1 t1 t2
    mv a0 t0
    addi sp sp -4
    sw t0 0(sp)
    jal ra relu
    lw t0 0(sp)
    addi sp sp 4

    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    lw t1 0(s6)
    lw t2 0(s10)
    mul a0 t1 t2
    slli a0 a0 2
    addi sp sp -4
    sw t0 0(sp)
    jal ra malloc
    lw t0 0(sp)
    addi sp sp 4
    mv t1 a0  # t1 is the pointer to score

    mv a0 s8
    lw a1 0(s6)
    lw a2 0(s7)
    mv a3 t0
    lw a4 0(s3)
    lw a5 0(s10)
    mv a6 t1

    addi sp sp -8
    sw t0 0(sp)
    sw t1 4(sp)
    jal ra matmul
    lw t0 0(sp)
    lw t1 4(sp)
    addi sp sp 8

    # free up malloc memory
    addi sp sp -4
    sw t1 0(sp)

    mv a0 t0
    jal ra free
    mv a0 s5
    jal ra free
    mv a0 s8
    jal ra free
    mv a0 s11
    jal ra free
    lw s5 0(s6)  # now s5 is row of score matrix
    lw s8 0(s10)  # now s8 is col of score matrix
    mv a0 s3
    jal ra free
    mv a0 s4
    jal ra free
    mv a0 s6
    jal ra free
    mv a0 s7
    jal ra free
    mv a0 s9
    jal ra free
    mv a0 s10
    jal ra free

    lw t1 0(sp)
    addi sp sp 4

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0 16(s1)  # load argv[4] 
    mv a1 t1
    mv s4 t1  # now s4 is the pointer to score matrix
    mv a2 s5
    mv a3 s8
    jal ra write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0 s4
    mul a1 s5 s8
    jal ra argmax
    mv s6 a0

    mv a0 s4
    jal ra free
    
    bne s2 x0 end
    # Print classification
    mv a1 s6
    jal ra print_int
    # Print newline afterwards for clarity
    li a1 '\n'
    jal print_char
end:
    # epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    lw s7 32(sp)
    lw s8 36(sp)
    lw s9 40(sp)
    lw s10 44(sp)
    lw s11 48(sp)
    addi sp sp 52
    ret
command_args_exit_49:
    addi a1 x0 49
    jal exit2