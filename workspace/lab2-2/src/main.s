//2-2
//堆疊的一個著名應用是檢查括號的平衡。我們從左到右讀取中序表達式的
//元素。當我們遇到開括號時，我們將其推入堆疊，當我們遇到閉括號時則
//從堆疊中彈出元素與之匹配。最後我們檢查堆疊是否為空。
//請修改下面提供的程式碼，並實做子程序“ pare_check”，該子程序接受指
//向“ infix_expr”的指針（“ R0”）。 它將檢查括號內的匹配。 如果發生錯誤
//，則將“ R0”設置為 -1。 否則，“ R0”將被設置為 0。
//注意：您必須在 data section 中分配空間並將該空間設置為堆疊，並使用
//PUSH，POP 指令存取記憶體堆疊。
	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	infix_expr: .asciz "{ -99+ [ 10 + 20 - 10 }"

	user_stack_bottom: .zero 128
.text
	.global main
	//infix_expr: .asciz "{-99+[10+20-0]}  "
	//move infix_expr here. Please refer to the question below.
main:
	BL stack_init
	LDR R0, =infix_expr
	BL pare_check
L: B L

stack_init:
	//TODO: Setup the stack pointer(sp) to user_stack.
	ldr sp, =user_stack_bottom
	add sp, sp, #128
	movs R7, #0
	BX LR
	pare_check:
	//TODO: check parentheses balance, and set the error code to R0.
	movs R1, #0
	forLoop:
	add R2, R0, R1
	ldrb R4, [R2]
	cmp R4, #0
	beq check
	cmp R4, #91
	beq left
	cmp R4, #123
	beq left
	cmp R4, #93
	beq right
	cmp R4, #125
	beq right

	add R1, R1, #1
	b forLoop

	left:
	push {R4}
	add R1, R1, #1
	add R7, R7, #1
	b forLoop

	right:
	pop {R5}
	sub R6, R4, R5
	sub R7, R7, #1
	cmp R6, #2
	beq correct
	b error

	correct:
	add R1, R1, #1
	b forLoop

	error:
	movs R0, #0
	sub R0, R0, #1
	b return

	check:
	cmp R7, 0
	beq noProblem
	b error

	noProblem:
	movs R0, #0
	b return

	return:
	BX LR
