.syntax unified
	.cpu cortex-m4
	.thumb

.data
	.equ GPIOC_IDR , 0x48000810

.text
	.global DisplayLED

CheckPress:
	ldr R2, =GPIOC_IDR

	movs R6, #0
	checkStart:
	add R6, R6, #1
	ldr R5, [R2]
	lsr R5, R5, #13
	and R5, R5, #1
	cmp R6, #10
	beq checkFinish
	cmp R5, #0
	beq checkStart
	movs R6, #0
	b checkStart

	checkFinish:
	bx lr
