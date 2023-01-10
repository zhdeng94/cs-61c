.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
#
# If the length of the vector is less than 1, 
# this function exits with error code 8.
# ==============================================================================
relu:
    addi t0 x0 0  # t0 is the iterator index i
    blt x0 a1 loop_start  # array length > 0, perform element-wise ReLU
    addi a1 x0 8  # otherwise exit with code 8
    jal exit2
loop_start:
    beq t0 a1 loop_end
    slli t1 t0 2
    add t2 a0 t1
    lw t3 0(t2)
    blt x0 t3 loop_continue  # if a[i] > 0, do nothing
    sw x0 0(t2)  # else a[i] = 0
loop_continue:
    addi t0 t0 1  # increment i
    j loop_start
loop_end:
	ret