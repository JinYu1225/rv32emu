.org 0
.global _start
    # new system call
    .equ SYSSTDOUT, 1
    .equ SYSWRITE, 64
    .equ SYSEXIT, 93

.data
    mask1: .word 0x55555555
    mask2: .word 0x33333333
    mask4: .word 0x0f0f0f0f
    test1: .dword 0x0000000000100000, 0x00000000000FFFFF # HD(1048576, 1048575) = 21
    test2: .dword 0x0000000000000001, 0x7FFFFFFFFFFFFFFE # HD(1, 9223372036854775806) = 63
    test3: .dword 0x000000028370228F, 0x000000028370228F # HD(10795098767, 10795098767) = 0

    str1: .string "\nThe clz result is "
          .set str_size1, .-str1
          
    str2: .string "\n"
          .set str_size2, .-str2
          
    str3: .string "The Hamming distance is "
          .set str_size3, .-str3

.text
_start:
main:
    # push addresses of the test data onto the stack
    addi sp, sp, -12
    la t0, test1
    sw t0, 0(sp)
    la t0, test2
    sw t0, 4(sp)
    la t0, test3
    sw t0, 8(sp)
    # put test1 in a0, a2 
    # s0: points to test data
    # s1: number of test data
    # s2: test data counter
    lw s0, 0(sp) 
    add a0, s0, x0
    addi a1, s0, 8
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, HAMDIS
    lw ra, 0(sp)
    addi sp, sp, 4

DONE:
    addi sp, sp, 12
    add a0, x0, 0
    li a7, SYSEXIT
    ecall
    
HAMDIS:
    # a0: address of lower 32-bit of first number
    # a1: address of lower 32-bit of second number
    # s0: check no 1 bit remain in xor
    # s1: upper 32-bit of first number
    # s2: lower 32-bit of first number
    # s3: upper 32-bit of second number
    # s4: lower 32-bit of second number
    # s5: hamming distance
    # s6: check if shift more than 32
    # output hamming distance

HAMDIS_MAIN:
    # store s1-6 onto stack
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    # load test number
    lw s1, 4(a0)
    lw s2, 0(a0)
    lw s3, 4(a1)
    lw s4, 0(a1)
    add s5, s5, x0
    addi s6, x0, 32
    # c1 = x1 ^ x2
    # s1 = upper 32-bit of c1
    # s2 = lower 32-bit of c1
    xor s1, s1, s3
    xor s2, s2, s4

HAMDIS_LOOP:
    # while (c1 != 0)
    or s0, s1, s2 
    beq s0, x0, EXIT_HAMDIS
    addi s5, s5, 1 # hamdis + 1
    # clz
    add a0, s1, x0
    add a1, s2, x0
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, CLZ
    lw ra, 0(sp)
    addi sp, sp, 4
    # c1 = c1 << clz_count + 1
    addi a0, a0, 1
    bge a0, s6, SGE32

SLT32: # shift less than 32-bit
    sll s1, s1, a0 # s1 = s1 << a0
    sub t0, s6, a0 # t0 = 32 - (clz_count + 1)
    srl t1, s2, t0 # t1 = s2 >> t0
    or s1, s1, t1  # s1 = s1 & t1
    sll s2, s2, a0 # s2 = s2 << a0
    j HAMDIS_LOOP

SGE32: # shift greater equ 32-bit
    sub t0, a0, s6 # t0 = (clz_count + 1) - 32
    sll s1, s2, t0 # s1 = s2 << t0
    add s2, x0, x0 # s2 = 0
    j HAMDIS_LOOP

PRINT_HAMDIS:
    # print str3
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    li a0, SYSSTDOUT
    la a1, str3
    li a2, str_size3
    li a7, SYSWRITE
    ecall
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    
    # print HAMDIS (HAMDIS <= 64)
    # t2: tens digit
    # t1: units digit
    addi t0, x0, 10
    add t1, a0, x0
    add t2, x0, x0
PRINT_HAMDIS_LOOP:
    blt t1, t0, PRINTINT_HAMDIS
    addi t1, t1, -10
    addi t2, t2, 1
    j PRINT_HAMDIS_LOOP
PRINTINT_HAMDIS:
    addi t1, t1, 48
    addi t2, t2, 48
    addi sp, sp, -20
    sw t1, 0(sp)
    sw t2, 4(sp)
    sw a0, 8(sp)
    sw a1, 12(sp)
    sw a2, 16(sp)
    # print tens digit
    li a0, SYSSTDOUT
    addi a1, sp, 4
    li a2, 1
    li a7, SYSWRITE
    ecall
    # print units digit
    addi a1, sp, 0
    ecall
    # print ("\n")
    la a1, str2
    li a2, str_size2
    ecall
    lw t1, 0(sp)
    lw t2, 4(sp)
    lw a0, 8(sp)
    lw a1, 12(sp)
    lw a2, 16(sp)
    addi sp, sp, 20
    ret
    
EXIT_HAMDIS:
    add a0, s5, x0
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, PRINT_HAMDIS
    lw ra, 0(sp)
    addi sp, sp, 4
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    addi sp, sp, 28
    ret

CLZ:
    # pass argument between clz and caller: a0, a1
    # a0: the upper 32-bit of the number to do CLZ
    # a1: the lower 32-bit of the number to do CLZ
    # t0: shifted x
    # t1: flag to decide upper is zero or not
    # t2: mask
    # output clz
    
    # we can skip upper padding if upper word is zero
    # we can skip lower padding if upper word isn't zero
    add t0, x0, x0
    add t1, x0, x0
    beq a0, x0, PAD_LOWER

PAD_UPPER:
    # padding words
    srli t0, a0, 1
    or a0, a0, t0
    srli t0, a0, 2
    or a0, a0, t0
    srli t0, a0, 4
    or a0, a0, t0
    srli t0, a0, 8
    or a0, a0, t0
    srli t0, a0, 16
    or a0, a0, t0
    j POPCNT    # skip PAD_LOWER

PAD_LOWER:
    addi t1, x0, 1    # set flag t1 = 1
    srli t0, a1, 1
    or a1, a1, t0
    srli t0, a1, 2
    or a1, a1, t0
    srli t0, a1, 4
    or a1, a1, t0
    srli t0, a1, 8
    or a1, a1, t0
    srli t0, a1, 16
    or a0, a1, t0

POPCNT:
    # x -= ((x >> 1) & 0x55555555)
    lw t2, mask1
    srli t0, a0, 1
    and t0, t0, t2
    sub a0, a0, t0
    # x = ((x >> 2) & 0x33333333) + (x & 0x33333333)
    lw t2, mask2
    srli t0, a0, 2
    and t0, t0, t2
    and a0, a0, t2
    add a0, a0, t0
    # x = ((x >> 4) + x) & 0x0f0f0f0f
    lw t2, mask4
    srli t0, a0, 4
    add a0, a0, t0
    and a0, a0, t2
    # x += (x >> 8)
    srli t0, a0, 8
    add a0, a0, t0
    # x += (x >> 16)
    srli t0, a0, 16
    add a0, a0, t0
    # (x & 0x3f)
    andi a0, a0, 0x3f
    bne t1, x0, POPCNT_LOWER
    # 32 - (x & 0x3f)
    li t0, 32
    sub a0, t0, a0
    j EXIT_CLZ

POPCNT_LOWER:
    # 64 - (x & 0x3f)
    li t0, 64
    sub a0, t0, a0
    j EXIT_CLZ

EXIT_CLZ:
    ret
