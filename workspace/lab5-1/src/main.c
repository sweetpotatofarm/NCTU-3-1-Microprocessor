//5-1

#include "stm32l476xx.h"
#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (~(MASK))) | (VAL));};

//These functions inside the asm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);

/*
* TODO: Show data on 7-seg via max7219_send
* Input:
* data: decimal value
* num_digs: number of digits will show on 7-seg
* Return:
* 0: success
* -1: illegal data range(out of 8 digits range)
*/

int display(int data, int num_digs){
	int i;
	for(i=1; i<num_digs; i++){
		int num = data%10;
		max7219_send(i, num);
		data = data/10;
	}

	max7219_send(num_digs, 0);

	if(data<99999999 && data>-9999999){
		return 0;
	}
	else{
		return -1;
	}
}

void main(){
	int student_id = 716026;
	GPIO_init();
	max7219_init();
	display(student_id, 8);
}
