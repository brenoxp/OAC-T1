.eqv VGA 0xFF000000
.eqv TAMX 320
.eqv TAMY 240
.eqv H_TAMX 160
.eqv H_TAMY 120
.eqv OPCAO1 1
.eqv OPCAO2 2
.eqv OPCAO3 3
.eqv OPCAO4 4
.eqv OPCAO5 5

.data
	
	INF:     .float -160.0
	SUP:     .float  160.0
	UM:      .float  1.0
	UMCINCO: .float  1.5
	Z5: 	.float 0.5
	ZERO: .float 0.0
	DOIS: .float 2.0
	VINTE: .float 20.0
	CINC3: .float 53.3
	DSEIS:   .float 16.0
	SCENTA: .float 60.0
	OITENTA: .float 80.0
	QUARENTA: .float 40.0
	MENU:	 .asciiz "O que deseja realizar?\n1 - F(x) = -x\n2 - F(x)= x^2 + 1\n3 - F(x) = sqrt(x)\n4 - F(x) = (x+1)^2*(x-1)/(x-1.5)\n5 - Símbolo do Batman\n" 
	PLOT1:   .asciiz "Informe o limite inferior.\n"
	PLOT2:   .asciiz "Informe o limite superior.\n"
	
.text
MAIN:
	
	# Primeiro plota os eixos
	jal P_EIXOS
	
	# Imprimindo o menu 
	li $v0, 4
	la $a0, MENU
	syscall
	
	# Le opcao do usuario
	li $v0, 5
	syscall
	
	move $a0,$v0
	# Retorna ponteiro para a funcao que usario escolheu $v0 = (funcao escolhida)
	jal CHOOSE_FUNC
	
	move $a2, $v0
	jal PLOT
	
	
	li $v0, 10
	syscall

# $a0 lim inferior
# $a1 lim superior
# $a2 Função
PLOT: 
	move $a0, $ra
	jal PUSH_STACK

	lwc1 $f0, INF
	lwc1 $f1, SUP
	l.s $f10, UM

B_PLOT:
	jalr $a2 # valor da funcao em $f12

	jal FLOAT_TO_INT	# Valor em $v0, Y
	move $a1, $v0
	
	mov.s $f12, $f0
	jal FLOAT_TO_INT
	move $a0, $v0
	
	jal PLOTPIXEL
	
	add.s $f0, $f0, $f10
	c.le.s $f1, $f0 # $f1 = lsup , $f0 = x, lsup < x (FLAG = 1) 
	bc1f B_PLOT # (FLAG = 0) 
	

	jal POP_STACK
	jr $v0

# Recebe no $f12 retorna no $v0
FLOAT_TO_INT:
	cvt.w.s $f12, $f12
	mfc1 $v0, $f12
	jr $ra
	
CHOOSE_FUNC:
    	beq $a0,OPCAO1,L_A
    	beq $a0,OPCAO2,L_B
    	beq $a0,OPCAO3,L_C
    	beq $a0,OPCAO4,L_D
    
L_A:    la $v0,FUNCAO_A
    	jr $ra
    
L_B:    la $v0,FUNCAO_B
    	jr $ra
    
L_C:    la $v0,FUNCAO_C
    	jr $ra
    
L_D:    la $v0,FUNCAO_D
    	jr $ra

# DADO O LINF E LSUP, TEMOS QUE PASSAR TODOS OS ELEMENTOS NESTE INTERVALO
# PARA A FUNCAO E CALCULAR O SEU VALOR Y
# -x
FUNCAO_A:
	
    	neg.s $f12, $f0
    	jr $ra

# x^2 + 1 
FUNCAO_B:   
	l.s $f8, OITENTA
    	l.s $f7,UM
    	l.s $f9, VINTE
    	div.s $f12, $f0, $f8
    	mul.s $f12,$f12,$f12
    	add.s $f12,$f12,$f7
    	mul.s $f12, $f12, $f9
    	jr $ra

