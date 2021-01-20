//2-1
//請實現 Karatsuba 算法，該算法接受兩個32位元無號整數 "X, Y"，並將 X 乘以 Y 的結果存儲到變量 "result" 中。
//Karatsuba算法是一種使用分而治之技巧的快速乘法演算法。
//通過 Karatsuba 演算法，我們得到以下等式。其中 X 和 Y 是兩個 n 位元整數 XL, XR是 X 的最左，最右一半，而 YL, YR是 Y 的最左，最右一半。
//X*Y = 2^n * XL YL + 2^n/2 * [(XL + XR)(YL + YR) - (XL YL + XRXR)] + XRYR
	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .zero 8

.text
	.global main
	.equ X, 0xffffffff
	.equ Y, 0xffffffff

main:
	ldr r0, =X
	ldr r1, =Y
	ldr r2, =result
	bl kara_mul

L:
	b L

kara_mul:
	// TODO: Seperate the leftmost and rightmost halves into
	// different registers; then do the Karatsuba algorithm.

    ldr r7, =0xffff

	and r3, r0, r7    // right  part of X (XR)
	lsr r0, #16
	and r4, r0, r7    // left part of X (XL)

	and r5, r1, r7    // right  part of Y (YR)
	lsr r1, #16
	and r6, r1, r7    // left part of Y (YL)

	mul r8, r4, r6    // XL * YL
	mul r9, r3, r5    // XR * YR

	add r3, r3, r4    // XL + XR
	add r5, r5, r6    // YL + YR

	//mul r3, r5, r3    // ( XL + XR ) * ( YL + YR )
	ldr r12, =0x0
	umull r3, r6, r5, r3 //(r6(lower), r3(higher)) = r5*r3
	adds r4, r8, r9    // ( XL * YL ) + ( XR * YR )
	mov r10, #0
	adc r10, r10, r12
	//sub r3, r3, r4    // (( XL + XR ) * ( YL + YR )) - (( XL * YL ) + ( XR * YR ))

	subs r3, r3, r4
	sbc r6, r6, r10

    and r4, r3, r7    // right 16 bits of mid
    lsr r3, #16
    and r5, r3, r7    // left 16 bits of mid

    lsl r6, #16
    add r5, r5, r6

    lsl r4, #16

    adds r9, r9, r4
    adc r8, r8, r5

    strd r8, r9, [r2]

	bx lr
