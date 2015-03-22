main:
	.data
question: .ascii "Which function?\nThere are n functions:\n 1 for sum\n 2 for product\n 3 for min\n\ 4 for max\n 5 for average\n -1 to exit program\n\0"
numInputs: .ascii "How many parameters?\n\0"
enterInput: .ascii "Please input your parameters\n\0"
newLine: .ascii "\n\0"

sumDebug: .ascii "Calculating sum.\n\0"
productDebug: .ascii "Calculating product.\n\0"
minDebug: .ascii "Calculating min.\n\0"
maxDebug: .ascii "Calculating max.\n\0"
averageDebug: .ascii "Calculating average.\n\0"

	.text
ask:	li  $v0, 4          # service 4 is print string
    	la $a0, question  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	li  $v0, 5         # service 5 is get integer
	syscall
	
	add $t0, $v0, $zero  # the function they want is in t0
	
checkFunction:
	beq $t0, 1, getParamCount
	beq $t0, 2, getParamCount
	beq $t0, 3, getParamCount
	#beq $t0, 4, getParamCount
	beq $t0, 5, getParamCount
	j end

getParamCount:
	li  $v0, 4          # service 4 is print string
    	la $a0, numInputs  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	li  $v0, 5         # service 5 is get integer
	syscall
	
	add $t1, $v0, $zero  # the number of parameters is in t1
	
	li  $v0, 4          # service 4 is print string
    	la $a0, enterInput  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	addi $t2, $zero, 1 # the loop counter is t2
	
	la $t6, 0($gp) # t6 points to the global pointer which points to the heap
	
getInput:
	bgt $t2, $t1, decideFunction
	li  $v0, 7         # service 7 is get double
	syscall
	
	add.d $f2, $f0, $f30  # the input value is in f1
	sdc1 $f2, 0($t6) # store the input on heap
	addi $t6, $t6, 8 # increment pointer
	addi $t2, $t2, 1 # incrementing loop counter
	j getInput
	
decideFunction:
	addi $t6, $t6, -8 # decrement pointer
	beq $t0, 1, sum
	beq $t0, 2, product
	beq $t0, 3, min
	#beq $t0, 4, max
	beq $t0, 5, average

######## Sum
		
sum:	
	li $v0, 4          # service 4 is print string
    	la $a0, sumDebug  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f8, $f30, $f30 # cleared sum for some reason
sumLoop:	
	bge $t2, $t1, printAnswer
	ldc1 $f4, 0($t6)
	add.d $f8, $f8, $f4 # adds current number to sum is in f8
	subi $t6, $t6, 8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	j sumLoop

######## Product
		
product:	
	li $v0, 4          # service 4 is print string
    	la $a0, productDebug  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f8, $f30, $f30 # 
	addi $t3, $zero, 1
	mtc1.d $t3, $f28
	cvt.d.w $f28, $f28
	add.d $f8, $f30, $f28
	
productLoop:
	bge $t2, $t1, printAnswer
	ldc1 $f4, 0($t6)
	mul.d $f8, $f8, $f4 # multiplies current product with current input
	subi $t6, $t6, 8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	j productLoop
	
######## Min
		
min:	
	li $v0, 4         # service 4 is print string
    	la $a0, minDebug  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f8, $f30, $f30 # cleared sum for some reason
	
	### Stores Iinfinity in $f8 ###
	lui $t3, 0x7FF0 
	ori $t3, 0x0000
	add $t4, $zero, $zero
	sw $t3, 8($t6)
	sw $t4, 12($t6)
	lwc1 $f9, 8($t6)
	lwc1 $f8, 12($t6)
	
minLoop:
  	beq $t2, $t1, printAnswer
	ldc1 $f10, 0($t6) # load the current input into f10
	
        c.lt.d $f8, $f10 # set floating point conditional to true if current min is less than input
        bc1t keepMin # if current min < input don't change the current min
	
changeMin:
	add.d $f8, $f10, $f30 # set the curren min (f8) to the new lower value
	
keepMin: 
	sub $t6, $t6, 8 # decrement heap pointer
	addi $t2, $t2, 1 # increment loop counter
	j minLoop
	
######## Average
		
average:	
	li $v0, 4          # service 4 is print string
    	la $a0, averageDebug  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f2, $f30, $f30 # cleared sum for some reason
averageLoop:	
	bge $t2, $t1, divideByTotal
	ldc1 $f4, 0($t6)
	add.d $f2, $f2, $f4 # adds current number to sum is in f2
	subi $t6, $t6, 8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	j averageLoop

divideByTotal:
	mtc1.d $t1, $f6 # move total number of inputs to f6
	cvt.d.w $f6, $f6 # convert f6 to double
	div.d $f8, $f2, $f6 # f8 is average
		
printAnswer:
	li  $v0, 3          # service 4 is print string
    	add.d $f12, $f8, $f30  # load desired value into argument register $a0, using pseudo-op
	syscall

	li $v0, 4         # service 4 is print string
    	la $a0, newLine  # load desired value into argument register $a0, using pseudo-op
	syscall

	j ask
	
end:	j end