//4-2
//在本實驗中，您被要求將 Max7219 設置為 code B decode mode。 然
//後，請參考下面提供的代碼請參閱下面提供的代碼，請將您的學生 ID 放
//置在陣列 student_id 中，並將這些數字顯示在 7 段 LED 上。 例如，如果
//您的學號是 1234567，則 7 段 LED 會顯示如下圖所示的圖案。沒使用到
//的 digits 被設成了空白。
	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	//TODO: put your student id here
	student_id: .byte 0, 7, 1, 6, 0, 2, 6
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

.text
	.global main
main:
	BL GPIO_init
	BL max7219_init
	//TODO: display your student id on 7-Seg LED
	ldr r9, = student_id
    ldr r2, =#0
    ldr r3, =#8
    ldr r4, =#9
	for_loop:
		ldrb r1, [r9, r2]
		add r0, r2, #1
		sub r0, r3, r0 //7654321
		BL MAX7219Send
		add r2, r2, #1
		cmp r2, r3
		bne for_loop
Program_end:
	B Program_end
GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
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
MAX7219Send:
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
max7219_init:
	//TODO: Initial max7219 registers.
	push {R0, R1, R2, LR}
	ldr R0, =#DECODE_MODE
	ldr R1, =#0xFF //decode
	BL MAX7219Send
	ldr R0, =#DISPLAY_TEST
	ldr R1, =#0x0
	BL MAX7219Send
	ldr R0, =#SCAN_LIMIT
	ldr R1, =#0x6 //digit 0 ~ 7
	BL MAX7219Send
	ldr R0, =#INTENSITY
	ldr R1, =#0xA
	BL MAX7219Send
	ldr R0, =#SHUTDOWN
	ldr R1, =#0x1
	BL MAX7219Send
	pop {R0, R1, R2, PC}
	BX LR
