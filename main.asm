# MIPS code to reverse a string
.data
input_buffer:   .space 1024
output_buffer:  .space 1024
reverse_stack:  .space 1024

.text
.globl main
main:
	addiu $v0, $zero, 8  # v0=8 equals string input for syscall
	la $a0, input_buffer # Where the input string will be stored at
	addiu $a1, $zero, 1024     # Maximum input length
	syscall		     # Make a syscall which will wait for an input string
	
	jal reverse_string   # Will be stored at v1
	
	# Preserve input word
	addiu $sp, $sp, -4
	sw $a0, 0($sp)
	
	addiu $v0, $zero, 4  # v0=4 equals string output for syscall
	addu $a0, $zero, $v1   # Reversed string as parameter for output syscall
	syscall
	
	# Restore input word
	lw $a0, 0($sp)
	addiu $sp, $sp, 4
	
	j exit
	
reverse_string:
	# Save input word on stack to preserve it
	addiu $sp, $sp, -8
	sw $a0, 4($sp)
	
	# Initialize output buffer
	la $v1, output_buffer
	sw $v1, 0($sp)       # Preserve beginning of the output buffer
	
	# Initialize reverse stack
	la $t0, reverse_stack
	addiu $t0, $t0, 1024
	addu $t1, $zero, $t0 # Beginning of the stack
	
	# ASCII LF-char
	addiu $t3, $zero, 10
		
stack_loop:	
	lb $t2, 0($a0)
	# If the end of the string was reached, unstack the reverse stack
	beqz $t2, unstack_loop
	beq $t2, $t3, unstack_loop
			
	addiu $t0, $t0, -1   # Make space on the reverse stack
	sb $t2, 0($t0)       # Store byte on the reverse stack
	
	addiu $a0, $a0, 1    # Increment input word
	j stack_loop
	
unstack_loop:
	beq $t0, $t1, finish # If  stack is at the beginning again, finish
	# Put current byte at reverse stack on outpuf buffer
	lb $t2, 0($t0)
	sb $t2, 0($v1)
	# Increment outpuf buffer and reverse stack
	addiu $t0, $t0, 1
	addiu $v1, $v1, 1
	j unstack_loop
	
finish:
	# Restore input word and beginning of the output buffer
	lw $v1, 0($sp)
	lw $a0, 4($sp)
	addiu $sp, $sp, 8
	jr $ra
	
exit: