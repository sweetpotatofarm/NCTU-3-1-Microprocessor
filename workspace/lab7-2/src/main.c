//7-2
#include "stm32l476xx.h"
#include "core_cm4.h"

#define X0 (6)
#define X1 (7)
#define X2 (8)
#define X3 (9)
#define Y0 (12)
#define Y1 (13)
#define Y2 (14)
#define Y3 (15)

unsigned int x_mask = (0x01<<X0) + (0x01<<X1) + (0x01<<X2) + (0x01<<X3);
int x_arr[4] = {X0, X1, X2, X3};
int y_arr[4] = {Y0, Y1, Y2, Y3};

void blink_times(int value){
	for(int i=0; i<value; i++){
		GPIOA->BSRR = 1 << 5;
		Delay05s();
		GPIOA->BRR = 1 << 5;
		Delay05s();
	}
	GPIOA->BSRR = 1 << 5;
}


int keypad_scan(){

	for(int i=0; i<4; i++){
		GPIOA->ODR = (x_mask) | ((0x01<<x_arr[i])); // set high for z
		GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[i]*2))) | (0b00 << x_arr[i]*2);
	}

	int press = 0;
	int sum = 0;

	GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[0]*2))) | (0b01 << x_arr[0]*2);
	GPIOA->ODR = (x_mask) & (~(0x01 << X0)); // ACTIVE_LOW
	if((GPIOA->IDR & (0x01 << Y0))== 0){ sum+=1; press=1; return sum; } // ACTIVE_LOW
	if((GPIOA->IDR & (0x01 << Y1))== 0){ sum+=4; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y2))== 0){ sum+=7; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y3))== 0){ sum+=15; press=1; return sum; }
	GPIOA->ODR = (x_mask) | ((0x01<<X0)); // set high for z
	GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[0]*2))) | (0b00 << x_arr[0]*2);

	GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[1]*2))) | (0b01 << x_arr[1]*2);
	GPIOA->ODR = (x_mask) & (~(0x01 << X1)); // ACTIVE_LOW
	if((GPIOA->IDR & (0x01 << Y0))== 0){ sum+=2; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y1))== 0){ sum+=5; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y2))== 0){ sum+=8; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y3))== 0){ sum+=0; press=1; return sum; }
	GPIOA->ODR = (x_mask) | ((0x01<<X1)); // set high for z
	GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[1]*2))) | (0b00 << x_arr[1]*2);

	GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[2]*2))) | (0b01 << x_arr[2]*2);
	GPIOA->ODR = (x_mask) & (~(0x01 << X2)); // ACTIVE_LOW
	if((GPIOA->IDR & (0x01 << Y0))== 0){ sum+=3; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y1))== 0){ sum+=6; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y2))== 0){ sum+=9; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y3))== 0){ sum+=14; press=1; return sum; }
	GPIOA->ODR = (x_mask) | ((0x01<<X2)); // set high for z
	GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[2]*2))) | (0b00 << x_arr[2]*2);

	GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[3]*2))) | (0b01 << x_arr[3]*2);
	GPIOA->ODR = (x_mask) & (~(0x01 << X3)); // ACTIVE_LOW
	if((GPIOA->IDR & (0x01 << Y0))== 0){ sum+=10; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y1))== 0){ sum+=11; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y2))== 0){ sum+=12; press=1; return sum; }
	if((GPIOA->IDR & (0x01 << Y3))== 0){ sum+=13; press=1; return sum; }
	GPIOA->ODR = (x_mask) | ((0x01<<X3)); // set high for z
	GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[3]*2))) | (0b00 << x_arr[3]*2);

	if(press == 0) return -1;
	else return sum;
}


