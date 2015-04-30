main:
	.data
question: .asciiz "Which function?\nType:\n\t 1 for sum\n\t 2 for product\n\t 3 for min\n\t 4 for max\n\t 5 for average\n\t 6 for median\n\t 7 for mode\n\t 8 for sort\n\t 9 for scalar matrix multiplication\n\t 10 for matrix multiply\n\t -1 to exit program\n"
numInputs: .asciiz "How many parameters?\n"
inputScalar: .asciiz "Please enter scalar:\n"
enterInput: .asciiz "Please input your parameters\n"
enterMatrix: .asciiz "Please input a matrix in the form {(1 2 3),(4 5 6)}.\n"
newLine: .asciiz "\n"
space: .asciiz " "

sumMessage: .asciiz "Calculating sum.\n"
productMessage: .asciiz "Calculating product.\n"
minMessage: .asciiz "Calculating min.\n"
maxMessage: .asciiz "Calculating max.\n"
averageMessage: .asciiz "Calculating average.\n"
medianMessage: .asciiz "Calculating median.\n"
modeMessage: .asciiz "Calculating mode.\n"
sortMessage: .asciiz "Sorting.\n"
matrixMultMessage: .asciiz "Matrix multiplying.\n"

	.text
ask:	
	li  $v0, 4          # service 4 is print string
    	la $a0, question  # load desired value into argument register $a0
	syscall
	
	li  $v0, 5         # service 5 is get integer
	syscall
	
	add $t0, $v0, $zero  # the function they want is in t0
	la $t6, 0($gp) # t6 points to the global pointer which points to the heap
	
checkFunction:
	beq $t0, 1, sum
	beq $t0, 2, product
	beq $t0, 3, min
	beq $t0, 4, max
	beq $t0, 5, average
	beq $t0, 6, median
	beq $t0, 7, mode
	beq $t0, 8, printSort
	beq $t0, 9, matrixScalar
	beq $t0, 10, matrixMult
	j end

getParamCount:
	li  $v0, 4          # service 4 is print string
    	la $a0, numInputs # load desired value into argument register $a0
	syscall
	
	li  $v0, 5         # service 5 is get integer
	syscall
	
	add $t1, $v0, $zero  # the number of parameters is in t1
	
	li  $v0, 4          # service 4 is print string
	la $a0, enterInput  # load desired value into argument register $a0
	syscall
	
	addi $t2, $zero, 1 # the loop counter is t2
	
getInput:
	bgt $t2, $t1, endInput
	li  $v0, 7         # service 7 is get double
	syscall
	
	add.d $f2, $f0, $f30  # the input value is in f2
	sdc1 $f2, 0($t6) # store the input on heap
	addi $t6, $t6, 8 # increment pointer
	addi $t2, $t2, 1 # increment loop counter
	j getInput

endInput:
	addi $t6, $t6, -8 # decrement pointer
	jr $ra


####  Input Matrix	

inputMatrix:
	# zero out EVERYTHING
	add $t1, $zero, $zero 
	add $t2, $zero, $zero 
	add $t3, $zero, $zero
	add $t4, $zero, $zero
	add $t5, $zero, $zero
	add $t8, $zero, $zero 
	add $t9, $zero, $zero 
	add.d $f0, $f30, $f30
	add.d $f2, $f30, $f30
	add.d $f4, $f30, $f30
	add.d $f6, $f30, $f30
	add.d $f8, $f30, $f30
	add.d $f10, $f30, $f30
	add.d $f12, $f30, $f30
	add.d $f14, $f30, $f30
	
	add $t7, $zero, $t6
	li  $v0, 4          # service 4 is print string
    	la $a0, enterMatrix # load desired value into argument register $a0
	syscall
	
	li $v0, 8 # ask nicely for a string
	lui $t1, 0x1004 # put the appropriate address in a1
	ori $t1, 0x0000
	la $a0, 0($t1)
	li $a1, 100000
	syscall
	
	lb $t2, 0($t1)
	addi $t5, $zero, 10 #store ten in a temp
	mtc1 $t5, $f0 # move ten to a floating point
	cvt.d.w $f0, $f0 #f0 has ten
	addi $t5, $zero, -1 #store -1 in a temp
	mtc1 $t5, $f6 # move -1 to a floating point
	cvt.d.w $f6, $f6 #f0 has negative 1
	
	
