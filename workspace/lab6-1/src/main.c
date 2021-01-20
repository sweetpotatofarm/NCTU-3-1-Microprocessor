//6-1

#include "stm32l476xx.h"

extern void GPIO_init();
extern void max7219_init();
void Delay1sUnder4MHz();
void Set_HCLK(int freq);

unsigned int freq[] = {
			0b111000000000000100001110001,
		    0b011000000000000110000110001,
		    0b011000000000001010000110001,
		    0b011000000000010000000110001,
		    0b011000000000101000000110001};

int freqNum = 0;
int n = 0;
int debounce = 0;

int main(){
	// Do initializations.
	GPIO_init();
	max7219_init();
	Set_HCLK(freqNum);


	for(;;){
		// change LED state
		GPIOA->BRR = (1<<5);
		Delay1sUnder4MHz();
		// change LED state
		GPIOA->BSRR = (1<<5);
		Delay1sUnder4MHz();
	}
}

void Set_HCLK(int freqNum){
	// 1. change to the temporary clock source if needed
	// 2. set the target clock source
	// 3. change to the target clock source

	//Temporarily use this HSI before turning off PLL
	RCC->CR |= RCC_CR_HSION;
	while((RCC->CR & RCC_CR_HSIRDY) == 0);

	RCC->CFGR = 0x00000000; //CFGR reset value
	//PLL OFF (bit24)
	RCC->CR  &= 0xFEFFFFFF;
	while (RCC->CR & 0x02000000);

	//Configure CFGR
	RCC->PLLCFGR &= 0x00000001; //off all except the MSI clock source
	RCC->PLLCFGR |= freq[freqNum];

	//PLL ON
	RCC->CR |= RCC_CR_PLLON;
	while((RCC->CR & RCC_CR_PLLRDY) == 0);

	//Set the main clock source as PLL
	RCC->CFGR |= RCC_CFGR_SW_PLL;
	while ((RCC->CFGR & RCC_CFGR_SWS_PLL) != RCC_CFGR_SWS_PLL);

}

void Delay1sUnder4MHz(){
	for(int i=0; i<10000; i++){
		// change HCLK if button pressed
		if(pressed() == 1){
			freqNum = ((freqNum+1)%5);
			Set_HCLK(freqNum);
		}
	}
}

int pressed(){
	if((GPIOC->IDR & 0b0010000000000000) == 0){
		debounce = 1;
		return 0;
	}
	else if(debounce == 1){
		debounce = 0;
		for(int i=0; i<50000; i++);
		return 1;
	}
	return 0;
}

//reference 6.4.4
/*
f(VCO clock) = f(PLL clock input) × PLLN / PLLM
PLLCLK output clock frequency = VCO frequency / PLLR
(PLLR: Main PLL division factor for PLLCLK (system clock))
(PLLM: Division factor for the main PLL and audio PLL )
(PLLN: Main PLL multiplication factor for VCO)

From the above formula, we can get:
f(PLL_R) = f(PLL clock input) × (PLLN) /( PLLM * PLLR )

SYS_CLK   PLLN   PLLM   PLLR
1(4*8/32)   8      8     4
6           12     4     2
10          20     4     2
16          32     4     2
40          80     4     2

[1:0]  PLLSRC: 01: MSI clock selected as PLL, PLLSAI1 and PLLSAI2 clock entry
[6:4]  PLLM  : 000= 1,..., 111= 8
[14:8] PLLN  : 0001000= 8,...,1010110= 86
[24]   PLLREN: 1 means PLLCLK output enable
[26:25]PLLR  : 00 = 2,...,11= 8
*/
