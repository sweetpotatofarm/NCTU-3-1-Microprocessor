.syntax unified
	.cpu cortex-m4
	.thumb

.data
	.equ GPIOA_ODR, 0x48000014

.text
	.global DisplayLED

DisplayLED:
	/* TODO: Display LED by leds */
	ldr R1, =GPIOA_ODR

	cmp R0, #1
	beq light
	b dark

	light:
	movs R0, #0xff
	strh R0,[R1]
	b end

	dark:
	movs R0, #0xf
	strh R0,[R1]
	b end

	end:
	bx lr
