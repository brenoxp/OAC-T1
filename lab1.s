# LAB.1 OAC - 2016/2 - 3) Plotador de Gráficos no Mars
#------------------------------------------------------
# GRUPO: PAULO VICTOR GONÇALVES FARIAS - 13/0144754
#	 BRENO XAVIER - 
#	 MIGUEL ANGELO MONTAGNER - 
#	JEFFERSON
#	RAFAEL 
# 
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

	SUP_A:  .float  160.0
	SUP_B:  .float 80.0
	SUP_C:	.float 16.0
	SUP_D: .float 53.333333
	SUP_E: .float 40.0
	CONST1: .float 0.0912372213
	UM:      .float  1.0
	UMCINCO: .float  1.5
	VINTE: .float 20.0
	
	MENU:	 .asciiz "O que deseja realizar?\n1 - F(x) = -x\n2 - F(x)= x^2 + 1\n3 - F(x) = sqrt(x)\n4 - F(x) = (x+1)^2*(x-1)/(x-1.5)\n5 - Símbolo do Batman\n" 
	PLOT1:   .asciiz "Informe o limite inferior.\n"
	PLOT2:   .asciiz "Informe o limite superior.\n"
	
.text
# ------  INÍCIO DA MAIN ------
MAIN:
	
	# Inicializa a tela
	la $t0, VGA
	li $t1, TAMX
	li $t5, 0x00  # cor 0x00000000

	# Imprimindo o menu 
	li $v0, 4
	la $a0, MENU
	syscall
	
	# Le opção do usuario
	li $v0, 5
	syscall
	
	# $a0 = opçao escolhida
	move $a0,$v0
	
	# Retorna ponteiro para a funcao que usario escolheu $v0 = (funcao escolhida)
	jal CHOOSE_FUNC
	move $s0, $v0 # $s0 = ponteiro pra funçao escolhida
	jal P_EIXOS # plota os eixos (x,y)
	
	# Lê o limite inferior e o superior
	# $f0 = linf
	# $f1 = lsup
	jal INTERVALO
	
	# Plota os valores de acordo com a função escolhida
	# $f0 = linf
	# $f1 = lsup
	jal PLOT

FIM: 
	# Encerra o programa
	li $v0, 10
	syscall
	
# ------  FIM DA MAIN ------


# ------  INÍCIO DA CHOOSE_FUNC ------
# Checa qual a função escolhida e redireciona
CHOOSE_FUNC:
    	beq $a0,OPCAO1,L_A
    	beq $a0,OPCAO2,L_B
    	beq $a0,OPCAO3,L_C
    	beq $a0,OPCAO4,L_D
    	beq $a0, OPCAO5, L_BATMAN

# Usuário escolheu a função A, carrega o ponteiro e o limite de proporção
L_A:    la $v0,FUNCAO_A
	l.s $f30, SUP_A
    	jr $ra

 # Usuário escolheu a função B, carrega o ponteiro e o limite de proporção  
L_B:    la $v0,FUNCAO_B
	l.s $f30, SUP_B
    	jr $ra

# Usuário escolheu a função C, carrega o ponteiro e o limite de proporção
L_C:    la $v0,FUNCAO_C
	l.s $f30, SUP_C
    	jr $ra

# Usuário escolheu a função D, carrega o ponteiro e o limite de proporção
L_D:    la $v0,FUNCAO_D
	l.s $f30, SUP_D
    	jr $ra

# Usuário escolheu imprimir o símbolo do batman
L_BATMAN:
	la $v0, BATMAN_GX
	l.s $f30, SUP_D
	jr $ra # vai para a funçao batman

# ------  FIM DA CHOOSE_FUNC ------


