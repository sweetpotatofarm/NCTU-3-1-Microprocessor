//3-1
//請構建一個包含 4 個低態有效 LED 的電路。 也就是說，當相應的 GPIO 引
//腳輸出高電位（VDD）時，LED 將關閉，而當接收到低電位（VSS）時，
//LED 將被打開。
//接著，參考章節投影片，完成週邊裝置匯流排（AHB2）及 GPIO 接腳的初
//始化。接著，完成以下程式碼。利用 "leds" 這個變數紀錄目前位移數值，並
//使用 "DisplayLED" 函式將 LED 設置為與變數對應的圖案。

//請不要將 PA13 和 PA14 用作 I/O 引腳，否則會發現除錯工具發生故障。默
//認情況下，它們與連接到 ST-LINK/V2-1 的 SWD 信號共享。你可以連接你
//的 LDEs 至實驗板上的 PB3, PB4, PB5, PB6。

//在一開始，最右邊的 LED 亮起。 接著，燈光每秒鐘按順序向左移動直到抵
//達左端，然後將改變移動方向為右。 在此過程中，除了到達左端和右端之
//外應該有兩個 LED 點亮。
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
	.equ onesec, 400000

main:
	BL GPIO_init
	MOVS R3, #1
	LDR R0, =leds
	STRB R3, [R0]

Loop:
	/* TODO: Write the display pattern into leds variable */
	BL DisplayLED
	BL Delay
	B Loop

GPIO_init:
	/* TODO: Initialize LED GPIO pins as output */
	// Enable AHB2 clock
	movs R0, #0x1
	ldr R1, =RCC_AHB2ENR
	str R0, [R1]
	// Set pins (Ex. PA4-7) as output mode
	movs R0, #0x5500 //101010100000000
	ldr r1, =GPIOA_MODER
	ldr R2, [R1]
	and R2, #0xFFFF00FF //11111111111111110000000011111111
	orrs R2, R2, R0
	str R2, [R1]
	// Keep PUPDR as the default value(pull-up).
	movs R0, #0x5500 //101010100000000
	ldr R1, =GPIOA_PUPDR
	ldr R2, [R1]
	and R2, #0xFFFF00FF //11111111111111110000000011111111
	orrs R2, R2, R0
	str R2, [R1]

	// Set output speed register
	movs R0, #0xAA0
	ldr R1, =GPIOA_OSPEEDR
	strh R0, [R1]

	ldr R1, =GPIOA_ODR

/*
	movs R0, #0xF0
	strh R0, [R1]
*/

	BX LR

DisplayLED:
	/* TODO: Display LED by leds */
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
	movs R0, #0xEF
	//active high
	//movs R0, #0x1F
	b return

	L2:
	movs R0, #0xCF
	//active high
	//movs R0, #0x3F
	b return

	L3:
	movs R0, #0x9F
	//active high
	//movs R0, #0x6f
	b return

	L4:
	movs R0, #0x3F
	//active high
	//movs R0, #0xCF
	b return

	L5:
	movs R0, #0x7F
	//active high
	//movs R0, #0x8F
	b return

	L6:
	movs R0, #0x3F
	//active high
	//movs R0, #0xCF
	b return

	L7:
	movs R0, #0x9F
	//active high
	//movs R0, #0x6f
	b return

	L8:
	movs R0, #0xCF
	//active high
	//movs R0, #0x3F
	movs R3, #0
	b return

	return:
	strh	r0,[r1]
	LDR		r0, =leds
	add R3, R3, #1
	ldr R4, =onesec
	BX LR

Delay:
	/* TODO: Write a delay 1 sec function */
	// You can implement this part by busy waiting.
	// Timer and Interrupt will be introduced in later lectures.
	sub R4, R4, #1
	cmp R4, #0
	bne Delay
	BX LR





