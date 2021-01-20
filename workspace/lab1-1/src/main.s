//1-1
.syntax unified
.cpu cortex-m4
.thumb

.data
	result: .byte 0

.text
.global main
	.equ X, 0xABCD
	.equ Y, 0xEFAB

main:
	ldr R0, =X //This line will cause an error. Why?
	ldr R1, =Y
	ldr R2, =result
	bl hamm
L: b L

hamm:
	movs R5, #0 // R5 = 0

	eor R3, R0, R1 //R3 = X xor Y

	loop:
		and R4, R3, #1 //if R3 is ...xxx1, R4 = 1, else, R4 = 0
		add R5, R5, R4 //count R5
		lsr R3, R3, #1 //logic shift right

		cmp R3, #0 //if R3 == 0, return
		beq return

		b loop //else loop


	return:
		str R5, [R2]
		bx lr
