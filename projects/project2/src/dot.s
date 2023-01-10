.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1, 
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot:
    bge x0 a2 dot_exit_5  # 0 >= vector length, exit 5
    bge x0 a3 dot_exit_6  # 0 >= stride of v0, exit 6
    bge x0 a4 dot_exit_6  # 0 >= stride of v1, exit 6
    # Prologue
    addi sp sp -12
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)

    mv s0 x0  # s0 store the dot product
    mv t0 x0  # i = 0
    li t1 4
    mul s1 t1 a3  # i * s1 is the address offset of a0[i]
    mul s2 t1 a4  # i * s2 is the address offset of a1[i]
loop_start:
    beq t0 a2 loop_end
    mul t1 t0 s1
    add t1 a0 t1
    lw t1 0(t1)   # t1 = a0[i]
    mul t2 t0 s2
    add t2 a1 t2
    lw t2 0(t2)   # t2 = a1[i]
    mul t3 t1 t2
    add s0 s0 t3
    addi t0 t0 1  # i++
    j loop_start
loop_end:
    mv a0 s0
    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    addi sp sp 12
    ret
dot_exit_5:
    addi a1 x0 5  # exit with code 5
    jal exit2
dot_exit_6:
    addi a1 x0 6  # exit with code 6
    jal exit2