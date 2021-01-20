.syntax unified
	.cpu cortex-m4
	.thumb

.data

.text
	.global max7219_init
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

max7219_init:
	//TODO: Initial max7219 registers.
	push {R0, R1, R2, LR}
	ldr R0, =#DECODE_MODE
	ldr R1, =#0xFF
	BL max7219_send
	ldr R0, =#DISPLAY_TEST
	ldr R1, =#0x0
	BL max7219_send
	ldr R0, =#SCAN_LIMIT
	ldr R1, =#0x6
	BL max7219_send
	ldr R0, =#INTENSITY
	ldr R1, =#0xA
	BL max7219_send
	ldr R0, =#SHUTDOWN
	ldr R1, =#0x1
	BL max7219_send
	pop {R0, R1, R2, PC}
	BX LR
