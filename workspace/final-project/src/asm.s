.text
	.global GPIO_init, MAX7219Send, max7219_init
	.equ RCC_AHB2ENR, 0x4002104c
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000c
	.equ GPIOA_ODR, 0x48000014

GPIO_init:
	//TODO: Initialize GPIO pins for max7219 DIN, CS and CLK

	// Enable AHB2 clock
	mov r2, #0x1
	ldr r3, =RCC_AHB2ENR
	str r2, [r3]

	// Set PA5, PA6, PA7 as output mode(01)
	ldr r5, =GPIOA_MODER
	ldr r2, =0x5400
	ldr r3, [r5]
	ldr r4, =0xffff03ff
	and r3, r3, r4
    orr r3, r3, r2
	str r3, [r5]

	BX LR


MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r4-r7, lr}
	ldr r2, =GPIOA_ODR
	mov r3, #0
	orr r3, r3, r1
	lsl r0, #8
	orr r3, r3, r0

 	mov r4, #15

    Loop:
    	mov r5, r3
    	lsr r5, r4
    	mov r7, #1
    	and r5, r5, r7
    	lsl r5, #5
    	ldr r6, =0x0
    	orr r6, r6, r5
    	str r6, [r2]
		ldr r6, =0x80
    	orr r6, r6, r5
    	str r6, [r2]
    	sub r4, #1
    	cmp r4, #0
    	bge Loop

	ldr r6, =0x40
    str r6, [r2]
    ldr r6, =0xc0
    str r6, [r2]
    ldr r6, =0x00
    str r6, [r2]

	pop {r4-r7, pc}

max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, lr}

	// set shutdown register(1 for normal operation)
	ldr r0, =0x0c
	ldr r1, =0x1
	BL MAX7219Send

	// set decode-mode register(deocde for digits 7-0)
	ldr r0, =0x09
	ldr r1, =0xff
	BL MAX7219Send

	// set display-test register(0 for normal operation)
	ldr r0, =0x0f
	ldr r1, =0x0
	BL MAX7219Send

	// set scan-limit register(display digits 0-7)
	ldr r0, =0x0b
	ldr r1, =0x7
	BL MAX7219Send

	// set intensity register
	ldr r0, =0x0A
	ldr r1, =0xA
	BL MAX7219Send

	pop {r0, r1, pc}