# sqrt(x) 
FUNCAO_C:
	l.s $f8, DSEIS
	div.s $f11, $f0, $f8
    	sqrt.s $f12, $f11
    	mul.s $f12, $f12, $f8
    	jr $ra

# (x+1)^2*(x-1)*(x-2)/(x-1.5)
FUNCAO_D:
    	l.s $f7, UM
    	l.s $f2, SUP
    	l.s $f3, UMCINCO
    	l.s $f9, CINC3
    	l.s $f27, DOIS 
 	l.s $f31, Z5
 	l.s $f30, ZERO
 	l.s $f29, VINTE
    	div.s $f11, $f0, $f9 
    	
    	#funcao 
    	#r = 0 + 2
    	add.s $f23, $f30, $f27
    	# r = r + x
    	add.s $f23, $f23, $f11
    	# x^2
    	mul.s $f24, $f11, $f11
    	# 3x^2
    	add.s $f28, $f27, $f7
    	mul.s $f28, $f28, $f24
    	# r = r - 3x^2
    	sub.s $f23, $f23, $f28
    	# x^3
    	mul.s $f24, $f11, $f24
    	# r = r - x^3
    	sub.s $f23, $f23, $f24
    	# x^4
    	mul.s $f24, $f11, $f24
    	# r = r + x^4	
    	add.s $f23, $f24, $f23
    	# x - 1/2 
    	sub.s $f3, $f11, $f3
    	# r = r / x - 1/2
    	div.s $f23, $f23, $f3
    	
    	mov.s $f12, $f23
    	mul.s $f12, $f12, $f29
    	jr $ra
	
	
	
# ------ INICIO PRINT EIXOS ------
P_EIXOS:
	move $a0, $ra
	jal PUSH_STACK
	
	jal P_X
	jal P_Y
	
	jal POP_STACK
	jr $v0
# ------  FIM PRINT EIXOS ------

# ------ INICIO PRINT EIXO X ------
P_X:	# Imprime x de -TAM_X até +
	move $a0, $ra
	jal PUSH_STACK
	
	li $a0, H_TAMX
	neg $a0, $a0
	li $a1, 0
	
BACK_X: jal PLOTPIXEL
	addi $a0, $a0, 1
	blt $a0, H_TAMX, BACK_X
	
	jal POP_STACK
	jr $v0
# ------  FIM PRINT EIXO X ------

# ------ INICIO PRINT EIXO Y ------
P_Y:	
	move $a0, $ra
	jal PUSH_STACK
	
	li $a0, 0
	li $a1, H_TAMY
	neg $a1, $a1
	
BACK_Y: jal PLOTPIXEL
	addi $a1, $a1, 1
	blt $a1, H_TAMY, BACK_Y
	
	jal POP_STACK
	jr $v0
# ------  FIM PRINT EIXO Y ------
	

	
# "FUNÇAO" PLOTA: RECEBE X E Y, CALCULA O ENDEREÇO DO PIXEL E COLOCA NA TELA
PLOTPIXEL:
	la $t0, VGA
	li $t1, TAMX
	li $t5, 0x00  # cor 0b11000000

	move $t2, $a0  # X = $a0
	move $t3, $a1  # Y = $a1
	neg $t3, $t3
	
	addi $t3,$t3,H_TAMY
	
	mul $t3,$t1,$t3   # Y*320
	
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3,H_TAMX

	# --- Inicio verifica se esta fora da área do display
	bge $t3, $zero CONT1
	jr $ra
CONT1:
	li $t4, 768000	# Quantidade de pixels no display
	ble $t3, $t4, CONT2
	jr $ra
CONT2:
	# --- Fim verifica se esta fora da área do display

	add $t3,$t3,$t0   # Endereco
	
	sb $t5, 0($t3)	  # plota o pixel na tela

	jr $ra
	

# Coloca $a0 na pilha
PUSH_STACK:
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jr $ra
	
# Retorna topo da pilha em $v0
POP_STACK:
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
