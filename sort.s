.eqv N 10

.data
vetor:  .word 5,8,3,4,7,6,8,0,1,9
newl:	.asciiz "\n"
tab:	.asciiz "\t"


.text	
MAIN:	la $a0,vetor
	li $a1,N
	jal show #printa o vetor

	la $a0,vetor
	li $a1,N
	jal sort #chama o SORT

	la $a0,vetor #printa o vetor ordenado
	li $a1,N
	jal show

	li $v0,10 #tchau
	syscall	


swap:	sll $t1,$a1,2
	add $t1,$a0,$t1
	lw $t0,0($t1)
	lw $t2,4($t1)
	sw $t2,0($t1)
	sw $t0,4($t1)
	jr $ra

sort:	addi $sp,$sp,-20 #aloca pillha
	sw $ra,16($sp)
	sw $s3,12($sp)
	sw $s2,8($sp)
	sw $s1,4($sp)
	sw $s0,0($sp) #guarda uns bagulho na pilha
	move $s2,$a0 #coloca o vetor em s2
	move $s3,$a1 #coloca o tamanho do vetor em s3
	move $s0,$zero #coloca zero em s0 
for1:	slt $t0,$s0,$s3 # s3 < 0 (tamanho do vetor é menor que 0?)
	beq $t0,$zero,exit1 #se sim vai pra exit 1
	addi $s1,$s0,-1
for2:	slti $t0,$s1,0
	bne $t0,$zero,exit2
	sll $t1,$s1,2
	add $t2,$s2,$t1
	lw $t3,0($t2)
	lw $t4,4($t2)
	slt $t0,$t4,$t3
	beq $t0,$zero,exit2
	move $a0,$s2
	move $a1,$s1
	jal swap
	addi $s1,$s1,-1
	j for2
exit2:	addi $s0,$s0,1
	j for1
exit1: 	lw $s0,0($sp)
	lw $s1,4($sp)
	lw $s2,8($sp)
	lw $s3,12($sp)
	lw $ra,16($sp) #restaura os valores dos registradores 
	addi $sp,$sp,20 #desaloca a pilha 
	jr $ra #volta pra main


show:	move $t0,$a0
	move $t1,$a1
	move $t2,$zero

loop1: 	beq $t2,$t1,fim1
	li $v0,1
	lw $a0,0($t0)
	syscall
	li $v0,4
	la $a0,tab
	syscall
	addi $t0,$t0,4
	addi $t2,$t2,1
	j loop1

fim1:	li $v0,4
	la $a0,newl
	syscall
	jr $ra
