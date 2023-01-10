.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1, 
# this function exits with error code 7.
# =================================================================
argmax:
    bge x0 a1 argmax_exit  # 0 >= array length, exit
    mv t0 x0  # t0 is the iterator index i
    mv t1 x0  # t1 store the max index
    lw t2 0(a0)  # t2 store the max element
loop_start:
    beq t0 a1 loop_end
    slli t3 t0 2
    add t3 a0 t3
    lw t4 0(t3)
    bge t2 t4 loop_continue  # if cur_max >= a[i], continue
    mv t2 t4  # otherwise, update the max element and max index
    mv t1 t0
loop_continue:
    addi t0 t0 1  # increment i
    j loop_start
loop_end:
    mv a0 t1
    ret
argmax_exit:
    addi a1 x0 7  # otherwise exit with code 7
    jal exit2