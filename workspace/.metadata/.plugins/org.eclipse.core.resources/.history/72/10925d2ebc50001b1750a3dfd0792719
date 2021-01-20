#include "stm32l476xx.h"
#include "core_cm4.h"

#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (~(MASK))) | (VAL));};
#define BUZZER_PIN (0)
#define BUZZER_BASE (GPIOA)

extern void GPIO_init();
extern void max7219_init();
extern void MAX7219Send(unsigned char address, unsigned char data);

int count_time = 11;
int n = 0;
int div = 0;
int remainder = 0;
int buzz = 0;
int option = 0;

int display(int data, int num_digs);

void HX711_init(void) {

	// PA11 clock(output), PA12 input
	SET_REG(GPIOA->MODER, 0x03c00000, 0x00400000)
	//SET_REG(GPIOA->PUPDR, 0x03c00000, 0x01000000)

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

	//data = data ^ 0x800000;

	return data;
}

void timerInit(){
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	TIM2->CR1 &= ~TIM_CR1_CMS; // Edge-Aligned

	TIM2->PSC = (uint32_t) 100;
	TIM2->ARR = (uint32_t) (100-1);
	TIM2->CCR1 = (uint32_t) (50-1);

	// set mode 1
	TIM2->CCMR1 |= ( TIM_CCMR1_OC1M_2 | TIM_CCMR1_OC1M_1 ); // 0110

	// enable auto reload
	TIM2->CR1 |= TIM_CR1_ARPE;
	TIM2->EGR = TIM_EGR_UG;
	TIM2->CCER = TIM_CCER_CC1E; // TURN ON /* Channel 1 */
}

void buzzerInit(){

	// enable GPIOA
	RCC->AHB2ENR |=	RCC_AHB2ENR_GPIOAEN;

	// set buzzer (PA0) as AF(10)
	BUZZER_BASE->MODER &= ( ~(0b11 << BUZZER_PIN*2));
	BUZZER_BASE->MODER |= (0b10 << BUZZER_PIN*2);

	//
	BUZZER_BASE->AFR[0] &= ~GPIO_AFRL_AFSEL0; // PA0: TIM2_CH1: AF1
	BUZZER_BASE->AFR[0] |= GPIO_AFRL_AFSEL0_0; // PA0: TIM2_CH1: AF1
}

void SetSysTickValue(){
	SysTick->CTRL &= ~SysTick_CTRL_ENABLE_Msk;

	if( n == div ){
		SysTick->LOAD = (uint32_t)(remainder * 1000000 - 1);
		SysTick->VAL = 0;
		buzz = 1;
	}
	else{
		SysTick->LOAD = (uint32_t)(16 * 1000000 - 1);
		SysTick->VAL = 0;
	}

}


void SysTick_Start(){
	SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk;
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

	// Systick
	// (1) set processor clock as source
	// (2) asserts the SysTick exception request -> enable
	SysTick->CTRL = SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_TICKINT_Msk;

}

void alarm_handler(){
	// start timer -> turn on buzzer
	TIM2->CR1 |= TIM_CR1_CEN;
	for( int i = 1; i <= 8; i++ )
			MAX7219Send(i, 0xf);
	if( option == 0 )
		MAX7219Send(1, 0xc);
	else
		MAX7219Send(1, 0xb);

	while(HX711_value()>=20000);

	// stop timer -> turn off buzzer
	TIM2->CR1 &= ~TIM_CR1_CEN;
	buzz = 0;
	n = 0;

	int k = 50000;
	while(k>=0)k--;
}

void SysTick_Handler(void){
	SysTick->CTRL &= ~SysTick_CTRL_ENABLE_Msk;
	if(buzz == 1)
		alarm_handler();
	else
		n++;
	SetSysTickValue();
	SysTick_Start();
}

void main(){
	div = count_time / 16;
	remainder = count_time % 16;
	SystemClock_Config();
	GPIO_init();
	max7219_init();
	HX711_init();
	timerInit();
	buzzerInit();
	// user button (PC13)
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOCEN;

	// PC13 as input
	GPIOC->MODER &= ( ~(0b11 << 13*2));
	GPIOC->MODER |= (0b00 << 13*2);

	// PC13 as pull up
	GPIOC->PUPDR &= ( ~(0b11 << 13*2));
	GPIOC->PUPDR |= (0b01 << 13*2);
	int last_value = 0;
	int i = 0;
	int flag = 1;
	int last_weight = 0;
	SET_REG(GPIOA->MODER, 0xc0000, 0x40000)
	SET_REG(GPIOA->ODR, 0x200, 0x0)
	display(count_time, 2);
	SetSysTickValue();
	SysTick_Start();
	while(1){
		int value = HX711_value();
		option = 0;
		//display(value, 8);
		if(div == n)
			display(SysTick->VAL / 1000000, 2);
		else
			display(SysTick->VAL / 1000000 + (div - n - 1) * 16 + remainder, 2);
		if(i == 1){
			if( value >= 5000 && value <= 85000){
				option = 1;
				alarm_handler();
			}
			else{
				int difference = value - last_value;
				if(difference < 0) difference *= -1;
				if(difference > 50000){
					if( flag == 2){
						flag = 1;
						if(last_weight - value < 4000){
							alarm_handler();
						}
						n = 0;
						SetSysTickValue();
						SysTick_Start();
					}
					else if(flag == 1){
						flag = 2;
						n = 0;
						SetSysTickValue();
						last_weight = last_value;
					}
				}
			}
			last_value = value;
		}
		if(i == 0){
			i = 1;
			last_value = value;
		}
		//500
		int k = 50;
		while(k>=0){
			//1000
			int j = 1000;
			if(flag == 1){
				if(div == n)
					display(SysTick->VAL / 1000000, 2);
				else
					display(SysTick->VAL / 1000000 + (div - n - 1) * 16 + remainder, 2);
			}
			if(flag == 2)
				display(count_time, 2);
			while(j>=0)j--;
			k--;
		};
	}
}

int display(int data, int num_digs){
	for( int i = 1; i <= 8; i++ )
			MAX7219Send(i, 0xf);
	for( int i = 1 ; i <= num_digs ; i=i+1 ){
			int num = data % 10;
			MAX7219Send(i, num);
			data = data / 10;
	}
	return 0;

}