void init_GPIO(){
	RCC->AHB2ENR |=	RCC_AHB2ENR_GPIOAEN;
	GPIOA->MODER &= (~(0b11 << 5*2));
	GPIOA->MODER |= (0b01 << 5*2);
	GPIOA->OSPEEDR &= (~(0b11 << 5*2));
	GPIOA->OSPEEDR |= (0b10 << 5*2);

	// keypad init
	// X as OUTPUT // OUTPUT GPIOA 6 7 8 9
	RCC->AHB2ENR = RCC->AHB2ENR | (0x1 << 0);
	for(int i=0; i<4; i++){
		GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[i]*2))) | (0b01 << x_arr[i]*2);
		GPIOA->OTYPER = (GPIOA->OTYPER & (~(0x1 << x_arr[i]))) | (0b01 << x_arr[i]);
		GPIOA->PUPDR = (GPIOA->PUPDR & (~(0x3 << x_arr[i]*2))) | (0b01 << x_arr[i]*2);
		GPIOA->OSPEEDR = (GPIOA->OSPEEDR & (~(0x3 << x_arr[i]*2))) | (0b01 << x_arr[i]*2);
	}

	// Y as INPUT // INPUT GPIOA 12 13 14 15
	RCC->AHB2ENR = RCC->AHB2ENR | (0x1 << 0);
	for(int i=0; i<4; i++){
		GPIOA->MODER = (GPIOA->MODER & (~(0x3 << y_arr[i]*2))) | (0b00 << y_arr[i]*2);
		GPIOA->OTYPER = (GPIOA->OTYPER & (~(0x1 << y_arr[i]))) | (0b00 << y_arr[i]);
		GPIOA->PUPDR = (GPIOA->PUPDR & (~(0x3 << y_arr[i]*2))) | (0b01 << y_arr[i]*2);
		GPIOA->OSPEEDR = (GPIOA->PUPDR & (~(0x3 << y_arr[i]*2))) | (0b01 << y_arr[i]*2);
	}

	//get press action
	for(int i=0; i<4; i++){
		GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[i]*2))) | (0b01 << x_arr[i]*2);
		GPIOA->ODR &= ~x_mask;
	}
}
void Delay05s(){
	int i = 0;
	for(i=0; i<100000; i++);
}

void EXTI_config(){
	RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;

	SYSCFG->EXTICR[3] |= SYSCFG_EXTICR4_EXTI12_PA;
	SYSCFG->EXTICR[3] |= SYSCFG_EXTICR4_EXTI13_PA;
	SYSCFG->EXTICR[3] |= SYSCFG_EXTICR4_EXTI14_PA;
	SYSCFG->EXTICR[3] |= SYSCFG_EXTICR4_EXTI15_PA;

	EXTI->IMR1 |= EXTI_IMR1_IM12;
	EXTI->IMR1 |= EXTI_IMR1_IM13;
	EXTI->IMR1 |= EXTI_IMR1_IM14;
	EXTI->IMR1 |= EXTI_IMR1_IM15;

	EXTI->FTSR1 |= EXTI_FTSR1_FT12;
	EXTI->FTSR1 |= EXTI_FTSR1_FT13;
	EXTI->FTSR1 |= EXTI_FTSR1_FT14;
	EXTI->FTSR1 |= EXTI_FTSR1_FT15;
}
void NVIC_config(){
	//Enable External Interrupt
	NVIC_EnableIRQ(EXTI15_10_IRQn);
	//Set Interrupt Priority
	//NVIC_SetPriority(EXTI15_10_IRQn, (1UL << __NVIC_PRIO_BITS) - 1UL);

}
void EXTI15_10_IRQHandler(void){
	blink_times(keypad_scan());

	//clear
	EXTI->PR1 |= EXTI_PR1_PIF12;
	EXTI->PR1 |= EXTI_PR1_PIF13;
	EXTI->PR1 |= EXTI_PR1_PIF14;
	EXTI->PR1 |= EXTI_PR1_PIF15;

	// Get Press Action
	for(int i=0; i<4; i++){
		GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[i]*2))) | (0b01 << x_arr[i]*2);
		GPIOA->ODR &= ~x_mask;
	}
}
int main()
{
	NVIC_config();
	EXTI_config();
	init_GPIO();
	GPIOA->BSRR = 1 << 5;
	while(1);
}
