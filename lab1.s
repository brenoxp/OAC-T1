.eqv VGA 0xFF000000
.eqv NUMX 320
.eqv NUMY 240
.eqv OPCAO1 1
.eqv OPCAO2 2
.eqv OPCAO3 3
.eqv OPCAO4 4
.eqv OPCAO5 5


.data

	INF:   .float -2.0
	SUP:   .float 2.0
	UM:    .float 1.0
	MENU:	.asciiz "O que deseja realizar?\n1 - F(x) = -x\n2 - F(x)= x^2 + 1\n3 - F(x) = sqrt(x)\n4 - F(x) = (x+1)^2*(x-1)/(x-1.5)\n5 - Símbolo do Batman\n" 
	PLOT1: .asciiz "Informe o limite inferior.\n"
	PLOT2: .asciiz "Informe o limite superior.\n"
	
.text

MAIN:	
	
	# Imprimindo o menu 
	li $v0, 4
	la $a0, MENU
	syscall
	
	# Lendo a resposta
	li $v0, 5
	syscall
	
	# INICIALIZANDO A TELA VGA
	la $t0, VGA
	li $t1, NUMX
	li $t5,0x55  # cor 0b11000000
	
	# Primeiro plota os eixos
	jal EIXOS
	
	# Redirecionando
	beq $v0, OPCAO1, A
	beq $v0, OPCAO2, B
	beq $v0, OPCAO3, C
	beq $v0, OPCAO4, D
	beq $v0, OPCAO5, E
	
	# Usuário inseriu um número diferente do esperado
	j FIM


A:

	jal PLOT
	# limite inferior = $f3, limite superior = $f4 
	# calculando um valor que esteja no intervalo
	jal INTERVALOCALC 
	
	# INTERVALOCALC devolve um $f0 no intervalo
	jal FUNCAOA
	
	# Ja temos o y = $f12 e o x = $f0
	jal PLOTPIXELFLOAT
	
	# testamos se ja acabou, caso contrario continua
	bne $t9, $zero, FIM
	
	j A
	
B:
	jal PLOT
	# limite inferior = $f3, limite superior = $f4 
	# calculando um valor que esteja no intervalo
	jal INTERVALOCALC 
	
	# INTERVALOCALC devolve um $f0 no intervalo
	jal FUNCAOB
	
	# Ja temos o y = $f12 e o x = $f0
	jal PLOTPIXELFLOAT
	
	# testamos se ja acabou, caso contrario continua
	bne $t9, $zero, FIM
	
	j B
	
C:
	jal PLOT
	# limite inferior = $f3, limite superior = $f4 
	# calculando um valor que esteja no intervalo
	jal INTERVALOCALC 
	
	# INTERVALOCALC devolve um $f0 no intervalo
	jal FUNCAOC
	
	# Ja temos o y = $f12 e o x = $f0
	jal PLOTPIXELFLOAT
	
	# testamos se ja acabou, caso contrario continua
	bne $t9, $zero, FIM
	
	j C
	
D:
	jal PLOT
	# limite inferior = $f3, limite superior = $f4 
	# calculando um valor que esteja no intervalo
	jal INTERVALOCALC 
	
	# INTERVALOCALC devolve um $f0 no intervalo
	jal FUNCAOD
	
	# Ja temos o y = $f12 e o x = $f0
	jal PLOTPIXELFLOAT
	
	# testamos se ja acabou, caso contrario continua
	bne $t9, $zero, FIM
	
	j D
	
E:
	

# DADO O LINF E LSUP, TEMOS QUE PASSAR TODOS OS ELEMENTOS NESTE INTERVALO
# PARA A FUNCAO E CALCULAR O SEU VALOR Y
# -x
FUNCAOA:

# x^2 + 1 
FUNCAOB:	

	l.s $f1,UM
	mul.s $f12,$f0,$f0
	add.s $f12,$f12,$f1
	jr $ra	

# sqrt(x) 
FUNCAOC:

# (x+1)^2*(x-1)*(x-2)/(x-1.5)
FUNCAOD:
	

PLOT:  
	
	l.s $f1,UM
	# Lê o limite inferior
	li $v0, 4
	la $a0, PLOT1
	syscall
	
	li $v0, 6
	syscall

	# f3 = f0
	add.s $f3, $f0, $f0 
	
	# Lê o limite superior
	li $v0, 4
	la $a0 PLOT2
	syscall

	li $v0, 6 
	syscall 
	
	# f4 = f0
	add.s $f4, $f0, $f0 
	
	# flag de inicio
	addi $t9, $zero, 0
	
	jr $ra
	
INTERVALOCALC:
	
	mov.s $f5, $f3
	
	c.eq.s 1, $f5,  $f3	
	bc1t 1, LINF
	
	c.le.s 1, $f5, $f4
	bc1t 1, LSUP
	
	add.s $f5, $f5, $f1
	mov.s $f0, $f5
	
	j FIM
	
# CHEGOU NO LIMITE INFERIOR
LINF: 
	mov.s $f0, $f3
	jr $ra
	
# CHEGOU NO LIMITE SUPERIOR
LSUP:

	mov.s $f0, $f4
	# flag que acabou
	addi $t9, $zero, 1
	
	jr $ra
	
# "FUNÇAO" PLOTA: RECEBE X E Y EM PONTO FLUTUANTE, CALCULA O ENDEREÇO DO PIXEL EM INT E COLOCA NA TELA	
PLOTPIXELFLOAT:
	
	
	floor.w.s $f0, $f0
	floor.w.s $f12, $f12 
	
	li $v0, 2
	syscall
	j FIM 
	
	mfc1 $a0, $f0
	mfc1 $a1, $f12
	
	move $t2, $a0
	move $t3, $a1
	
	mul $t3,$t1,$t3   # Y*320
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3,$t0   # Endereco
	
	sb $t5, 0($t3)	  # plota o pixel na tela
	
	jr $ra
	
# "FUNÇAO" PLOTA: RECEBE X E Y, CALCULA O ENDEREÇO DO PIXEL E COLOCA NA TELA
PLOTPIXEL: 

	move $t2, $a0  # X = $a0
	move $t3, $a1  # Y = $a1
	
	mul $t3,$t1,$t3   # Y*320
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3,$t0   # Endereco
	
	sb $t5, 0($t3)	  # plota o pixel na tela
	
	jr $ra
	
# PLOTA O EIXO X: VAI DO PIXEL (0,119) -> (319, 119) 
EIXOS: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $t6, $zero, 319 
	addi $t7, $zero, 119 
	
	addi $a0, $zero, 0
	add $a1, $zero, $t7
	j EIXOXPLOT
	
EIXOXPLOT: 

	beq $a0, $t6, EIXOY
	jal PLOTPIXEL
	addi $a0, $a0, 1
	j EIXOXPLOT

# PLOTA O EIXO Y: VAI DO PIXEL (159, 0) -> (159, 239) 
EIXOY: 
	addi $t6, $zero, 159
	addi $t7, $zero, 239
	
	add $a0, $zero, $t6  
	addi $a1, $zero, 0 
	j EIXOYPLOT

EIXOYPLOT:
	
	beq $a1, $t7, VOLTA
	jal PLOTPIXEL
	addi $a1, $a1, 1
	j EIXOYPLOT

VOLTA: 
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


# ENCERRA O PROGRAMA	
FIM:

	li $v0, 10
	syscall
	
