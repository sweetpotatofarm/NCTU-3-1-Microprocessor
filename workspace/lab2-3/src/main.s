//2-3
//Stein的GCD演算法為二進制GCD演算法，使用算術移位，比較和減法取
//代除法，並且被證明相較於歐幾里得演算法有更高的效率。在這裡，我們
//展示了C語言的實現。您可以檢查下面的鏈接以獲取更多信息。
///* Stein’s Algorithm (C version)*/
//int GCD(int a, int b) {
// if (a == 0) return b; if (b == 0) return a;
// if (a % 2 == 0 && b % 2 == 0) return 2 * GCD(a >> 1, b >> 1);
// else if (a % 2 == 0) return GCD(a >> 1, b);
// else if (b % 2 == 0) return GCD(a, b >> 1);
// else return GCD(abs(a - b), min(a, b));
//}
	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .word 0
	max_size: .word 0

.text
	.global main
	m: .word 0x4E
	n: .word 0x82

GCD:
	//TODO: Implement your GCD function

	cmp r0, #0
	beq return_r1
	cmp r1, #0
	beq return_r0

	and r3, r0, #1
	and r4, r1, #1

	orr r5, r3, r4
	cmp r5, #0
	beq case1

	cmp r3, #0
	beq case2

	cmp r4, #0
	beq case3

	sub r7, r0, r1
	cmp r7, #0
	bge positive
    mov r8, #-1             // will skip if positive
    mul r7, r8, r7          // will skip if positive
positive:
	cmp r0, r1
	bge skip_update_min     // will skip if r1 <= r0
	mov r1, r0              // will skip if r1 <= r0
skip_update_min:
    mov r0, r7
    push {lr}
    add R12, R12, #4
	cmp R12, R9
	ble noUpdate1
	movs R9, R12
	noUpdate1:
    bl GCD
    pop {r10}
    sub R12, R12, #4
    mov lr, r10
    bx lr

// (a % 2 == 0 && b % 2 == 0) return 2 * gcd( a >> 1, b >> 1 )
case1:
	asr r0, #1
	asr r1, #1
	push {lr}
	add R12, R12, #4
	cmp R12, R9
	ble noUpdate2
	movs R9, R12
	noUpdate2:
	bl GCD
	ldr r11, [r2]
	lsl r11, #1
	str r11, [r2]
	pop {r10}
	sub R12, R12, #4
	mov lr, r10
	bx lr

// else if ( a % 2 == 0 ) return gcd( a >> 1, b )
case2:
	asr r0, #1
	push {lr}
	add R12, R12, #4
	cmp R12, R9
	ble noUpdate3
	movs R9, R12
	noUpdate3:
	bl GCD
	pop {r10}
	sub R12, R12, #4
	mov lr, r10
	bx lr

// else if ( b % 2 == 0 ) return gcd( a, b >> 1 )
case3:
	asr r1, #1 //算術右移
	push {lr}
	add R12, R12, #4
	cmp R12, R9
	ble noUpdate4
	movs R9, R12
	noUpdate4:
	bl GCD
	pop {r10}
	sub R12, R12, #4
	mov lr, r10
	bx lr

return_r0:
	str r0, [r2]
	pop {r10}
	sub R12, R12, #4
	mov lr, r10
	bx lr

return_r1:
	str r1, [r2]
	pop {r10}
	sub R12, R12, #4
	mov lr, r10
	bx lr


main:
	// r0 = m, r1 = n
	movs r9, #0 //max size
	movs r12, #0 //stack size now
	ldr r0, =m
	ldr r1, =n
	ldr r0, [r0]
    ldr r1, [r1]
    ldr r2, =result
	BL GCD
	// get return val and store into result
	ldr r12, =max_size
	str r9, [r12]

L:
	b L
