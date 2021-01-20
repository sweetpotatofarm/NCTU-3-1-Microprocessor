//3-2
//我們的開發板提供了一個內建的藍色使用者按鈕，該按鈕連接到 STM32 微
//控制器的 I/O PC13。 請初始化 GPIO PC13 作為上拉輸入，並使用軟體解彈
//跳技巧來解決機械彈跳問題。
//接著，設計一個輪詢程式讀取使用者按鈕的狀態。然後利用這個按鈕控制
//LED 的滾動（Require 2-1）。 按下按鈕後，LED 將暫停滾動，當再次按下
//按鈕時，它將從繼續滾動。
	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	leds: .byte 0
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

	.equ onesec, 100000

main:
	BL GPIO_init

	MOVS R3, #1
	LDR R0, =leds
	STRB R3, [R0]
	movs R7, #1 //pause or start(0 for pause, 1 for start)

Loop:
	// TODO: Write the display pattern into leds variable
	movs R4, #0
	movs R8, #0
	BL CheckPress
	BL DisplayLED
	BL Delay
	B Loop

CheckPress:
	// TODO: Do debounce and check button state
	movs R6, #0
	cmp R7, #0
	beq pauseState
	cmp R7, #1
	beq startState

	pauseState:
	ldr R5, [R2]
	lsr R5, R5, #13
	and R5, R5, #1
	add R6, R6, #1
	cmp R6, #20
	beq goStart
	cmp R5, #0
	beq pauseState
	movs R6, #0
	b pauseState

	startState:
	ldr R5, [R2]
	lsr R5, R5, #13
	and R5, R5, #1
	add R6, R6, #1
	cmp R6, #20
	beq goPause
	cmp R5, #0
	beq startState
	movs R6, #0
	b checkFinish

	goStart:
	movs R7, #1
	movs R8, #1
	b checkFinish

	goPause:
	movs R6, #0
	movs R7, #0
	ldr R9, =onesec
	b doNothing

	doNothing:
	sub R9, #1
	cmp R9, #0
	beq pauseState
	b doNothing

GPIO_init:
	// TODO: Initialize LED, button GPIO pins
	// Enable AHB2 clock
	movs R0, #0x1
	ldr R1, =RCC_AHB2ENR
	str R0, [R1]
	movs R0, #0x5
	ldr R1, =RCC_AHB2ENR
	str R0, [R1]

	// Set LED gpio output
	// Set gpio pins as output mode
	movs R0, #0x5500 //101010100000000
	ldr R1, =GPIOA_MODER
	ldr R2, [R1]
	and R2, #0xFFFF00FF //11111111111111110000000011111111
	orrs R2, R2, R0
	str R2, [R1]
	// Keep PUPDR as the default value(pull-up)
	// Set output speed register
	movs R0, #0xAA0
	ldr R1, =GPIOA_OSPEEDR
	strh R0, [R1]

	// Set user button(pc13) as gpio input
	// set PC13 as input mode
	// Set PC13 as Pull-up
	ldr R0, =GPIOC_MODER
	ldr R1, [R0]
	and R1, R1, 0xF3FFFFFF //11110011111111111111111111111111
	str R1, [R0]

	//for output
	ldr R1, =GPIOA_ODR
	//for input
	ldr R2, =GPIOC_IDR

	movs R0, #0xFF
	strh R0, [R1]

	BX LR

DisplayLED:
	// TODO: Display LED by leds
	cmp R3,#1
	beq L1
	cmp R3,#2
	beq L2
	cmp R3,#3
	beq L3
	cmp R3,#4
	beq L4
	cmp R3,#5
	beq L5
	cmp R3,#6
	beq L6
	cmp R3,#7
	beq L7
	cmp R3,#8
	beq L8

	L1:
	movs R0, #0xEF //11101111
	b return

	L2:
	movs R0, #0xCF //11001111
	b return

	L3:
	movs R0, #0x9F //10011111
	b return

	L4:
	movs R0, #0x3F //00111111
	b return

	L5:
	movs R0, #0x7F //01111111
	b return

	L6:
	movs R0, #0x3F
	b return

	L7:
	movs R0, #0x9F
	b return

	L8:
	movs R0, #0xCF
	movs R3, #0
	b return

	return:
	strh	R0,[R1]
	LDR		R0, =leds
	add R3, R3, #1
	ldr r4, =onesec
	BX LR

Delay:
	// TODO: Write a delay 1 sec function
	// You can implement this part by busy waiting.
	// Timer and Interrupt will be introduced in later lectures.
	sub r4, r4, #1
	cmp R8, #0
	beq CheckPress
	checkFinish:
	cmp r4, #0
	bne Delay
	BX LR

