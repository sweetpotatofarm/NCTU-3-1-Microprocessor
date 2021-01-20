//4-1 live coding
	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	//TODO: put 0 to F 7-Seg LED pattern here
	arr: .byte 0x1c, 0x19, 0x15, 0xd, 0x1c, 0x19, 0x15, 0xd, 0x1c, 0x19, 0x15, 0xd, 0x1c, 0x19, 0x15, 0xd
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_BASE, 0x48000000
	.equ GPIO_BSRR_OFFSET, 0x18
	.equ GPIO_BRR_OFFSET, 0x28
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

	.equ onesec, 400000

main:
	BL GPIO_init
	BL max7219_init

	ldr R9, =arr
	ldr R2, =#0

	B DisplayDigit

GPIO_init:
	//TODO: Initialize GPIO pins for max7219 DIN, CS and CLK
	movs R0, #0x1
	ldr R1, =RCC_AHB2ENR
	str R0, [R1]

	//pinA-5,6,7
	movs R0, #0x5400 //101010000000000
	ldr r1, =GPIOA_MODER
	ldr R2, [R1]
	and R2, #0xFFFF03FF //11111111111111110000001111111111
	orrs R2, R2, R0
	str R2, [R1]

	movs R0, #0xA800
	ldr R1, =GPIOA_OSPEEDR
	str R0, [R1]

	ldr R1, =GPIOA_ODR

	BX LR

DisplayDigit:
	//TODO: Display 0 to F at first digit on 7-SEG LED.
	movs R0, #1
	forLoop:
	//save R0 current place
	movs R11, R0
	movs R0, #1
	//turn every digit to zero
	movs R1, #0
	bl MAX7219Send
	movs R0, #2
	movs R1, #0
	bl MAX7219Send
	movs R0, #3
	movs R1, #0
	bl MAX7219Send
	movs R0, #4
	movs R1, #0
	bl MAX7219Send
	movs R0, #5
	movs R1, #0
	bl MAX7219Send
	movs R0, #6
	movs R1, #0
	bl MAX7219Send
	movs R0, #7
	movs R1, #0
	bl MAX7219Send
	movs R0, #8
	movs R1, #0
	bl MAX7219Send

	//change R0 to the format we want
	movs R0, R11
	ldrb R1, [R9, R2]
	bl MAX7219Send

	bl Delay
	add R0, R0, #1
	add R2, R2, #1
	cmp R2, #8
	bne forLoop
	movs R2, #0
	b DisplayDigit

	/*
	movs R0, #1
	ldrb R1, [R9, R2]
	bl MAX7219Send
	bl Delay
	add R2, R2, #1
	cmp R2, #16
	bne DisplayDigit
	movs R2, #0
	b DisplayDigit
	*/
MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, lr}
	lsl R0, R0, #8 //D8-D15
	add R0, R0, R1 //D0-D7
	ldr R1, =#GPIOA_BASE
	ldr R2, =#LOAD
	ldr R3, =#DATA
	ldr R4, =#CLOCK
	ldr R5, =#GPIO_BSRR_OFFSET //1
	ldr R6, =#GPIO_BRR_OFFSET //0
	movs R7, #16 //i

	max7219send_loop:
		mov R8, #1
		sub R9, R7, #1
		lsl R8, R8, R9 //R8 = mask
		str R4, [R1, R6] //clk = 0
		tst R0, R8 //same as ands, if bit R0[R8] = 0, zero = 1, bit R0[R8] = 1, zero = 0
		beq bit_not_set
		str R3, [R1, R5] //din = 1
		b if_done

	bit_not_set: //clear
		str R3, [R1, R6] //din = 0

	if_done:
		str R4, [R1, R5] //clk = 1
		subs R7, R7, #1 //i--
		bgt max7219send_loop
		str R2, [R1, R6] //cs = 0
		str R2, [R1, R5] //cs = 1
		pop {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, pc}
		BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {R0, R1, R2, LR}
	ldr R0, =#DECODE_MODE
	ldr R1, =#0x0 //no decode
	BL MAX7219Send
	ldr R0, =#DISPLAY_TEST
	ldr R1, =#0x0 //normal
	BL MAX7219Send
	ldr R0, =#SCAN_LIMIT
	ldr R1, =#0x7 //digit 0 only
	BL MAX7219Send
	ldr R0, =#INTENSITY
	ldr R1, =#0xA //10
	BL MAX7219Send
	ldr R0, =#SHUTDOWN
	ldr R1, =#0x1 //normal operation
	BL MAX7219Send
	pop {R0, R1, R2, PC}
	BX LR

Delay:
	//TODO: Write a delay 1sec function
	ldr R4, =onesec
	DelayLoop:
	sub R4, R4, #1
	cmp R4, #0
	bne DelayLoop
	bx lr

