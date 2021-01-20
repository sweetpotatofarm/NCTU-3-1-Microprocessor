#include "stm32l476xx.h"
#include "core_cm4.h"

#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (~(MASK))) | (VAL));};

extern void GPIO_init();
extern void max7219_init();
extern void MAX7219Send(unsigned char address, unsigned char data);

int display(int data, int num_digs);

void HX711_init(void) {

	// PA11 clock(output), PA12 input
	SET_REG(GPIOA->MODER, 0x03c00000, 0x00400000)
	SET_REG(GPIOA->PUPDR, 0x03c00000, 0x01000000)

	SET_REG(GPIOA->ODR, 0x0800, 0x0800)
	int k = 10000;
	while(k>=0)k--;
	SET_REG(GPIOA->ODR, 0x0800, 0x0000)

}

int32_t HX711_value(void) {

	int data = 0;

    // PA12 == 1
	while( (GPIOA->IDR >> 12) & 0x1 == 1);
	for (int i=0; i<24 ; i++) {
		SET_REG(GPIOA->ODR, 0x0800, 0x0800)
		data = data << 1;
		if( (GPIOA->IDR >> 12) & 0x1 == 1)
			data ++;

		SET_REG(GPIOA->ODR, 0x0800, 0x0000)
	}

	data = data ^ 0x800000;

	return data;
}

void main(){
	GPIO_init();
	max7219_init();
	HX711_init();
	int i = 0;
	while(1){
		int value = HX711_value();
		display(value, 8);
		int k = 10000;
		while(k>=0)k--;
	}
}

int display(int data, int num_digs){
	for( int i = 1 ; i <= num_digs ; i=i+1 ){
			int num = data % 10;
			MAX7219Send(i, num);
			data = data / 10;
	}
	return 0;

}
