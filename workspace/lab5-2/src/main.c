//5-2

#include "stm32l476xx.h"
#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (~(MASK))) | (VAL));};

extern void max7219_init();
extern void MAX7219Send(unsigned char address, unsigned char data);

int table[4][4] = {{1, 2, 3, 10}, {4, 5, 6, 11}, {7, 8, 9, 12}, {15, 0, 14, 13}};
char keypad_scan();

void main(){

	/* Example */
	// enable GPIOA, GPIOB
	SET_REG(RCC->AHB2ENR, RCC_AHB2ENR_GPIOAEN, RCC_AHB2ENR_GPIOAEN)
	SET_REG(RCC->AHB2ENR, RCC_AHB2ENR_GPIOBEN, RCC_AHB2ENR_GPIOBEN)

	// Set PA5, PA6, PA7 as output
	SET_REG(GPIOA->MODER, 0x0000fc00, 0x5400)

	// Set PB2, PB3, PB4, PB5 as output; PB12, PB13, PB14, PB15 as input
	SET_REG(GPIOB->MODER, 0xff000ff0, 0x550)

    // Set PB2, PB3, PB4, PB5, PB12, PB13, PB14 PB15 pull-up
	SET_REG(GPIOB->PUPDR, 0xff000ff0, 0x55000550)

	max7219_init();

	MAX7219Send(1, 0xf);
	MAX7219Send(2, 0xf);

	while(1){
		keypad_scan();
	}

}

char keypad_scan(){
	int flag;
	int debounce;
	GPIOB->ODR = 0x0000;
	flag = GPIOB->IDR & 0xf000;
	int k = 0;
	int num;
	if( flag != 0xf000 ){
		k = 45000;
		while( k >= 0 ){
			debounce = GPIOB->IDR & 0xf000;
			k--;
		}
		if( debounce != 0xf000 ){
			for( int i = 2 ; i <= 5 ; i++ ){
				GPIOB->ODR = 0xffff & ~(1<<i);
				flag = GPIOB->IDR & 0xf000;
				if( flag == 0xf000 )
					continue;
				else{
					int check = GPIOB->IDR >> 12;
					for( int j = 0 ; j < 4 ; j++ ){
						int temp = check & 0x1;
						if( temp == 1 ){
							check = check >> 1;
							continue;
						}
						else{
							num = table[j][i-2];
							if( num >= 10 ){
								MAX7219Send(1, num%10);
								MAX7219Send(2, 1);
							}
							else{
								MAX7219Send(1, num);
							}
								return num;
						}
					}
				}
			}
		}
	}
	else {
		MAX7219Send(1, 0xf);
		MAX7219Send(2, 0xf);
		return 0;
	}

}

