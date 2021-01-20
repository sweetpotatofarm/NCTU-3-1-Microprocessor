.syntax unified
	.cpu cortex-m4
	.thumb

.data

.text
	.global GPIO_init
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

	.equ GPIOC_MODER , 0x48000800
	.equ GPIOC_OTYPER ,	0x48000804
	.equ GPIOC_OSPEEDR , 0x48000808
	.equ GPIOC_PUPDR ,	0x4800080c
	.equ GPIOC_IDR , 0x48000810

GPIO_init:
	// Enable AHB2 clock
	movs R0, #0x5
	ldr R1, =RCC_AHB2ENR
	str R0, [R1]
	// Set pins (PA5) as output mode
	movs R0, #0x400 //010000000000
	ldr r1, =GPIOA_MODER
	ldr R2, [R1]
	and R2, #0xFFFFF3FF //11111111111111111111001111111111
	orrs R2, R2, R0
	str R2, [R1]
	// Keep PUPDR as the default value(pull-up).
	movs R0, #0x400 //010000000000
	ldr R1, =GPIOA_PUPDR
	ldr R2, [R1]
	and R2, #0xFFFFF3FF //11111111111111111111001111111111
	orrs R2, R2, R0
	str R2, [R1]

	// Set output speed register
	movs R0, #0xAA0
	ldr R1, =GPIOA_OSPEEDR
	strh R0, [R1]

	// Set user button(pc13) as gpio input
	// set PC13 as input mode
	// Set PC13 as Pull-up
	ldr R0, =GPIOC_MODER
	ldr R1, [R0]
	ldr R2, =0xF3FFFF00 //11110011111111111111111100000000
	and R1, R1, R2
	str R1, [R0]

	BX LR
