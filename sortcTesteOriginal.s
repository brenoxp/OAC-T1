	.file	1 "sortc.c"		#Nos diz como começar um novo arquivo lógico, seguido de uma string por aspas. Caso seja arquivo em branco, deve-se fazer: ""
	.section .mdebug.abi32		#A instrução .section é usada para marcar bits de código com um nome de seção. É feita uma ligação com .mdebug.abi32, concatenando em uma área de memória e dizendo onde e em que ordem para colocá-lo no binário gerado pela ligação. 
	.previous			#Permite a troca da .section com .nan. Ajuda na manutenção de códigos densos, permite declarar dados dentro de uma troca.
	.nan	legacy			#Diz que o arquivo "sortc.c" utilizará o enconding original do MIPS
#	.module	fp=32			#Este módulo diz para que o código seja possível rodar em processadores de 32 bits. 
	.module	oddspreg		#Este outro módulo diz para representar registradores de precisão simples
	.globl	v			#Definição de uma variável global. Pode ser feito com funções também.
	.data				#Define que a partir deste ponto, serão definidos segmentos de dados.
	.align	2			#Permite reforçar o alinhamento do dado no endereço 2 da memória (Otimização).
#	.type	v, @object		#Seta o tipo da variável v como um sendo um objeto de dados.
	.size	v, 40			#Define o tamanho da variável v como sendo 40 bytes.

#Assume valores de 5,8,3,4,7,6,8,0,1,8 para a variável v, em que, cada valor deve ser declarado individualmente através da diretiva .word, que aloca e inicializa um espaço para uma variável. Em que os valores 5,8,3,... são valores que são definidos para a variável v.
v:
	.word	5 			#0x00000005 Define 5 e aloca um espaço para v
	.word	8 			#0x00000008 Define 8 e aloca um espaço para v
	.word	3 			#0x00000003 Define 3 e aloca um espaço para v
	.word	4 			#0x00000004 Define 4 e aloca um espaço para v
	.word	7 			#0x00000007 Define 7 e aloca um espaço para v
	.word	6 			#0x00000005 Define 6 e aloca um espaço para v
	.word	8 			#0x00000008 Define 8 e aloca um espaço para v
	.word	0 			#0x00000000 Define 0 e aloca um espaço para v
	.word	1 			#0x00000001 Define 1 e aloca um espaço para v
	.word	9 			#0x00000009 Define 9 e aloca um espaço para v
	.rdata				#Não indica o uso de dados, mas uma meta especificação para o sistema operacional. Define constantes de somente leitura. 
	.align	2			#Permite reforçar o alinhamento do dado no endereço 2 da memória (Otimização).
.LC0:					#Label
	.ascii	"%d\011\000"		#Define a string "%d\011\000" para LC0
	.text				#Define a partir de onde será feito o código
	.globl	show			#Define o label show como sendo do tipo global
	.set	nomips16		#Gera um código para não ser rodado em processadores mips 16 bits
	.set	nomicromips		#Coloca o assembly em microMIPS mode para um tamanho de 32 bits
	.ent	show			#Marca o começo da função show
#	.type	show, @function		#Define show como sendo do tipo função
	nop
	jal 	main
	nop
	li 	$v0, 10
	syscall
show:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, gp= 0. Define o formato da pilha de frame. $fp define o ponteiro como sendo o registrador $fp, 32 é o endereço de chamada na pilha (Canonical Frame Address, CFA) e $31 é o registrador de retorno.
	.mask	0xc0000000,-4		#Especifica o registrador a ser armazenado e onde será. 0xc0000000(Little endian) = 11000000 00000000 00000000 00000000. -4 é o deslocamento da fp. 
	.fmask	0x00000000,0		#Define o não uso de ponto flutuante.
	.set	noreorder		#Desabilita instrução de não ordenamento
	.set	nomacro			#Previne que o assembly traduza uma declaração em mais de uma instrução
	addiu	$sp,$sp,-32		#Soma -32 no ponteiro de pilha ($sp), ou seja, sp -= 32
	sw	$31,28($sp)		#Armazena o conteúdo de $ra no endereço sp+28
	sw	$fp,24($sp)		#Armazena o conteúdo de $fp no endereço sp+24
	move	$fp,$sp			#Define o valor de fp como sendo de sp, então fp = 32
	sw	$4,32($fp)		#Armazena o conteúdo de $a0 no endereço de 32+fp
	sw	$5,36($fp)		#Armazena o conteúdo de $a1 no endereço de 36+fp
	sw	$0,16($fp)		#Armazena o conteúdo de $zero no endereço de 16+fp
	b	.L2			#Pula para a label L2
	nop				#Breakpoint

