//1-3
.syntax unified
.cpu cortex-m4
.thumb

.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
.text
	.global main
do_sort:
 	mov R1, #8 //n

 	movs R2, #0 //i

 	firstForLoop:
 		movs R4, #0 //j
 		movs R5, R1
 		sub R5, R5, #1 //n-1
 		sub R5, R5, R2 //n-i-1

		sub R1, R1, #1
 		cmp R2, R1
 		bne add //i != n-1?
 		b return//i == n-1, break

 		add:
 		add R1, R1, #1
 		b secondForLoop

 		secondForLoop:
 		cmp R4, R5
 		beq secondReturn //j == n-i-1

 		add R3, R0, R4 //arr[j] add
 		//movs R8, #4
 		//mul R10, R4, R8
 		//add R3, R0, R10
 		ldrb R7, [R3] //arr[j]
 		add R3, R3, #1 //arr[j+1] add
 		//add R3, R3, #4
 		ldrb R6, [R3] //arr[j+1]  modify
 		cmp R7, R6 //modify
 		blt swap
 		//live code:
 		//bgt swap

 		add R4, R4, #1 //j++
 		b secondForLoop

 		secondReturn:
 		add R2, R2, #1 //i++
 		b firstForLoop

 		swap:
 		movs R9, R6
 		movs R6, R7
 		movs R7, R9
 		strb R6, [R3]
 		sub R3, R3, #1
 		//sub R3, R3, #4
 		strb R7, [R3]

 		add R4, R4, #1
 		b secondForLoop

 	return:
	bx lr

main:
	ldr r0, =arr1
	bl do_sort
	ldr r0, =arr2
	bl do_sort
L: b L

/*
void bubbleSort(int arr[], int n)
{
   int i, j;
   for (i = 0; i < n-1; i++)

       // Last i elements are already in place
       for (j = 0; j < n-i-1; j++)
           if (arr[j] > arr[j+1])
              swap(&arr[j], &arr[j+1]);
}
*/
