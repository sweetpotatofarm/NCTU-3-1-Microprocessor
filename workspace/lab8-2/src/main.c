//8-2

#include "stm32l476xx.h"
#include "core_cm4.h"

int freq = 500;
int counting = 0;

/* GPIO */

GPIO_TypeDef* GPIO[16] = {[0xA]=GPIOA, [0xB]=GPIOB, [0xC]=GPIOC};
const unsigned int X[4] = {0xA5, 0xA6, 0xA7, 0xB6};
const unsigned int Y[4] = {0xC7, 0xA9, 0xA8, 0xBA};


void read_button() {
	int cnt = 0;
	while(1) {
		int button = GPIOC->IDR & (1 << 13);
		if (button == 0) { // 0
			cnt ++;
			if (cnt > (1 << 13)) break;
		} else if (cnt > (1 << 13)) { // 1 trigger
			cnt = 0;
			return;
		} else { // 1
			cnt = 0;
		}
	}
}

void set_moder(int addr, int mode) { // mode: 0 input, 1 output
	int x = addr >> 4, k = addr & 0xF;
	RCC->AHB2ENR |= 1<<(x-10);
	GPIO[x]->MODER &= ~(3 << (2*k));
	GPIO[x]->MODER |= (mode << (2*k));

	if (mode == 0) {
		GPIO[x]->PUPDR &= ~(3 << (2*k));
		GPIO[x]->PUPDR |= (2 << (2*k));
	}
}

void gpio_init() {
	set_moder(0xA9, 2); // TX
	set_moder(0xAA, 2); // RX
	set_moder(0xCD, 0);
	set_moder(0xA0, 3);
	GPIOA->AFR[1] |= (7 << 4) + (7 << 8);
	GPIOA->ASCR |= (1<<0); //this signal has to be handeled by ADC
}

/* uart */
int UART_Transmit(uint8_t *arr, uint32_t size) {
	char *str = arr;
	int ret = 0;
	for (int i = 0; str[i] && i < size; i ++) {
		while ((USART1->ISR & USART_ISR_TXE) == 0);
		USART1->TDR = str[i];
		ret ++;
	}
	while ((USART1->ISR & USART_ISR_TXE) == 0);
	return ret;
}

void init_UART() {
	RCC->APB2ENR |= RCC_APB2ENR_USART1EN;

	// CR1
	USART1->CR1 &= ~(USART_CR1_M | USART_CR1_PS | USART_CR1_PCE | USART_CR1_TE | USART_CR1_RE | USART_CR1_OVER8);
	USART1->CR1 |= (USART_CR1_TE | USART_CR1_RE);

	// CR2
	USART1->CR2 &= ~(USART_CR2_STOP);

	// BRR
	USART1->BRR &= ~(0xFF);
	//!
	USART1->BRR |= 1000000L / 9600L ;

	/* In asynchronous mode, the following bits must be kept cleared:
	- LINEN and CLKEN bits in the USART_CR2 register,
	- SCEN, HDSEL and IREN bits in the USART_CR3 register.*/
	USART1->CR2 &= ~(USART_CR2_LINEN | USART_CR2_CLKEN);

	// Enable UART
	USART1->CR1 |= (USART_CR1_UE);
}


void init_ADC(){
	RCC->AHB2ENR |= RCC_AHB2ENR_ADCEN;

	ADC1->CFGR &= ~(ADC_CFGR_CONT); // no continue
	ADC1->CFGR |= 0 << 3;
	ADC1->CFGR &= ~ADC_CFGR_ALIGN;


	ADC1-> CFGR &= ~ADC_CFGR_RES;
	//ADC1-> CFGR |= ADC_CFGR_RES_1; // 8 bit resolution *** live coding ***
	/*
	* 00 => 12 bit
	* 01 => 10 bit
	* 10 => 8 bit
	* 11 => 6 bit
	*/

	ADC123_COMMON->CCR |= 1 << 16; // ckmode
	ADC123_COMMON->CCR |= 4 << 8; // delay

	ADC1->SQR1 |= 0<<0; //seq length = 1
	ADC1->SQR1 |= 5<<6; //channel 5

	//ADC1->SMPR1 |= 2<<15;


	ADC1->CR &= ~ADC_CR_DEEPPWD; //deep power down off
	ADC1->CR |= ADC_CR_ADVREGEN;

	for (int i=0; i<200; i++);


	ADC1->IER |= ADC_IER_EOCIE;
	NVIC_EnableIRQ(ADC1_2_IRQn); //at the end of the seq will exec ADC_1_2_IRQHandler

	ADC1->CR |= ADC_CR_ADEN;
	while (!(ADC1->ISR & ADC_ISR_ADRDY)); //wait until ADC1->ISR == 1
	ADC1->CR |= ADC_CR_ADSTART;
}

int ADC_data = 1;

void ADC1_2_IRQHandler(){
	// UART_Transmit((uint8_t*)"Scan\r\n", 20);
	NVIC_ClearPendingIRQ(ADC1_2_IRQn);
	for (int i=0; i<(1<<15); i++);
	ADC_data = ADC1->DR;
	ADC1->ISR |= ADC_ISR_EOC;
	// UART_Transmit_Number(ADC_data);

	NVIC_ClearPendingIRQ(ADC1_2_IRQn);
}

void UART_Transmit_Number(int n) {
	int dig[12] = {0};
	for (int i = 0; i < 12; i ++) {
		dig[i] = n % 10;
		n /= 10;
	}
	for (int i = 11; i >= 0; i --) {
		char c = '0' + dig[i];
		UART_Transmit((uint8_t*)&c, 1);
	}
	UART_Transmit((uint8_t*)"\r\n", 2);
}

void set_clock() {
	// Set system clock as MSI
	RCC->CFGR &= ~3;

	// HPRE -> 1MHz
	RCC->CFGR &= ~(0xF << 4);
	RCC->CFGR |= 11 << 4;

	// enable HSION
	RCC->CR |= 1 << 8;

	// Set system clock as PLL
	RCC->CFGR |= 1;
}

void systick_config() {
	SysTick->CTRL |= 7;
	SysTick->LOAD = 500000;
	 NVIC_SetPriority(SysTick_IRQn, 1);
	 NVIC_SetPriority(ADC1_2_IRQn, 0);
}

void SysTick_Handler() {
	ADC1->CR |= ADC_CR_ADSTART; //use systick to trigger
}

int main() {
	gpio_init();
	set_clock();
	systick_config();

	init_UART();
	init_ADC();

	UART_Transmit((uint8_t*)"Start\r\n", 20);

	while (1) {
		read_button();

		// UART_Transmit((uint8_t*)"Button\r\n", 20);
		UART_Transmit_Number(ADC_data);
	}

}
