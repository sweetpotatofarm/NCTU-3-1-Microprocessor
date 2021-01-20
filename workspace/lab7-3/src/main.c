//7-3
#include <stm32l476xx.h>
#include <core_cm4.h>

#define X0 (6)
#define X1 (7)
#define X2 (8)
#define X3 (9)

#define Y0 (12)
#define Y1 (13)
#define Y2 (14)
#define Y3 (15)

unsigned int x_mask = (0x01<<X0) + (0x01<<X1) + (0x01<<X2) + (0x01<<X3);
unsigned int x_arr[4] = {X0, X1, X2, X3};
unsigned int y_arr[4] = {Y0, Y1, Y2, Y3};

extern void max7219_init(); // 7-Segment
extern void MAX7219Send(unsigned char address, unsigned char data); // 7-Segment
extern void GPIO_init7(); // 7-Segment

void keypad_init(){
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

void buzzer_init(){
	//GPIOA 0 as buzzer pin
	RCC->AHB2ENR |=	RCC_AHB2ENR_GPIOAEN;
	GPIOA->MODER &= ( ~(0b11 << 0*2));
	GPIOA->MODER |= (0b10 << 0*2);

	GPIOA->AFR[0] &= ~GPIO_AFRL_AFSEL0; // PA0: TIM2_CH1: AF1
	GPIOA->AFR[0] |= GPIO_AFRL_AFSEL0_0;
}

void GPIO_init(){
	//PC13 as button pin
	RCC->AHB2ENR |=	RCC_AHB2ENR_GPIOCEN;
	GPIOC->MODER &= (~(0b11 << 13*2));
	GPIOC->MODER |= (0b00 << 13*2);
	GPIOC->OSPEEDR &= (~(0b11 << 13*2));
	GPIOC->OSPEEDR |= (0b01 << 13*2);

	buzzer_init();
	keypad_init();
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

void NVIC_config(){
	//Enable External Interrupt
	NVIC_EnableIRQ(EXTI15_10_IRQn);
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

 void timer_init(){
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	TIM2->CR1 &= ~TIM_CR1_CMS;

	TIM2->PSC = (uint32_t) 100;
	TIM2->ARR = (uint32_t) (100-1);
	TIM2->CCR1 = (uint32_t) (50-1); /* Channel 1 */

	//mode 1
	TIM2->CCMR1 |= ( TIM_CCMR1_OC1M_2 | TIM_CCMR1_OC1M_1 ); // 0110

	TIM2->CR1 |= TIM_CR1_ARPE;
	TIM2->EGR = TIM_EGR_UG;
	TIM2->CCER = TIM_CCER_CC1E; // TURN ON /* Channel 1 */
 }

void alarm(){
	TIM2->CR1 |= TIM_CR1_CEN;
	while((GPIOC->IDR & (1 << 13)) != 0){;} // Wait Button Input
	TIM2->CR1 &= ~TIM_CR1_CEN;
}

void setSysTickValue(int tick_sec){
	if(tick_sec == 0){
		SysTick->LOAD = (uint32_t)(1);
		SysTick->VAL = 0UL;
	}
	else if(tick_sec < 0){
		return;
	}
	else{
		SysTick->LOAD = (uint32_t)(tick_sec*1000000 - 1UL); // At Least 1
		SysTick->VAL = 0UL;
	}
}

void SysTick_Start(){
	SysTick->CTRL &= ~SysTick_CTRL_ENABLE_Msk;
	SysTick->CTRL |= 1 << SysTick_CTRL_ENABLE_Pos;
}

void SysTick_Stop(){
	SysTick->CTRL &= ~SysTick_CTRL_ENABLE_Msk;
}

void SystemClock_Config(){
	// Set SYSCLK
	// TURN ON HSI
	RCC->CR &= ~RCC_CR_HSION;
	RCC->CR |= RCC_CR_HSION;
	while ((RCC->CR & RCC_CR_HSIRDY) == 0);

	// Set SYSCLK SRC = HSI
	RCC->CFGR &= ~RCC_CFGR_SW;
	RCC->CFGR |= RCC_CFGR_SW_HSI;
	while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_HSI);

	RCC->CFGR &= ~RCC_CFGR_HPRE;
	RCC->CFGR |= RCC_CFGR_HPRE_DIV16; // Down to 1MHz

	// SysTick Timer Setting
	SysTick->CTRL &= ~SysTick_CTRL_CLKSOURCE_Msk;
	SysTick->CTRL |= 1 << SysTick_CTRL_CLKSOURCE_Pos; // Processor Clock
	SysTick->CTRL &= ~SysTick_CTRL_TICKINT_Msk;
	SysTick->CTRL |= 1 << SysTick_CTRL_TICKINT_Pos; // Assert Exception

	// Set priority
	NVIC_SetPriority (SysTick_IRQn, (1UL << __NVIC_PRIO_BITS) - 1UL);
}

void SysTick_Handler(void){
	SysTick_Stop();
	alarm();

	// Clean Interrupt Request
	EXTI->PR1 |= EXTI_PR1_PIF12;
	EXTI->PR1 |= EXTI_PR1_PIF13;
	EXTI->PR1 |= EXTI_PR1_PIF14;
	EXTI->PR1 |= EXTI_PR1_PIF15;

	NVIC_EnableIRQ(EXTI15_10_IRQn);
}

void EXTI15_10_IRQHandler(void){
	// Turn Off
	//disable interrupt
	NVIC_DisableIRQ(EXTI15_10_IRQn);

	int value = keypad_scan();
	if(value >= 0){
		setSysTickValue(value);
		SysTick_Start();
	}
	else {
		// Clean Interrupt Request
		EXTI->PR1 |= EXTI_PR1_PIF12;
		EXTI->PR1 |= EXTI_PR1_PIF13;
		EXTI->PR1 |= EXTI_PR1_PIF14;
		EXTI->PR1 |= EXTI_PR1_PIF15;

		// Turn On
		NVIC_EnableIRQ(EXTI15_10_IRQn);
	}

	//get press action
	for(int i=0; i<4; i++){
		GPIOA->MODER = (GPIOA->MODER & (~(0x3 << x_arr[i]*2))) | (0b01 << x_arr[i]*2);
		GPIOA->ODR &= ~x_mask;
	}
}

void display(int input){
	for(int i=1; i<=4; i++){
		int remainder = input % 10;
		//if(i == 3) remainder+=0x80;
		MAX7219Send(i, remainder);
		input /= 10;
		//if(input == 0) break;
	}
}

void reset_display(){
	for(int i=1; i<=8; i++)
		MAX7219Send(i, 0xF);
}

int main(){
	GPIO_init();
	GPIO_init7(); //7 segment
	max7219_init();
	SystemClock_Config();
	NVIC_config();
	EXTI_config();
	timer_init();
	reset_display();
	while(1){
		int timerValue = SysTick->VAL;
		display(timerValue/10000);
	}
}

