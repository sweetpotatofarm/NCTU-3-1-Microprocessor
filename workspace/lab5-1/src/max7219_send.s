.syntax unified
	.cpu cortex-m4
	.thumb

.data

.text
	.global max7219_send
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014
	.equ DECODE_MODE,	0x09
	.equ SHUTDOWN,	0x0C
	.equ INTENSITY,	0x0A
	.equ SCAN_LIMIT, 0x0B
	.equ DISPLAY_TEST, 0x0F
	.equ DATA, 0x20 //PA5
	.equ LOAD, 0x40 //PA6
	.equ CLOCK, 0x80 //PA7

	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_BASE, 0x48000000
	.equ GPIO_BSRR_OFFSET, 0x18
	.equ GPIO_BRR_OFFSET, 0x28

max7219_send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, lr}
	lsl R0, R0, #8
	add R0, R0, R1
	ldr R1, =#GPIOA_BASE
	ldr R2, =#LOAD
	ldr R3, =#DATA
	ldr R4, =#CLOCK
	ldr R5, =#GPIO_BSRR_OFFSET //1
	ldr R6, =#GPIO_BRR_OFFSET //0
	movs R7, #16

	max7219send_loop:
		mov R8, #1
		sub R9, R7, #1
		lsl R8, R8, R9 //R8 = mask
		str R4, [R1, R6] //clk = 0, if bit R0[R8] = 0, zero = 1, bit R0[R8] = 1, zero = 0
		tst R0, R8 //same as ands
		beq bit_not_set
		str R3, [R1, R5] //din = 1
		b if_done

	bit_not_set:
		str R3, [R1, R6] //din = 0

	if_done:
		str R4, [R1, R5] //clk = 1
		subs R7, R7, #1 //i--
		bgt max7219send_loop
		str R2, [R1, R6] //cs = 0
		str R2, [R1, R5] //cs = 1
		pop {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, pc}
		BX LR
