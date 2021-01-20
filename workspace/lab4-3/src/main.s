//4-3
//設計一個程式來檢測 STM32 上用戶按鈕的輸入信號。 點擊按鈕 N 次後，
//在 7 段 LED 上顯示第 N 個斐波那契數並將沒使用到的位數設為空白。 按
//住用戶按鈕 1 秒鐘以上時，將顯示的數字重置為 0。如果數值超出顯示範
//圍，請顯示 “9999 9999”，範例影片如下。
	.syntax unified
	.cpu cortex-m4
	.thumb

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104c
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000c
	.equ GPIOA_ODR, 0x48000014

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OTYPER, 0x48000804
	.equ GPIOC_OSPEEDR, 0x48000808
	.equ GPIOC_PUPDR, 0x4800080c
	.equ GPIOC_IDR, 0x48000810

main:
	bl GPIO_init
	bl max7219_init
	bl Reset
	mov r10, #0
	mov r11, #1
L:
    bl CheckPress
    bl Display
    b L

GPIO_init:
	//TODO: Initialize GPIO pins for max7219 DIN, CS and CLK

	// Enable AHB2 clock
	mov r2, #0x5
	ldr r3, =RCC_AHB2ENR
	str r2, [r3]

	// Set PA5, PA6, PA7 as output mode(01)
	ldr r5, =GPIOA_MODER
	ldr r2, =0x5400 //101010000000000
	ldr r3, [r5]
	ldr r4, =0xffff03ff //11111111111111110000001111111111
	and r3, r3, r4
    orr r3, r3, r2
	str r3, [r5]

	// Set PC13 as input
	ldr r5, =GPIOC_MODER
	ldr r2, =0xf3ffffff //11110011111111111111111111111111
	ldr r3, [r5]
	and r3, r3, r2
	str r3, [r5]

	BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r2, r3, r4, r5, r6, r7}
	ldr r2, =GPIOA_ODR
	mov r3, #0
	orr r3, r3, r1
	lsl r0, 8
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
    	sub r4, 1
    	cmp r4, #-1
    	bne Loop

	ldr r6, =0x40
    str r6, [r2]
    ldr r6, =0xc0
    str r6, [r2]
    ldr r6, =0x00
    str r6, [r2]

	pop {r2, r3, r4, r5, r6, r7}

	BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, lr}

	// set shutdown register(1 for normal operation)
	ldr r0, =0x0c
	ldr r1, =0x1
	BL MAX7219Send

	// set decode-mode register(code B deocde for digits 7-0)
	ldr r0, =0x09
	ldr r1, =0xff
	BL MAX7219Send

	// set display-test register(0 for normal operation)
	ldr r0, =0x0f
	ldr r1, =0x0
	BL MAX7219Send

	// set scan-limit register(display digits 7-0)
	ldr r0, =0x0b
	ldr r1, =0x7
	BL MAX7219Send

	// set intensity register
	ldr r0, =0x0a
	ldr r1, =0xA
	BL MAX7219Send

	pop {r0, r1, pc}

CheckPress:
	// TODO: Do debounce and check button state
	push {r10, r11}
	ldr r1, =GPIOC_IDR
	mov r10, #0
	mov r12, #0

	CPLOOP:
		// Check first time
    	ldr r2, [r1]
	   	ldr r3, =0x2000
    	and r2, r2, r3
   		lsr r2, #13
    	cmp r2, #0
        bne CPLOOP

		// Delay (for debounce)
    	ldr r6, =10000
		L2:
			subs r6, #1
    		cmp r6, #0
    		bne L2

		// Check again
    	ldr r2, [r1]
    	ldr r3, =0x2000
    	and r2, r2, r3
    	lsr r2, #13
    	cmp r2, #0
    	beq pressed
    	b CPLOOP
		pressed:
			mov r10, #1

		// Delay about 1 second
		ldr r6, =1000000
		L3:
			subs r6, #1
    		cmp r6, #0
    		bne L3

		// Check Press ( long press )
    	ldr r2, [r1]
    	ldr r3, =0x2000
    	and r2, r2, r3
    	lsr r2, #13
    	cmp r2, #0
    	beq long_pressed
    	pop {r10, r11}
    	bx lr
		long_pressed:
			mov r12, #1      // r12 : 1 for long press; 0 for short press

	pop {r10, r11}
	bx lr