.L3:
	lw	$2,16($fp)		#Armazena em $v0 o conteúdo de 16+fp
	sll	$2,$2,2			#Faz o shift de $v0 em 2 bits para a esquerda
	lw	$3,32($fp)		#Armazena em $v1 o valor de 32+fp
	addu	$2,$3,$2		#Soma $v1 e $v0, armazenando o valor em $v0
	lw	$2,0($2)		#Carrega em $v0 o valor do endereço de $v0
	move	$5,$2			#Armazena $a1 o valor de $v0
#	lui	$2,%hi(.LC0)
#	addiu	$4,$2,%lo(.LC0)
	la 	$4, .LC0($0)		#Armazena em $4 o label .LC0
#	jal	printf
	nop				#No Operation

	lw	$2,16($fp)		#Carrega o valor de 16+fp em $v0
	addiu	$2,$2,1			#Adiciona em $v0 o valor de $v0+1
	sw	$2,16($fp)		#Carrega o valor de $v0 no endereço 16+fp
.L2:
	lw	$3,16($fp)		#Armazena em $v1 o conteúdo de 16+fp
	lw	$2,36($fp)		#Armazena em $v0 o conteúdo de 36+fp
	slt	$2,$3,$2		#Se $v1 < $v0, então $v0 = 1, senão $v0 = 0
	bne	$2,$0,.L3		#Se $zero não for igual a $v0, ou seja, se o valor de v0 for diferente de 0, então pula para a label L3.
	nop				#Breakpoint

	li	$4,10			# 0xa, armazena 10 em $a0
#	jal	putchar
	nop				#Breakpoint

	nop				#Breakpoint
	move	$sp,$fp			#Armazena o valor de $fp em #sp
	lw	$31,28($sp)		#Carrega o valor de 28+sp em $ra
	lw	$fp,24($sp)		#Carrega o valor de 24+sp em $fp
	addiu	$sp,$sp,32		#Soma $sp + 32 em $sp
	jr	$31			#Jump para o valor de $ra, indicando o fim de função
	nop				#Breakpoint

	.set	macro
	.set	reorder			#Habilita a instrução de ordenamento
	.end	show			#Finaliza a label show
	.size	show, .-show		#Define o valor de show como sendo o valor negativo que ela ocupa, sendo 0, desalocando da memória
#	.align	2
	.globl	swap			#Define a label swap como global
	.set	nomips16
	.set	nomicromips
	.ent	swap			#Marca o começo da função swap
#	.type	swap, @function		#Define o tipo da função swap como sendo função
swap:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0 Define o formato da pilha de frame. $fp define o ponteiro como sendo o registrador $fp, 16 é o endereço de chamada na pilha e $31 é o registrador de retorno.
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder		#Desabilita instrução de não ordenamento
	.set	nomacro			#Previne que o assembly traduza uma declaração em mais de uma instrução
	addiu	$sp,$sp,-16		#Define $sp com o valor de $sp-16
	sw	$fp,12($sp)		#Carrega o valor do registrador $fp para 12+$sp
	move	$fp,$sp			#Define o valor de $fp como sendo $sp
	sw	$4,16($fp)		#Carrega o valor do registrador $a0 para 16+fp
	sw	$5,20($fp)		#Carrega o valor do registrador $a1 para 20+fp
	lw	$2,20($fp)		#Armazena em $v0 o conteúdo de 20+$fp
	sll	$2,$2,2			#Faz o shift de $v0 em 2 bits para a esquerda
	lw	$3,16($fp)		#Armazena em $v1 o conteúdo de 16+$fp
	addu	$2,$3,$2		#Adiciona o conteúdo de $v0 e $v1 em $v0.
	lw	$2,0($2)		#Armazena em $v0 o conteúdo de 0+$v0
	sw	$2,0($fp)		#Carrega o valor do registrador $v0 para 0+fp
	lw	$2,20($fp)		#Armazena em $v0 o conteúdo de 20+$fp
	sll	$2,$2,2			#Faz o shift de $v0 em 2 bits para a esquerda
	lw	$3,16($fp)		#Armazena em $v1 o conteúdo de 16+$fp
	addu	$2,$3,$2		#Adiciona o conteúdo de $v0 e $v1 em $v0.
	lw	$3,20($fp)		#Armazena em $v1 o conteúdo de 20+$fp
	addiu	$3,$3,1			#Define $v1 com o valor de $v1+1
	sll	$3,$3,2			#Faz o shift de $v1 em 2 bits para a esquerda
	lw	$4,16($fp)		#Armazena em $a0 o conteúdo de 16+$fp
	addu	$3,$4,$3		#Adiciona o conteúdo de $v1 e $a0 em $v1
	lw	$3,0($3)		#Armazena em $v1 o conteúdo de 0+$v1
	sw	$3,0($2)		#Carrega o valor do registrador $v1 para 0+$v0
	lw	$2,20($fp)		#Armazena em $v0 o conteúdo de 20+$fp
	addiu	$2,$2,1			#Define $v0 com o valor de $v0+1
	sll	$2,$2,2			#Faz o shift de $v1 em 2 bits para a esquerda
	lw	$3,16($fp)		#Armazena em $v1 o conteúdo de 16+$fp
	addu	$2,$3,$2		#Adiciona o conteúdo de $v0 e $v1 em $v0
	lw	$3,0($fp)		#Armazena em $v1 o conteúdo de 0+$fp
	sw	$3,0($2)		#Carrega o valor do registrador $v1 para 0+$v0
	nop				#Breakpoint
	move	$sp,$fp			#Armazena o valor de $fp em $sp
	lw	$fp,12($sp)		#Armazena em $fp o conteúdo de 12+$sp
	addiu	$sp,$sp,16		#Define $sp com o valor de $sp+16
	jr	$31			#Pula para o valor armazenado em $ra
	nop				#Breakpoint

	.set	macro
	.set	reorder
	.end	swap			#Finaliza a label swap
	.size	swap, .-swap		#Define o valor de swap como sendo o valor negativo que ela ocupa, sendo 0, desalocando da memória
