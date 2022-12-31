#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "lfsr.h"

void lfsr_calculate(uint16_t *reg) {
    /* YOUR CODE HERE */
    uint16_t b1 = ((*reg) & (1 << 0)) >> 0;
    uint16_t b2 = ((*reg) & (1 << 2)) >> 2;
    uint16_t b3 = ((*reg) & (1 << 3)) >> 3;
    uint16_t b4 = ((*reg) & (1 << 5)) >> 5;
    uint16_t msb = b1 ^ b2 ^ b3 ^ b4;
    *reg = ((*reg) >> 1) | (msb << 15);
}