Display:
	push {lr}

	// check r12 first, if 1 -> reset
	cmp r12, #1
	bne skip_reset
	bl Reset
	pop {pc}

	// cases for short press
	skip_reset:
		mov r1, r11
		add r11, r10, r11
		mov r10, r1

		// check overflow
		ldr r2, =99999999
		cmp r11, r2
		ble no_overflow

		// case: overflow, display 99999999
		mov r0, #0x8
		mov r1, #0x9
		bl MAX7219Send

		mov r0, #0x7
		mov r1, #9
		bl MAX7219Send

		mov r0, #0x6
		mov r1, #9
		bl MAX7219Send

		mov r0, #0x5
		mov r1, #9
		bl MAX7219Send

		mov r0, #0x4
		mov r1, #9
		bl MAX7219Send

		mov r0, #0x3
		mov r1, #9
		bl MAX7219Send

		mov r0, #0x2
		mov r1, #9
		bl MAX7219Send

		mov r0, #0x1
		mov r1, #9
		bl MAX7219Send

		ldr r10, =39088169
		ldr r11, =63245986

		pop {pc}

	// cases for short press and the result is not overflow
	no_overflow:
	//check from 10000000, if ans < 10000000, no minus, check R2, if 0, blank, if 1, 0

		mov r7, #8            // digits
		mov r2, #0            // check bit for blank
		mov r5, r11			  // load the result in r5 for operate
		DL:
			cmp r7, #0        // if digit = 0: break
			beq DL_END

			mov r0, #0        // r0: bit for count the number of the digit


			// start caculate base //
			ldr r8, =1        // r8:base (ex: 1 for digit 0, 10 for digit 1.....)
			mov r6, #10
			cmp r7, #1        // r7 = 1 -> digit 0 -> base = 1
			beq one
			push {r7}
			time10:
			mul r8, r8, r6
			sub r7, r7, #1
			cmp r7, #1
			bne time10
			pop {r7}
			one:
			// end caculate base //

			digit:
				cmp r5, r8            // if r5(result) > r8(base) -> do minus
				bge minus

				// digit 0 (special case)
				cmp r7, #1
				beq D0

				// check if blank
				cmp r2, #0
				beq blank

				// display number for digit 1-7
				mov r1, r0
				mov r0, r7
				bl MAX7219Send
				sub r7, r7, #1
				b DL

				// display the digit with blank
				blank:
				mov r0, r7
				mov r1, 0xf
				bl MAX7219Send
				sub r7, r7, #1
				b DL

				// digit 0:can't be blank
				D0:
				mov r1, r0
				mov r0, r7
				bl MAX7219Send
				sub r7, r7, #1
				b DL

				minus:
        		sub r5, r5, r8
        		add r0, #1               // count how many times we do minus
        		mov r2, #1				 // after one minus, there won't be any blank
        		b digit
		DL_END:

	pop {pc}


// set 7-seg LED to 0, and set r10 -> 0, r11 -> 1
// r10, r11 number for calculate Fibonacci
Reset:
	push {lr}
	mov r0, #0x8
	mov r1, #0xf
	bl MAX7219Send

	mov r0, #0x7
	mov r1, #0xf
	bl MAX7219Send

	mov r0, #0x6
	mov r1, #0xf
	bl MAX7219Send

	mov r0, #0x5
	mov r1, #0xf
	bl MAX7219Send

	mov r0, #0x4
	mov r1, #0xf
	bl MAX7219Send

	mov r0, #0x3
	mov r1, #0xf
	bl MAX7219Send

	mov r0, #0x2
	mov r1, #0xf
	bl MAX7219Send

	mov r0, #0x1
	mov r1, #0
	bl MAX7219Send

	mov r10, #0
	mov r11, #1

	// Write a delay 1 sec function
    ldr r3, =1000000
	L1:
		subs r3, #1
   		cmp r3, #0
    	bne L1

	pop {pc}