stringConvertLoop:
	beq $t2, '\0', endOfString
	beq $t2, '-', negative
	beq $t2, ')', newNumber
	beq $t2, ' ', newNumber
	beq $t2, ',', getNextChar
	beq $t2, '{', getNextChar
	beq $t2, '(', rowCount
	beq $t2, '}', getNextChar
	j digit
	
rowCount:
	addi $t4, $t4, 1 #t4 is the number of rows
	j getNextChar
	
digit:
	addi $t5, $t5, 1 # add one to the count of digits after the radix point
	beq $t2, '.', radixPoint
	addi $t2, $t2, -48	# the offset for ascii values
	mtc1 $t2, $f4
	cvt.d.w $f4, $f4 # the current digit is in f4
	add.d $f2, $f2, $f4 # add current digit to f2
	mul.d $f2, $f2, $f0 # multiply by ten
	j getNextChar

radixPoint:
	add $t5, $zero, $zero
	addi $t8, $zero, 1 #t8 is flag for radix point
	j getNextChar
	
negative:
	addi $t9, $zero, 1 #t9 is flag for negative numbers
	j getNextChar
	
newNumber:
	addi $t3, $t3, 1 # increment total number of numbers in matrix
	bne $t8, 1, noRadix
	
divByTenLoop:
	blt $t5, $zero, store # loop (the number of digits after the radix point +1) times, dividing by ten each time
	div.d $f2, $f2, $f0 
	addi $t5, $t5, -1
	j divByTenLoop
	
noRadix:
	div.d $f2, $f2, $f0 # divide one more time 

store:
	beq $t9, 0, isPositive
	mul.d $f2, $f2, $f6
isPositive:
	add $t8, $zero, $zero
	add $t9, $zero, $zero
	add $t5, $zero, $zero
	
	sdc1 $f2, ($t7)
	addi $t7, $t7, 8 # increment pointer
	add.d $f2, $f30, $f30
	
getNextChar:
	addi $t1, $t1, 1 # increment address pointer
	lb $t2, 0($t1) #load next character
	j stringConvertLoop
	
endOfString:
	div $t3, $t4
	mflo $t3
	# at end of loop t3 will have number of columns and t4 will have number of rows
	jr $ra
	

######## Sum	
	
sum:	
	jal getParamCount
	
	li $v0, 4          # service 4 is print string
    	la $a0, sumMessage  # load desired value into argument register $a0
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f8, $f30, $f30

sumLoop:	
	bge $t2, $t1, endSum
	ldc1 $f4, 0($t6)
	add.d $f8, $f8, $f4 # add current number to sum is in f8
	addi $t6, $t6, -8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	j sumLoop

endSum:
	jal printAnswerWithNewLine
	j ask


######## Product
		
product:	
	jal getParamCount
	
	li $v0, 4          # service 4 is print string
    	la $a0, productMessage  # load desired value into argument register $a0
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f8, $f30, $f30 # zero out f8, the answer 
	addi $t3, $zero, 1 
	mtc1 $t3, $f28 # move 1 to f28
	cvt.d.w $f28, $f28 # convert f28 to double
	add.d $f8, $f30, $f28 # add 1 to f8 because 0 times anything is 0
	
productLoop:
	bge $t2, $t1, endProduct
	ldc1 $f4, 0($t6)
	mul.d $f8, $f8, $f4 # multiply current product with current input
	addi $t6, $t6, -8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	j productLoop
	
endProduct:
	jal printAnswerWithNewLine
	j ask
	
	
######## Min
		
min:	
	jal getParamCount
	
	li $v0, 4         # service 4 is print string
    	la $a0, minMessage  # load desired value into argument register $a0
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f8, $f30, $f30
	
	### Stores infinity in $f8 ###
	lui $t3, 0x7FF0 
	ori $t3, 0x0000
	add $t4, $zero, $zero
	sw $t3, 8($t6)
	sw $t4, 12($t6)
	lwc1 $f9, 8($t6)
	lwc1 $f8, 12($t6)
	
minLoop:
  	beq $t2, $t1, endMin
	ldc1 $f10, 0($t6) # load the current input into f10
	
    	c.lt.d $f8, $f10 # set floating point condition flag to true if current min is less than input
    	bc1t keepMin # if current min < input don't change the current min
	
changeMin:
	add.d $f8, $f10, $f30 # set the current min (f8) to the new lower value
	
keepMin: 
	addi $t6, $t6, -8 # decrement heap pointer
	addi $t2, $t2, 1 # increment loop counter
	j minLoop
	
endMin:
	jal printAnswerWithNewLine
	j ask
	
	
######## Max
		
max:	
	jal getParamCount
	
	li $v0, 4         # service 4 is print string
    	la $a0, maxMessage  # load desired value into argument register $a0
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f8, $f30, $f30
	
	### Stores negative infinity in $f8 ###
	lui $t3, 0xFFF0 
	ori $t3, 0x0000
	add $t4, $zero, $zero
	sw $t3, 8($t6)
	sw $t4, 12($t6)
	lwc1 $f9, 8($t6)
	lwc1 $f8, 12($t6)
	
maxLoop:
  	beq $t2, $t1, endMax
	ldc1 $f10, 0($t6) # load the current input into f10
	
    	c.lt.d $f10, $f8 # set floating point conditional flag to true if input is less than current max
    	bc1t keepMax # if current min < input don't change the current min
	
changeMax:
	add.d $f8, $f10, $f30 # set the current max (f8) to the new higher value
	
keepMax: 
	addi $t6, $t6, -8 # decrement heap pointer
	addi $t2, $t2, 1 # increment loop counter
	j maxLoop
	
endMax:
	jal printAnswerWithNewLine
	j ask


######## Sort

sort:	
	li $v0, 4          # service 4 is print string
    	la $a0, sortMessage  # load desired value into argument register $a0
	syscall
	
	addi $t3, $zero, 1 # t2 is loop counter
	add $t7, $t6, $zero
	
sortOuterLoop:
	bge $t3, $t1, endSort
	addi $t2, $zero, 1 # t2 is loop counter	
	ldc1 $f6, 0($t7)

sortInnerLoop:
	bge $t2, $t1, endInnerLoop
	add.d $f4, $f6, $f30
	addi $t7, $t7, -8 # move pointer to previous input
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

endSort:
	jr $ra

######## PrintSort

printSort:
	jal getParamCount
	jal sort
	jal printList
	j ask

######## Average
		
average:	
	jal getParamCount
	
	li $v0, 4          # service 4 is print string
    	la $a0, averageMessage  # load desired value into argument register $a0
	syscall
	
	add $t2, $zero, $zero # t2 is loop counter
	add.d $f2, $f30, $f30

averageLoop:	
	bge $t2, $t1, divideByTotal
	ldc1 $f4, 0($t6)
	add.d $f2, $f2, $f4 # add current number to sum in f2
	addi $t6, $t6, -8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	j averageLoop

divideByTotal:
	mtc1 $t1, $f6 # move total number of inputs to f6
	cvt.d.w $f6, $f6 # convert f6 to double
	div.d $f8, $f2, $f6 # f8 is average
	
	jal printAnswerWithNewLine
	j ask


######## Median

median:	
	jal getParamCount
	jal sort

medianInit:
	li $v0, 4          # service 4 is print string
    	la $a0, medianMessage  # load desired value into argument register $a0
	syscall
	
	addi $t3, $zero, 2 # store 2 in t3
	div $t1, $t3 # divide total number of arguments by two
	mfhi $t3 # the remainder is in t3
	mflo $t4 # lo is the quotient
	add $t7, $t6, $zero # t7 will be the pointer for internal use in the inputs
	beq $t3, $zero, medianEven # if the remainder is zero there is an even number of arguments
	j medianOdd
	
medianOdd:
	add $t2, $zero, $zero # t2 is loop counter

medianOddLoop:
	beq $t2, $t4, setOddMedian # loop until we reach the index of the median
	addi $t7, $t7, -8 # change the pointer
	addi $t2, $t2, 1 # increment loop counter
	j medianOddLoop

setOddMedian:
	ldc1 $f8, 0($t7) # load median value into f8
	jal printAnswerWithNewLine
	j ask
	
medianEven:
	add $t2, $zero, $zero # t2 is loop counter
	addi $t4, $t4, -1 # have to add one because we want the next number after the quotient

medianEvenLoop:
	beq $t2, $t4, setEvenMedian	
	addi $t7, $t7, -8
	addi $t2, $t2, 1
	j medianEvenLoop
	
setEvenMedian:
	addi $t3, $zero, 2 # set t3 to 2
	ldc1 $f2, 0($t7) # load first value needed for median
	addi $t7, $t7, -8 # set pointer to second value needed for median
	ldc1 $f4, 0($t7) # load second value needed for median
	add.d $f6, $f2, $f4 # add two values needed for median
	mtc1 $t3, $f10 # move the number two to f10
	cvt.d.w $f10, $f10 # convert the number two, an integer, to double precision
	div.d $f8, $f6, $f10 # divide the sum by two and place value in f8 for printing
	
	jal printAnswerWithNewLine
	j ask
	

######## Mode

mode:
	jal getParamCount
	
	jal sort

modeInit:
	li $v0, 4          # service 4 is print string
    	la $a0, modeMessage  # load desired value into argument register $a0
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
	bc1f newValue # branch if the current value is not the same as the last value we looked at 
	j sameValue
	
newValue:
	add $t4, $zero, $zero # set the current counter to 0; will increment in the next line
		
sameValue:
	addi $t4, $t4, 1 #increment the current count
	
	# now check if the current count is equal to or greater than the highest count
	bgt $t4, $t3, counterGreater # if the current count is greater than the highest count
	j checkEqual
	
counterGreater:
	add $s0, $zero, $t6 # get rid of all previously stored modes by resetting the pointer to the modes to print
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
	addi $t7, $t7, -8 # go to next input
	addi $t2, $t2, 1 # increment loop counter
	j modeLoop
	

######## Scalar Matrix Multiplication

matrixScalar:
	jal inputMatrix
	li  $v0, 4          # service 4 is print string
    	la $a0, inputScalar  # load desired value into argument register $a0
	syscall
	
	li  $v0, 7         # service 7 is get double
	syscall
	add.d $f2, $f0, $f30  # the input value is in f2
	add $t7, $zero, $t6

scalarMultiplyMatrix:
	add $t1, $zero, $zero # outer(Row) loop counter
	add $t2, $zero, 1 # inner (Column) loop counter

rowMultLoop:
	beq $t1, $t4, stopMult # if we've reached the end of the row, jump to the end; otherwise fall through to column loop

columnMultLoop:
	bgt $t2, $t3, endRowMultLoop
	ldc1 $f8, 0($t7)	# load the next value
	mul.d $f8, $f8, $f2	# multiply by the scalar value
	sdc1 $f8, 0($t7)	# store the result to the same palce
	addi $t7, $t7, 8	# update pointers
	addi $t2, $t2, 1
	j columnMultLoop

endRowMultLoop:
	addi $t2, $zero, 1 # increment inner (Column) loop counter
	addi $t1, $t1, 1
	j rowMultLoop
	
stopMult:
	jal printMatrix
	j ask


######## Matrix Multiplication

matrixMult:
	jal inputMatrix
	add $t6, $zero, $t7 #resets value for next input matrix
	add $s0, $zero, $t7 # s0 is the pointer to the second matrix
	add $s1, $zero, $t3 # s1 is the number of columns in the first matrix
	add $s2, $zero, $t4 # s2 is the number of rows in the first matrix
								
	jal inputMatrix
	add $s3, $zero, $t7 # s3 is the pointer to the product
	add $s4, $zero, $t3 # s4 is the number of columns in the second matrix 
	add $s5, $zero, $t4 # s5 is the number of rows in the second matrix
	add $t4, $zero, $gp #t4 is pointer to m1
	add $t5, $zero, $s0 #t5 is pointer to m2
	add $t6, $zero, $s3 #t6 is pointer to product
	# use to reset t4, t5, t6: the global pointer points to the beginning of the first s0 points to the second and $s3 points to the product
	
	add $t1, $zero, $zero #t1 is a loop counter for outerloop which is the number of rows in the first matrix

m1RowLoop: # each m1RowLoop makes a whole row of the product
	# the outer loop goes for the number of rows in the first matrix
	beq $t1, $s2, done
	add $t2, $zero, $zero #t2 is the loop counter for the number of columns in matrix one

m1ColumnLoop: # multiplies corresponding values from each matrix, then adds the result to the appropriate cell of the new matrix
	beq $t2, $s1, m1ColumnLoopEnd
	add $t3, $zero, $zero #t3 is the loop counter for the number of columns in matrix 2

m2ColumnLoop: 
	beq $t3, $s4, m2ColumnLoopEnd
	ldc1 $f2, 0($t4)
	ldc1 $f4, 0($t5)
	ldc1 $f6, 0($t6)
	
	mul.d $f8, $f2, $f4
	add.d $f8, $f8, $f6
	sdc1 $f8, 0($t6)
	addi $t6, $t6, 8 #pointer to product increment
	addi $t3, $t3, 1
	addi $t5, $t5, 8 #increment pointer to m2
	j m2ColumnLoop

m2ColumnLoopEnd:
	addi $t4, $t4, 8 #increment pointer to m1
	# reset pointer to product to beginning of current row
	addi $t8, $zero, 8
	mult $t8, $s4
	mflo $t8
	sub $t6, $t6, $t8
	### end reset
	addi $t2, $t2, 1
	j m1ColumnLoop
	
m1ColumnLoopEnd:
	add $t5, $s0, $zero # reset pointer to m2
	addi $t1, $t1, 1
	add $t6, $t6, $t8
	j m1RowLoop
	
done:
	add $t6, $t7, $zero # the pointer for print matrix
	add $t4, $zero, $s2
	add $t3, $zero, $s4
	jal printMatrix
	j ask
	
	
######## Print
		
printAnswer:
	li  $v0, 3          # service 3 is print double
    	add.d $f12, $f8, $f30  # load desired value into argument register $a0
	syscall
	jr $ra
	
printNewLine:
	li $v0, 4         # service 4 is print string
    	la $a0, newLine  # load desired value into argument register $a0
	syscall
	jr $ra
	
printAnswerWithNewLine:
	li  $v0, 3          # service 3 is print double
    	add.d $f12, $f8, $f30  # load desired value into argument register $a0
	syscall
	li $v0, 4         # service 4 is print string
    	la $a0, newLine  # load desired value into argument register $a0
	syscall
	jr $ra

printSpace:
	li $v0, 11         # service 4 is print string
    	addi $a0, $zero, ' '  # load desired value into argument register $a0
	syscall
	jr $ra
		
printList:
	add $t2, $zero, $zero # t2 is loop counter
	
printOne:
	bge $t2, $t1, printNewLine
	ldc1 $f4, 0($t6)
	addi $t6, $t6, -8 # move pointer to previous input
	addi $t2, $t2, 1 # increment loop counter
	li  $v0, 3          # service 3 is print double
    	add.d $f12, $f4, $f30  # load desired value into argument register $f12
	syscall
	li $v0, 4         # service 4 is print string
    	la $a0, space  # load desired value into argument register $a0
	syscall
	j printOne

printModeList:
	add $t2, $zero, $zero # t2 is loop counter
	
printOneMode:
	bge $t2, $t5, printNewLineMode #t5 is the number of modes to print
	ldc1 $f4, 0($t6)
	addi $t6, $t6, 8 # move pointer to next printy thing
	addi $t2, $t2, 1 # increment loop counter
	li  $v0, 3       # service 3 is print double
    	add.d $f12, $f4, $f30  # load desired value into argument register $f12
	syscall
	li $v0, 4      # service 4 is print string
    	la $a0, space  # load desired value into argument register $a0
	syscall
	j printOneMode

printNewLineMode:
	li $v0, 4         # service 4 is print string
    	la $a0, newLine  # load desired value into argument register $a0
	syscall
	j ask
	
	
######## Print Matrix

printMatrix:
	sw $ra, 0($sp)
	add $t7, $zero, $t6
	li $v0, 11 # syscall 11 is print character
	addi $a0, $zero, '{' # load desired value into argument register $a0
	syscall
	
	add $t1, $zero, $zero # outer (Row) loop counter
	add $t2, $zero, 1 # inner (Column) loop counter

rowLoop:
	beq $t1, $t4, stop
	li $v0, 11 # syscall 11 is print character
	addi $a0, $zero, '(' # load desired value into argument register $a0
	syscall

columnLoop:
	bgt $t2, $t3, endRowLoop
	ldc1 $f8, 0($t7)
	jal printAnswer
	sdc1 $f30, 0($t7)
	addi $t7, $t7, 8
	beq $t2, $t3, noSpace
	jal printSpace

noSpace:
	addi $t2, $t2, 1
	j columnLoop

endRowLoop:
	li $v0, 11 # syscall 11 is print character
	addi $a0, $zero, ')' # load desired value into argument register $a0
	syscall
	addi $t2, $zero, 1 # inner (Column) loop counter
	addi $t1, $t1, 1
	j rowLoop
	
stop:
	li $v0, 11 # syscall 11 is print character
	addi $a0, $zero, '}' # load desired value into argument register $a0
	syscall
	jal printNewLine
	lw $ra, 0($sp)
	jr $ra
	
end:	
	li $v0, 10 # exit
	syscall
