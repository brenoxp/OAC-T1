Parte 2.1)
O código sortcTesteOriginal.s foi comentado devidamente de acordo com as propostas estabelecidas pelo trabalho.

Parte 2.2)
Para que fosse corretamente compilado no MARS foi preciso redefinir algumas funções e comentar algumas outras outras, como por exemplo a definição de .module fp=32, que não permitia a compilação por processar em 32 bits, em que foi necessário removê-la, como também o alinhamento no endereço 2 .align 2 em alguns campos do código, algumas definições de tipo de função como sendo função, como por exemplo .type v, @object e .type show, @function. Além disso, foi necessário fazer mudanças, como por exemplo, a definição de %lo e %hi, j $31 para jr $31. Nos seguintes trechos de código abaixo foram necesárias fazer algumas alterações, sendo elas:

#	lui	$2,%hi(.LC0)
#	addiu	$4,$2,%lo(.LC0)
	la 	$4, .LC0($0)

Em que, ao comentar a instrução lui $2,%hi(.LC0), que pega os valores mais significativos do label .LC0, armazenando no registrador 2. Após essa operação, era necessário fazer a operação de adiocionar os valores menos significativos do label .LC0 e armazenar em uma outra variável, adicionando-o no registrador $4. Para a simplificação e reconhecimento do código no MARS, foi necessária fazer um load adress de uma word no registrador $zero, pegando, assim, toda a palavra. Deixando, deste modo, o código similar ao que deveria ser feito. 
Em todos os arquivos foram acrescentados o seguinte trecho de código para que o MARS conseguisse simular: 

	nop
	jal 	main
	nop
	li 	$v0, 10
	syscall

Em que é feita uma chamada para a função main, seguindo assim com o enccerramento da simulação através do syscall 10. Foi necessário acrescentar dois nops antes e depois da chamada de funçao, para que fosse operado corretamente. 

Parte 2.3)
Após a compilação de todos os códigos gerados para cada diretiva, O0, O1, O2, O3 e Os pode-se notar que o compilador gcc é mais veloz, dependendo do nível de otimização da diretiva utilizada. 
