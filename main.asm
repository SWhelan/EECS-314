main:
	.data
question: .ascii "Which function?\nThere are n functions. Type:\n\t 1 for sum\n\t 2 for product\n\t 3 for min\n\t 4 for max\n\t 5 for average\n\t 6 for median\n\t 7 for mode\n\t 8 for sort\n\t 9 for matrix multiply\n\t -1 to exit program\n\0"
numInputs: .ascii "How many parameters?\n\0"
enterInput: .ascii "Please input your parameters\n\0"
newLine: .ascii "\n\0"
space: .ascii " \0"

sumDebug: .ascii "Calculating sum.\n\0"
productDebug: .ascii "Calculating product.\n\0"
minDebug: .ascii "Calculating min.\n\0"
maxDebug: .ascii "Calculating max.\n\0"
averageDebug: .ascii "Calculating average.\n\0"
medianDebug: .ascii "Calculating median.\n\0"
modeDebug: .ascii "Calculating mode.\n\0"
sortDebug: .ascii "Sorting.\n\0"
matrixMultDebug: .ascii "Matrix multiplying.\n\0"

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
	beq $t0, 4, getParamCount
	beq $t0, 5, getParamCount
	#beq $t0, 6, getParamCount
	beq $t0, 7, getParamCount
	beq $t0, 8, getParamCount
	#beq $t0, 9, matrixMult
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
	beq $t0, 4, max
	beq $t0, 5, average
	#beq $t0, 6, median
	beq $t0, 7, mode
	beq $t0, 8, sort


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
	add.d $f8, $f30, $f30 # zeros out f8 - the answer 
	addi $t3, $zero, 1 
	mtc1.d $t3, $f28 # moves 1 to f28
	cvt.d.w $f28, $f28 # converts f28 to double
	add.d $f8, $f30, $f28 # add 1 to f8 because 0 times anything is 0
	
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
	
	### Stores Infinity in $f8 ###
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
	
	
######## Max
		
max:	
	li $v0, 4         # service 4 is print string
    	la $a0, maxDebug  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f8, $f30, $f30 # cleared sum for some reason
	
	### Stores -Infinity in $f8 ###
	lui $t3, 0xFFF0 
	ori $t3, 0x0000
	add $t4, $zero, $zero
	sw $t3, 8($t6)
	sw $t4, 12($t6)
	lwc1 $f9, 8($t6)
	lwc1 $f8, 12($t6)
	
maxLoop:
  	beq $t2, $t1, printAnswer
	ldc1 $f10, 0($t6) # load the current input into f10
	
        c.lt.d $f10, $f8 # set floating point conditional to true if input is less than current max
        bc1t keepMax # if current min < input don't change the current min
	
changeMax:
	add.d $f8, $f10, $f30 # set the curren max (f8) to the new higher value
	
keepMax: 
	sub $t6, $t6, 8 # decrement heap pointer
	addi $t2, $t2, 1 # increment loop counter
	j maxLoop


######## Sort

sort:	
	li $v0, 4          # service 4 is print string
    	la $a0, sortDebug  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	addi $t3, $zero, 1 # t2 is loop counter
	add $t7, $t6, $zero
	
sortOuterLoop:
	bge $t3, $t1, modeOrPrint
	addi $t2, $zero, 1 # t2 is loop counter	
	ldc1 $f6, 0($t7)
sortInnerLoop:
	bge $t2, $t1, endInnerLoop
	add.d $f4, $f6, $f30
	subi $t7, $t7, 8 # move pointer to previous input
	ldc1 $f6, 0($t7)
	c.lt.d $f6, $f4
	bc1t swapInner
	j noSwapInner
	
swapInner:
	add.d $f10, $f4, $f30
	add.d $f4, $f6, $f30
	add.d $f6, $f10, $f30
	
noSwapInner:
	sdc1 $f4, 8($t7)
	sdc1 $f6, 0($t7)
	addi $t2, $t2, 1 # increment inner loop counter
	j sortInnerLoop

endInnerLoop:
	add $t7, $t6, $zero
	addi $t3, $t3, 1 # increment outer loop counter
	j sortOuterLoop

