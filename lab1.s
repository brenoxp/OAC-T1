.eqv VGA 0xFF000000
.eqv NUMX 320
.eqv NUMY 240

.data
INF:   .float -2.0
SUP:   .float 2.0
UM:    .float 1.0

.text
MAIN:	jal PLOT
	li $v0,10
	syscall

FUNCAO:	# letra b)
	l.s $f1,UM
	mul.s $f12,$f0,$f0
	add.s $f12,$f12,$f1
	jr $ra	
			
PLOT:	# FAZER!!!!
	# Este é só um Exemplo de uso da VGA
	la $t0,VGA
	li $t1,NUMX

	li $t2,0  # X
	li $t3,0  # Y
	li $t5,0xC0  # cor 0b11000000

	mul $t3,$t1,$t3   # Y*320
	add $t3,$t3,$t2   # X+Y*320
	add $t3,$t3,$t0   # Endereco
	sb $t5,0($t3)	  # plota o pixel na tela
	jr $ra

	