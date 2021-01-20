	.syntax unified
	.cpu cortex-m4
	.thumb
.text
	.equ X, 0x55
	.equ Y, 0x01234567
.global main
main:
	movs r0, #X
	ldr r1, =Y
	adds r2, r0, r1
L:B L
