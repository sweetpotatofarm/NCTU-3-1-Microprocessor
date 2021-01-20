.syntax unified
.cpu cortex-m4
.thumb

.data
.text

.global max7219_init
	.equ 	DIN,	0b1000 		//PB3
	.equ	CS,		0b10000		//PB4
	.equ	CLK,	0b100000	//PB5

	//max7219
	.equ	DECODE_MODE,	0x19 //decode control
	.equ	INTENSITY,		0x1A //brightness
	.equ	SCAN_LIMIT,		0x1B //how many digits to display
	.equ	SHUT_DOWN,		0x1C //shut down
	.equ	DISPLAY_TEST,	0x1F //display test
max7219_init:
//TODO: Initialize max7219 registers
	push {r0, r1, r2, lr}

	ldr r0, =DISPLAY_TEST
	ldr r1, =0x0
	bl MAX7219Send

	ldr r0, =INTENSITY
	ldr r1, =0xA
	bl MAX7219Send

	ldr r0, =SCAN_LIMIT
	ldr r1, =0x6
	bl MAX7219Send

	ldr r0, =DECODE_MODE
	ldr r1, =0b1111111
	bl MAX7219Send

	ldr r0, =SHUT_DOWN
	ldr r1, =0x1
	bl MAX7219Send

	pop {r0, r1, r2, pc}
