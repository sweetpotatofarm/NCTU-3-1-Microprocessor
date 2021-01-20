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
