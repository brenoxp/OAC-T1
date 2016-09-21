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
	MENU:	.asciiz "O que deseja realizar?\n0 - Plotar gráficos\n1 - F(x) = -x\n2 - F(x)= x^2 + 1\n3 - F(x) = sqrt(x)\n4 - F(x) = (x+1)^2*(x-1)/(x-1.5)\n5 - Símbolo do Batman\n" 
	PLOT1: .asciiz "Informe o limite inferior.\n"
	PLOT2: .asciiz "Informe o limite superior.\n"
.text

MAIN:	
	
	# Imprimindo o menu 
	li $v0, 4
	la $a0, MENU
	syscall
	
	# Inicializando o quadro
	la $t0, VGA
	li $t1, NUMX
	
	# Lendo a resposta
	li $v0, 5
	syscall
	
	# Redirecionando
	beq $v0, $zero, PLOT
	beq $v0, OPCAO1, A
	beq $v0, OPCAO2, B
	beq $v0, OPCAO3, C
	beq $v0, OPCAO4, D
	beq $v0, OPCAO5, E
	
	# O número escolhido não faz parte do menu, encerra a execução
	j FIM

# Termina a execução
FIM:
	
	li $v0, 10
	syscall 
	
# Escolheu plotar 
PLOT:
	
	jal EIXOS
	
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

	j FUNCAO

# Escolheu a) F(x) = -x 	
A:
	jal EIXOS
	j AGRAF
	
# Escolheu b) F(x)= x^2 + 1 
B:
	jal EIXOS

# Escolheu c) F(x) = sqrt(x)
C:
	jal EIXOS

# Escolheu d) F(x) = (x+1)^2*(x-1)/(x-1.5)
D:
	jal EIXOS

# Escolheu e) Símbolo do Batman
E:
AGRAF: 
	
	j LIMITES
	
LIMITES:
	
	li $t2, 0
	li $t3, 119
	li $t5, 0x0b
	
	mul $t3,$t1,$t3   # Y*320
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3,$t0   # Endereco
	
	j LIMITEX
	
LIMITEX:
	
	addi $t7, $zero, 0
	sb $t5, 0($t3) 
	sb $t5, 319($t3) 
	j LIMITEXPLOT

LIMITEXPLOT:
	
	beq $t7, $t6, LIMITEY
	addi $t3, $t3, 16
	addi $t7, $t7, 16
	sb $t5, 0 ($t3)
	j LIMITEXPLOT

LIMITEY:

	li $t2, 160  # X
	li $t3, 0 # Y
	li $t5,0x1b  # cor 0b11000000
	
	mul $t3,$t1,$t3   # Y*320
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3,$t0   # Endereco
	
	addi $t9, $zero, 1
	addi $t8, $zero, 240
	sb $t5, 0($t3)
	j LIMITEYPLOT
	
LIMITEYPLOT:
	
	beq $t9, $t8, FIM
	addi $t9, $t9, 1
	addi $t3, $t3, 320
	sb $t5, 0($t3)
	j LIMITEYPLOT
	
CURVA:

EIXOS:
	
	li $t2,0  # X
	li $t3,120  # Y
	li $t5,0x00  # cor 0b11000000
	
	
	addi $t7, $t7, 1
	addi $t6, $t6, 320
	
	mul $t3,$t1,$t3   # Y*320
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3,$t0   # Endereco
	
	sb $t5, 0($t3)	  # plota o pixel na tela
	
	j EIXOXPLOT

EIXOXPLOT:
	
	beq $t7, $t6, EIXOY
	addi $t3, $t3, 1
	addi $t7, $t7, 1
	sb $t5, 0($t3)
	j EIXOXPLOT

EIXOY:
	
	li $t2,160  # X
	li $t3,0 # Y
	li $t5,0x00  # cor 0b11000000
	
	addi $t9, $t9, 1
	addi $t8, $t8, 1024
	
	mul $t3,$t1,$t3   # Y*320
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3,$t0   # Endereco
	
	sb $t5, 0($t3)	  # plota o pixel na tela
	
	j EIXOYPLOT

EIXOYPLOT:

	beq $t9, $t8, RETORNO
	addi $t3, $t3, 320
	addi $t9, $t9, 1
	sb $t5, 0($t3)
	j EIXOYPLOT

RETORNO:
	jr $ra

					
FUNCAO:	# letra b)
	l.s $f1,UM
	mul.s $f12,$f0,$f0
	add.s $f12,$f12,$f1
	j FIM	
	