#	.align	2
	.globl	sort			#Define a label sort como global
	.set	nomips16
	.set	nomicromips
	.ent	sort			#Marca o começo da função sort
#	.type	sort, @function		#Define o tipo da função sort como sendo função
sort:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, gp= 0 Define o formato da pilha de frame. $fp define o ponteiro como sendo o registrador $fp, 32 é o endereço de chamada na pilha e $31 é o registrador de retorno.
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32		#Adiciona em $sp o valor de $sp+32
	sw	$31,28($sp)		#Carrega o valor do registrador $ra para 28+$sp, indicando o fim da função
	sw	$fp,24($sp)		#Carrega o valor do registrador $fp para 24+$sp
	move	$fp,$sp			#Muda o valor de $fp para $sp
	sw	$4,32($fp)		#Carrega o valor do registrador $a0 para 32+$fp
	sw	$5,36($fp)		#Carrega o valor do registrador $a1 para 36+$fp
	sw	$0,16($fp)		#Carrega o valor do registrador $zero para 16+$fp
	b	.L6			#Pula para a label L6 para começar o sort
	nop				#Breakpoint

.L10:
	lw	$2,16($fp)
	addiu	$2,$2,-1
	sw	$2,20($fp)
	b	.L7
	nop

.L9:
	lw	$5,20($fp)
	lw	$4,32($fp)
	jal	swap
	nop

	lw	$2,20($fp)
	addiu	$2,$2,-1
	sw	$2,20($fp)
.L7:
	lw	$2,20($fp)
	bltz	$2,.L8
	nop

	lw	$2,20($fp)
	sll	$2,$2,2
	lw	$3,32($fp)
	addu	$2,$3,$2
	lw	$3,0($2)
	lw	$2,20($fp)
	addiu	$2,$2,1
	sll	$2,$2,2
	lw	$4,32($fp)
	addu	$2,$4,$2
	lw	$2,0($2)
	slt	$2,$2,$3
	bne	$2,$0,.L9
	nop

.L8:
	lw	$2,16($fp)
	addiu	$2,$2,1
	sw	$2,16($fp)
.L6:
	lw	$3,16($fp)
	lw	$2,36($fp)
	slt	$2,$3,$2
	bne	$2,$0,.L10
	nop

	nop
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	sort			#Finaliza a label sort
	.size	sort, .-sort		#Define o valor de sort como sendo o valor negativo que ela ocupa, sendo 0, desalocando da memória
#	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main			#Marca o começo da função main
#	.type	main, @function		#Define o tipo da função main como sendo função
main:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0 Define o formato da pilha de frame. $fp define o ponteiro como sendo o registrador $fp, 24 é o endereço de chamada na pilha e $31 é o registrador de retorno.
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	li	$5,10			#0xa $a1 = 10
#	lui	$2,%hi(v)
#	addiu	$4,$2,%lo(v)
	la 	$4, v($zero)
	jal	show			#Pula para a função show, com os valores de $a1 = 10, $v0 = v e $a0 = $v0+v
	nop				#Breakpoint

	li	$5,10			#0xa $a1 = 10
#	lui	$2,%hi(v)
#	addiu	$4,$2,%lo(v)
	la 	$4, v($zero)
	jal	sort			#Chama a função sort
	nop				#Breakpoint

	li	$5,10			#0xa $a1 = 10
#	lui	$2,%hi(v)
#	addiu	$4,$2,%lo(v)
	la 	$4, v($zero)
	jal	show			#Chama a função show
	nop				#Breakpoint

	nop				#Breakpoint
	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	main			#Finaliza a função main
	.size	main, .-main		#Define o valor de sort como sendo o valor negativo que ela ocupa, sendo 0, desalocando da memória
	.ident	"GCC: (Sourcery CodeBench Lite 2016.05-7) 5.3.0"
