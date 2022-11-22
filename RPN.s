//Author: Spence Johnston
//Project: Reverse Polish notation calculator
//Purpose: show how to push and pop from the stack with a calculator function.

#include <xc.h>
// Use PIC32MX460F512L

// can use C-like macro define statements
// #define statements follow here
.macro push reg     // define a parameter
   addiu    sp,	sp, -4	  // add a word of space to stack    
   sw	    \reg,   0(sp) // save \reg value to stack(text substitution)
.endm
   
.macro pop  reg
   lw	    \reg, 0(sp) //recover item from stack
   sw	    zero, 0(sp) //safely erase item on stack
   addiu    sp, sp, 4 //remove a word of space from stack
.endm
   
.macro loadv reg, label
   la	\reg, \label
   lw	\reg, 0(\reg)
.endm
   
.global main

.data
// data segment for READ/WRITE data follows here
// stored in volatile RAM memory
EXPR: .word 3,4, 0x80000000 + '*',5,6, 0x80000000 + '-', 0x80000000 + '+', 0x80000000 + '='
	
RESULT: .word 0
 
.text
.set noreorder
// text segment for instructions and CONSTANT READ-ONLY data follows here
// stored in non-volatile flash memory

.ent main
main:

    loadv s0, MULT_OP
    loadv s1, ADD_OP
    loadv s2, SUB_OP
    loadv s3, EQU_OP
    
    la	t0, EXPR
    
start_main:
   
   lw t4, 0(t0)
   beq t4, s0, do_mult 
   nop
   beq t4, s1, do_add 
   nop
   beq t4, s2, do_sub 
   nop
   beq t4, s3, do_equ 
   nop
   
   
   push t4 
   j post_op
   nop
   
   do_add:
    pop t1
    pop t2
    
    add t3, t1, t2
    push t3
    
    j post_op
    nop
    
   do_sub:
    pop t2
    pop t1
    
    sub t3, t1, t2
    push t3
    
    j post_op
    nop

   do_mult:
    pop a1
    pop a2
    jal multiply
    nop
    push v1
    j post_op
    nop

   do_equ:
    //pop the last numb and store in result address
    pop t1
    la a0, RESULT
    sw t1, 0(a0)
    j stop_main
    nop

   post_op:
    addiu t0, t0, 4
    j start_main
    nop
    
   stop_main:    
   endless:
    j endless
    nop
    
    multiply:
    add v1, $0, $0
    beqz a1, end_mult
    nop
    
    start_mult:
    beqz a2, end_mult
    nop
    add v1, v1, a1
    addi a2, a2, -1
    j start_mult
    nop
    end_mult:
    jr ra
    nop
    
.end main

		// constants go here
MULT_OP:  .word 0x80000000 + '*'
ADD_OP:	    .word 0x80000000 + '+'
SUB_OP:  .word 0x80000000 + '-'
EQU_OP:	    .word 0x80000000 + '='