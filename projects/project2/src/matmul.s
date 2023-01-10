.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:

    # Error checks
    bge x0 a1 matmul_exit_2
    bge x0 a2 matmul_exit_2
    bge x0 a4 matmul_exit_3
    bge x0 a5 matmul_exit_3
    bne a2 a4 matmul_exit_4

    # Prologue
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)

    mv s0 a0  # address of m0
    mv s1 a3  # address of m1
    mv s2 a1  # # of rows in m0
    mv s3 a2  # # of cols in m0 and # of rows in m1
    mv s4 a5  # # of cols in m1
    mv s5 a6  # address of d

    mv t0 x0  # i = 0

outer_loop_start:
    beq t0 s2 outer_loop_end
    mv t1 x0  # j = 0
inner_loop_start:
    beq t1 s4 inner_loop_end
    # calculate address of row i of m0
    mul a0 t0 s3
    slli a0 a0 2
    add a0 s0 a0
    # set the stride of row i
    li a3 1
    # set the length of vector
    mv a2 s3
    # calculate address of col j of m1
    slli a1 t1 2
    add a1 s1 a1
    # set the stride of col j
    mv a4 s4

    # store t registers
    addi sp sp -8
    sw t0 0(sp)
    sw t1 4(sp)

    # call dot function
    jal ra dot

    # recover t registers
    lw t0 0(sp)
    lw t1 4(sp)
    addi sp sp 8

    # store dot product to d[i][j]
    mul t2 t0 s4
    add t2 t2 t1
    slli t2 t2 2
    add t2 s5 t2
    sw a0 0(t2)

    addi t1 t1 1  # j++
    j inner_loop_start
inner_loop_end:
    addi t0 t0 1  # i++
    j outer_loop_start
outer_loop_end:
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
matmul_exit_2:
    addi a1 x0 2
    jal exit2
matmul_exit_3:
    addi a1 x0 3
    jal exit2
matmul_exit_4:
    addi a1 x0 4
    jal exit2