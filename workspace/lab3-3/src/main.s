//3-3
//請使用麵包板構建一個低態有效的指撥開關電路，並將 P0〜P3 連接至開發
//板上的 GPIO 引腳（您可以自行選擇引腳）。 則當我們打開開關時，GPIO
//引腳將接收到低電位。 例如，如果我們將下圖中指撥開關的 pin-1 和 pin-8
//短路，則 P0 將接收到低電位。
//接著宣告一個單字節的全局變數 "password"，並實現簡單的 4 位元密碼鎖。
//當我們按下使用者按鈕時，它將從指撥開關中讀取密碼並檢查正確性，然後
//通過閃爍 LED 來顯示結果。正確時閃三次，錯誤時閃一次。（您可以使用
//板子上的使用者LED它被連接到PA5）。
	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	leds: .byte 0
	password: .byte 0b1101
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014

	.equ GPIOC_MODER , 0x48000800
	.equ GPIOC_OTYPER ,	0x48000804
	.equ GPIOC_OSPEEDR , 0x48000808
	.equ GPIOC_PUPDR ,	0x4800080c
	.equ GPIOC_IDR , 0x48000810

	.equ onesec, 400000

main:
 	BL GPIO_init
	MOVS R3, #1 //r3 stores blinking times
	LDR R0, =leds
	STRB R3, [R0]
Loop:
	/* TODO: Write the display pattern into leds variable */
	BL checkPress
	BL checkLock
	BL DisplayLED
	B Loop

GPIO_init:
	/* TODO: Initialize LED GPIO pins as output */
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

	//for output
	ldr R1, =GPIOA_ODR
	//for press
	ldr R2, =GPIOC_IDR
	//for lock
	ldr R8, =GPIOC_IDR

	movs R0, #0xDF
	strh R0, [R1]

	BX LR

checkPress:
	movs R6, #0
	checkStart:
	add R6, R6, #1
	ldr R5, [R2]
	lsr R5, R5, #13
	and R5, R5, #1
	cmp R6, #10
	beq checkFinish
	cmp R5, #0
	beq checkStart
	movs R6, #0
	b checkStart

	checkFinish:
	bx lr

checkLock:
	ldr R5, [R2]
	and R5, 0b1111
	ldr R7, =password
	ldrb R7, [R7]
	eor R7, 0b1111
	cmp R5, R7
	beq correct
	b incorrect

	correct:
	movs R3, #3
	bx lr

	incorrect:
	movs R3, #1
	bx lr

DisplayLED:
	/* TODO: Display LED by leds */
	movs R0, #0xff
	strh R0,[R1]
	ldr	R0, =leds
	ldr r4, =onesec
	bl Delay

	movs R0, #0xf
	strh R0,[R1]
	ldr	R0, =leds
	ldr r4, =onesec
	bl Delay

	sub R3, R3, #1
	cmp R3, #0
	bne DisplayLED
	b Loop

Delay:
	/* TODO: Write a delay 1 sec function */
	// You can implement this part by busy waiting.
	// Timer and Interrupt will be introduced in later lectures.
	sub R4, R4, #1
	cmp R4, #0
	bne Delay
	BX LR
