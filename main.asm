main:
	.data
question: .ascii "Which function? We have 7 functions 1 for average\n\0"
numInputs: .ascii "How many parameters?\n\0"
enterInput: .ascii "Please input your parameters\n\0"
averageDebug: .ascii "Calculating average.\n\0"

	.text
	li  $v0, 4          # service 4 is print string
    	la $a0, question  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	li  $v0, 5         # service 5 is get integer
	syscall
	
	add $t0, $v0, $zero  # the function they want is in t0
	
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
	beq $t0, 1, average
	j end
	
	
average:	
	li $v0, 4          # service 4 is print string
    	la $a0, averageDebug  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f2, $f30, $f30 # cleared sum for some reason
adding:	
	bgt $t2, $t1, divideByTotal
	ldc1 $f4, 0($t6)
	add.d $f2, $f2, $f4 # adds current number to sum sum is in f2
	subi $t6, $t6, 8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	j adding

divideByTotal:
#	add.d $f3	#f3 is number of inputs
	mtc1.d $t1, $f6 # move total number of inputs to f6
	cvt.d.w $f6, $f6 # convert f6 to double
	div.d $f8, $f2, $f6 # f8 is average
		
printAnswer:
	li  $v0, 3          # service 4 is print string
    	add.d $f12, $f8, $f30  # load desired value into argument register $a0, using pseudo-op
	syscall

end: