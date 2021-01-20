//1-2
.syntax unified
.cpu cortex-m4
.thumb

.text
	.global main
	.equ N, 46

fib:
	cmp R0, #0
	blt lessThanZero //less than zero?

	cmp R0, #100
	bgt greaterThanHundred //greater than a hundred?

	movs R4, #0
	cmp R0, #0 //equal to zero?(f(0))
	beq return

	movs R4, #1
	cmp R0, #1 //equal to one?(f(1))
	beq return

	movs R1, #0 //f(n-2)
	movs R2, #1 //f(n-1)
	movs R4, #0 //f(n)
	movs R5, #2 //n

	loop:
	add R4, R1, R2 //f(n) = f(n-1)+f(n-2)
	cmp R4, R2
	blt overflow

	cmp R0, R5 // n == R0 ?
	beq return

	add R5, R5, #1 //n++
	movs R1, R2 //R1 = R2
	movs R2, R4 //R2 = ans
	b loop

	return:
	bx lr

	lessThanZero:
	movs R4, #0
	sub R4, R4, #1
	b return

	greaterThanHundred:
	movs R4, #0
	sub R4, R4, #1
	b return

	overflow:
	movs R4, #0
	sub R4, R4, #1
	sub R4, R4, #1
	b return

main:
	movs R0, #N
	bl fib

L: b L
