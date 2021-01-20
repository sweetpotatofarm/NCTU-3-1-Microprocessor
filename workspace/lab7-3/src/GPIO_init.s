.syntax unified
.cpu cortex-m4
.thumb

.data
.text

.global GPIO_init7
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OSPEEDR, 0x48000408

GPIO_init7:
//TODO: Initialize GPIO pins for max7219 DIN, CS and CLK

	// GPIOB
	movs r0,#7
	ldr r1,=RCC_AHB2ENR
	str r0,[r1]

	// PB 0, 1, 2 output
	movs r0,#21
	ldr r1,=GPIOB_MODER
	ldr r2,[r1]
	ands r2,r2,#0xFFFFFFC0
	orrs r2,r2,r0
	str r2,[r1]

	// PB 0, 1, 2 High Speed
	movs r0,#0x2A
	ldr r1,=GPIOB_OSPEEDR
	ldr r2,[r1]
	ands r2,r2,#0xFFFFFFC0
	orrs r2,r2,r0
	str r2,[r1]

	BX LR






