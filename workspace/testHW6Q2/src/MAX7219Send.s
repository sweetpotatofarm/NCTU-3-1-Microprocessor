.syntax unified
.cpu cortex-m4
.thumb

.data
.text

.global MAX7219Send
	.equ GPIOB_BSRR, 0x48000418
	.equ GPIOB_BRR, 0x48000428

	.equ 	DIN,	0b1000 		//PB3
	.equ	CS,		0b10000		//PB4
	.equ	CLK,	0b100000	//PB5

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA,r7 num
	//TODO: Use this function to send a message to max7219
	push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =DIN
	ldr r2, =CS
	ldr r3, =CLK
	ldr r4, =GPIOB_BSRR //set 1
	ldr r5, =GPIOB_BRR //set 0
	movs r6, #0xf

send_loop:
	str r3, [r5] //set clk 0

	movs r7, 1
	lsl r7, r6	// r7 ... 10000, 1000, 100, 10, 1
	tst r0, r7
	beq bit_not_set
	str r1, [r4] //set din 1
	b if_done
bit_not_set:
	str r1, [r5] //set din 0
if_done:
	str r3, [r4] //set clk1
	subs r6, r6, 1
	bge send_loop
	str r2, [r5] //set cs0
	str r2, [r4] //set cs1
	pop {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	BX LR
