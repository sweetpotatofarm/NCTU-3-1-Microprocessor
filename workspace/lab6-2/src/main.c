//6-2

#include "stm32l476xx.h"
#define TIME_SEC 6.70

extern void GPIO_init(); // 7-Segment
extern void max7219_init(); // 7-Segment
extern void MAX7219Send(unsigned char address, unsigned char data); // 7-Segment

void reset_display(){
	for(int i=1; i<=8; i++)
		MAX7219Send(i, 0xF);
}

void display(int input){
	if(input > 1000000) input = 0;
	reset_display();
	for(int i=1; i<=8; i++){
		int remainder = input % 10;
		if(i == 3) remainder+=0x80;
		MAX7219Send(i, remainder);
		input /= 10;
		if(input == 0 && i>=0x03) break;
	}
}

void Timer_init(TIM_TypeDef *timer){
	timer->PSC = (uint32_t)(40000-1);// Prescaler 4000000/40000 = 每1/100秒CNT會減1
	timer->ARR = (uint32_t)(TIME_SEC*100);//CNT從100數到0需要1秒, 12.7秒就是12.7*100
	timer->EGR = TIM_EGR_UG;// reinitialize the counter
}

void Timer_start(TIM_TypeDef *timer){
	timer->CR1 |= TIM_CR1_CEN; //start timer
}

int main(){
	GPIO_init();
	max7219_init();
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;// timer6 enable
	Timer_init(TIM2);
	Timer_start(TIM2);
	while(1){
		int timerValue = TIM2->CNT;
		display(timerValue);
		if(timerValue == TIME_SEC * 100 ) break;
	}
}