# ------  INÍCIO INTERVALO ------
# Recebe um limite inferior e superior do usuário
# salva cada um respectivamente nos registradores $f0 e $f1
INTERVALO:  

	# Lê o limite inferior
	li $v0, 4
	la $a0, PLOT1
	syscall
	li $v0, 6
	syscall
	mov.s $f1, $f0
	
	# Lê o limite superior
	li $v0, 4
	la $a0 PLOT2
	syscall
	li $v0, 6 
	syscall 
	mov.s $f2, $f0 
	
	# $f0 = linf, $f1 = lsup
	mov.s $f0, $f1
	mov.s $f1, $f2
	
	jr $ra
	
# ------  FIM INTERVALO ------


# ------  INÍCIO PLOT ------
# Funcao plot recebe uma funçao, seus limites, o limite de 
# proporçao e as desenha na tela
# $f0 lim inferior
# $f1 lim superior
# $s0 Função
# $f30 limite de proporçao
PLOT: 
	move $a0, $ra
	jal PUSH_STACK # guarda o valor de retorno na pilha
	
	l.s $f10, UM # carrega $f10 = 1.0

	mul.s $f0, $f0, $f30 # ajusta o range de x, $f30 = limite, diferente para cada func
	mul.s $f1, $f1, $f30 # ajusta o range de y, $f30 = limite, diferente para cada func

XY_PLOT: 
	jalr $s0 # vai para o valor da funcao em $s0, retorna valor y em $f12

	jal FLOAT_TO_INT	# Valor em $v0, Y
	move $a1, $v0
	
	mov.s $f12, $f0
	jal FLOAT_TO_INT
	move $a0, $v0	       # valor em $v0, X
	
	jal PLOTPIXEL
	
	add.s $f0, $f0, $f10
	c.le.s $f1, $f0 # $f1 = lsup , $f0 = x, lsup < x (FLAG = 1) 
	bc1f XY_PLOT # (FLAG = 0) 
	

	jal POP_STACK
	move $ra, $v0
	jr $ra # volta pra main

# ------  FIM PLOT ------

# ------  INÍCIO FLOAT_TO_INT  ------
# Função que recebe um numero em ponto flutuante ($f12)
# e devolve um inteiro em ($v0) 
FLOAT_TO_INT:
	cvt.w.s $f12, $f12
	mfc1 $v0, $f12
	jr $ra
	

# ------  FIM FLOAT_TO_INT  -----


# ------  INÍCIO DAS FUNÇÕES  ------
# f(x) = -x onde x pertence a [-1,1]
FUNCAO_A:

	neg.s $f12, $f0
    	jr $ra

# f(x) = x^2 + 1 onde x pertence a [-2,2] 
FUNCAO_B:   
	
    	l.s $f2, SUP_B # constante de proporçao Xmax = 2, 160/2 = 80
    	l.s $f3, VINTE # constante de proporção  20 * 8 = 160
    	
    	div.s $f12, $f0, $f2 # todo x recebido eh dividido por 80 
    	
    	mul.s $f12,$f12,$f12 # x^2
    	add.s $f12,$f12,$f10 # x^2 + 1
    	
    	mul.s $f12, $f12, $f3 # todo y tem que ser multiplicado por 20 
    	
    	jr $ra

# f(x) = sqrt(x) onde x pertence a [-1, 10] 
FUNCAO_C:

	l.s $f2, SUP_C # constante de proporçao Xmax = 10, 160/10 = 16
	
	div.s $f12, $f0, $f2 # divide todo X por 16
	
    	sqrt.s $f12, $f12 # sqrt(x)
    	
    	mul.s $f12, $f12, $f2 # multiplica todo Y por 16
    	jr $ra

# f(x) = (x+1)^2*(x-1)*(x-2)/(x-1.5) pertence a [-2, 3]
FUNCAO_D:

    	l.s $f2, SUP_D
    	l.s $f3, UMCINCO
    	add.s $f4, $f10, $f10 # $f4=1+1 
 	
    	div.s $f11, $f0, $f2 # divide todo x pela cte de proporçao
    	
    	#funcao 
    	
    	#y = 0 + 2
    	mov.s $f5, $f4
    	
    	# r = r + x
    	add.s $f5, $f5, $f11
    	
    	# x^2
    	mul.s $f6, $f11, $f11
    	# 3x^2
    	add.s $f7, $f4, $f10 # $f7 = 2 + 1 = 3
    	mul.s $f7, $f7, $f6 # $f7 = 3 * x^2
    	
    	# r = r - 3x^2
    	sub.s $f5, $f5, $f7
    	
    	# x^3
    	mul.s $f8, $f6, $f11 # $f8 = x^2 * x 
    	
    	# r = r - x^3
    	sub.s $f5, $f5, $f8
    	
    	# x^4
    	mul.s $f9, $f11, $f8 # $f9 = x^3 * x
    	# r = r + x^4	
    	add.s $f5, $f5, $f9
    	# x - 1/2 
    	sub.s $f6, $f11, $f3
    	# r = r / x - 1/2
    	div.s $f12, $f5, $f6
   	
    	mul.s $f12, $f12, $f2 # multiplica todo y pela cte de proporçao
    	
    	jr $ra
    	
# ------  FIM DAS FUNÇÕES  ------


# ------  INÍCIO BATMAN  ------
BATMAN:


# -7 A 7
# 2*sqrt(-abs(abs(x)-1)*abs(3-abs(x))/((abs(x)-1)*(3-abs(x))))(1+abs(abs(x)-3)/(abs(x)-3))*sqrt(1-(x/7)^2)+(5+0.97(abs(x-.5)+abs(x+.5))-3(abs(x-.75)+abs(x+.75)))(1+abs(1-abs(x))/(1-abs(x)))

BATMAN_CX:

# -3, -1
# 1, 3
#(2.71052+(1.5-.5abs(x))-1.35526sqrt(4-(abs(x)-1)^2))sqrt(abs(abs(x)-1)/(abs(x)-1))+0.9 
BATMAN_DX:

# -6, -4
# 4, 6
#-3*sqrt(1-(x/7)^2)*sqrt(abs(abs(x)-4)/(abs(x)-4))
BATMAN_EX:
	
	
# -4, 4
BATMAN_GX:

	l.s $f8, VINTE
	div.s $f11, $f0, $f8
	add.s $f24, $f10, $f10 
	l.s $f25, CONST1
	add.s $f29, $f10, $f24
	div.s $f20, $f11, $f24
	abs.s $f20, $f20
	
	mul.s $f26, $f11, $f11
	mul.s $f26, $f26, $f25
	
	sub.s $f20, $f20, $f26
	
	sub.s $f20, $f20, $f29
	
	##########
	abs.s $f26, $f11
	sub.s $f26, $f26, $f24
	abs.s $f26, $f26
	sub.s $f26, $f26, $f10
	mul.s $f26, $f26, $f26
	sub.s $f26, $f10, $f26
	sqrt.s $f15, $f26
	#########
	add.s $f12, $f20, $f15
	mul.s $f12, $f12, $f8
	jr $ra

# ------  FIM BATMAN  ------
	
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
	


# ------ INICIO PLOTPIXEL  ------
# Recebe $a0 = x e $a1 = y e calcula o endereço do pixel e plota
PLOTPIXEL:

	move $t2, $a0  # X = $a0
	move $t3, $a1  # Y = $a1
	neg $t3, $t3
	
	addi $t3,$t3,H_TAMY
	
	mul $t3,$t1,$t3   # Y*320
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3, H_TAMX

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

# ------ FIM PLOTPIXEL  ------


# ------ INICIO FUNÇÕES DA PILHA  ------
# Recebe um endereço = $a0 e empilha
PUSH_STACK:
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jr $ra
	
# Desempilha um endereço = $v0 e desempilha
POP_STACK:
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# ------ FIM FUNÇÕES DA PILHA  ------