modeOrPrint:
	beq $t0, 7, modeInit
	j printList


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
	j printAnswer


######## Mode

mode:
	j sort
modeInit:
	li $v0, 4          # service 4 is print string
    	la $a0, modeDebug  # load desired value into argument register $a0, using pseudo-op
	syscall

	add $t2, $zero, $zero # t2 is loop counter
	add $t3, $zero, $zero # t3 will be highest count
	add $t4, $zero, $zero # t4 will be current count
	add $t5, $zero, $zero # t5 is the number of mode values we need to print
	add $t7, $t6, $zero # t7 will be the pointer for internal use in the inputs
	addi $s0, $t6, 8 # s0 will be the pointer for storing which values need to be printed
	ldc1 $f8, 0($t7) # f8 will be the previous value
	
modeLoop:
	bge $t2, $t1, printModeList
	ldc1 $f4, 0($t7) # f4 is the current value
	c.eq.d $f4, $f8
	bc1f newValue # if the current value is not the same as the last value we looked at 
	j sameValue
	
newValue:
	add $t4, $zero, $zero # set the current counter to 0; will increment in the next line
	#sdc1 $f8, 0($s0)
	#addi $s0, $s0, 8
	
sameValue:
	addi $t4, $t4, 1 #increment the current count
	
	# now check if the current count is equal to or greater than the highest count
	bgt $t4, $t3, counterGreater # if the current count is greater than the highest count
	j checkEqual
	
counterGreater:
	add $s0, $zero, $t6 # get rid of all previously stored modes by resettingn the pointer to the modes to print
	addi $t5, $zero, 1 # set the number of values that need to be printed to 1
	sdc1 $f4, 0($s0) # make the current value the first value to be printed
	addi $s0, $s0, 8 # increment the s0 pointer
	add $t3, $t4, $zero
	j finishLoop

checkEqual:
	beq $t3, $t4, counterEqual
	j finishLoop
	
counterEqual:	
	addi $t5, $t5, 1 # increment the number of values that need to be printed
	sdc1 $f4, 0($s0) # add this value to the list of what needs to be printed
	addi $s0, $s0, 8 # increment the s0 pointer
	
finishLoop:
	add.d $f8, $f4, $f30 # save the current value as the previous value
	subi $t7, $t7, 8 # go to next input
	addi $t2, $t2, 1 # increment loop counter
	j modeLoop
	
	
######## Print	
		
printAnswer:
	li  $v0, 3          # service 4 is print string
    	add.d $f12, $f8, $f30  # load desired value into argument register $a0, using pseudo-op
	syscall

	li $v0, 4         # service 4 is print string
    	la $a0, newLine  # load desired value into argument register $a0, using pseudo-op
	syscall

	j ask
		
printList:
	add $t2, $zero, $zero # t2 is loop counter
	
printOne:
	bge $t2, $t1, printNewLine
	ldc1 $f4, 0($t6)
	subi $t6, $t6, 8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	li  $v0, 3          # service 3 is print double
    	add.d $f12, $f4, $f30  # load desired value into argument register $f12
	syscall
	li $v0, 4         # service 4 is print string
    	la $a0, space  # load desired value into argument register $a0, using pseudo-op
	syscall
	j printOne

printModeList:
	add $t2, $zero, $zero # t2 is loop counter
	
printOneMode:
	bge $t2, $t5, printNewLine #t5 is the number of modes to print
	ldc1 $f4, 0($t6)
	addi $t6, $t6, 8 # move pointer to next printy thing
	addi $t2, $t2, 1 # increment loop counter
	li  $v0, 3       # service 3 is print double
    	add.d $f12, $f4, $f30  # load desired value into argument register $f12
	syscall
	li $v0, 4      # service 4 is print string
    	la $a0, space  # load desired value into argument register $a0, using pseudo-op
	syscall
	j printOneMode

printNewLine:
	li $v0, 4         # service 4 is print string
    	la $a0, newLine  # load desired value into argument register $a0, using pseudo-op
	syscall
	#j ask
	
end:	j end
