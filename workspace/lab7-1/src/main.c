//7-1

#include "stm32l476xx.h"
#include "core_cm4.h"

void GPIO_init(){
	RCC->AHB2ENR |=	RCC_AHB2ENR_GPIOAEN;
	GPIOA->MODER &= (~(0b11 << 5*2));
	GPIOA->MODER |= (0b01 << 5*2);
	GPIOA->OSPEEDR &= (~(0b11 << 5*2));
	GPIOA->OSPEEDR |= (0b10 << 5*2);
}

void SystemClock_Config(){
	// TURN ON HSI
	RCC->CR &= ~RCC_CR_HSION; //HSI16 clock enable
	RCC->CR |= RCC_CR_HSION;  //HSI16 clock enable
	while ((RCC->CR & RCC_CR_HSIRDY) == 0); //HSI16 clock ready

	// Set SYSCLK SRC = HSI
	RCC->CFGR &= ~RCC_CFGR_SW; //system clock switch
	RCC->CFGR |= RCC_CFGR_SW_HSI; //HSI16 oscillator selection as system clock
	while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_HSI); //HSI16 oscillator used as system clock

	RCC->CFGR &= ~RCC_CFGR_HPRE;
	RCC->CFGR |= RCC_CFGR_HPRE_DIV16; // Down to 1MHz //16/16 = 1
}
void SysTick_config(){
	SysTick->LOAD = (uint32_t)(3000000);
	NVIC_SetPriority (SysTick_IRQn, (1UL << __NVIC_PRIO_BITS) - 1UL); /* set Priority for Systick Interrupt */
	SysTick->VAL   = 0UL;                                             /* Load the SysTick Counter Value */
	SysTick->CTRL  = SysTick_CTRL_CLKSOURCE_Msk |
					 SysTick_CTRL_TICKINT_Msk   |
				     SysTick_CTRL_ENABLE_Msk;                         /* Enable SysTick IRQ and SysTick Timer */
}
void SysTick_Handler(){
	unsigned int cur = (GPIOA->ODR & (1<<5));
	if(cur == 0) GPIOA->BSRR |= 1<<5;
	else         GPIOA->BRR  |= 1<<5;
}


int main(){
	GPIO_init();
	SystemClock_Config();
	SysTick_config();
	while(1);
}
