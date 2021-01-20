#include "stm32l476xx.h"
#include "core_cm4.h"
#include <string.h>

GPIO_TypeDef* GPIO[16] = {[0xA]=GPIOA, [0xB]=GPIOB, [0xC]=GPIOC};
const unsigned int X[4] = {0xA5, 0xA6, 0xA7, 0xB6};
const unsigned int Y[4] = {0xC7, 0xA9, 0xA8, 0xBA};

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
	set_moder(0xA5, 1);
	set_moder(0xA0, 3);
	GPIOA->ODR &= ~(1 << 5);
	GPIOA->AFR[1] |= (7 << 4) + (7 << 8);
	GPIOA->ASCR |= (1<<0);
}

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

char buf[300];

char receive_char() {

	while (!(USART1->ISR & USART_ISR_RXNE)); //read data register not empty
	USART1->ISR = USART1->ISR & ~USART_ISR_RXNE;
	return USART1->RDR & 0xFF;
}

void read_cmd() {
	int ptr = 0;
	char c;
	do {
		c = receive_char();
		if (c == 127){ // backspace
			if (ptr) ptr--;
		}
		else{
			buf[ptr++] = c;
		}
		UART_Transmit((uint8_t*)&c, 1);
	} while (c != '\n' && c != '\r');
	buf[ptr++] = '\0';
	UART_Transmit((uint8_t*)"\r\n", 2);
}

void init_UART() {
	RCC->APB2ENR |= RCC_APB2ENR_USART1EN;

	// CR1
	USART1->CR1 &= ~(USART_CR1_M | USART_CR1_PS | USART_CR1_PCE | USART_CR1_TE | USART_CR1_RE | USART_CR1_OVER8);
	USART1->CR1 |= (USART_CR1_TE | USART_CR1_RE);

	// CR2
	USART1->CR2 &= ~(USART_CR2_STOP);

	// CR3
	USART1->CR3 &= ~(USART_CR3_RTSE | USART_CR3_CTSE | USART_CR3_ONEBIT);

	// BRR
	USART1->BRR &= ~(0xFF);
	USART1->BRR |= (1000000L / 9600L) & 0xFFFF ;

	/* In asynchronous mode, the following bits must be kept cleared:
	- LINEN and CLKEN bits in the USART_CR2 register,
	- SCEN, HDSEL and IREN bits in the USART_CR3 register.*/
	USART1->CR2 &= ~(USART_CR2_LINEN | USART_CR2_CLKEN);
	USART1->CR3 &= ~(USART_CR3_SCEN | USART_CR3_HDSEL | USART_CR3_IREN);

	// Enable UART
	USART1->CR1 |= (USART_CR1_UE);
}

void init_ADC(){
	RCC->AHB2ENR |= RCC_AHB2ENR_ADCEN;

	ADC1->CFGR &= ~(ADC_CFGR_CONT); // continue
	ADC1->CFGR |= 0 << 3;
	ADC1->CFGR &= ~ADC_CFGR_ALIGN;

	ADC123_COMMON->CCR |= 1 << 16; // ckmode
	ADC123_COMMON->CCR |= 4 << 8; // delay

	ADC1->SQR1 |= 0<<0;
	ADC1->SQR1 |= 5<<6;

	ADC1->SMPR1 |= 2<<15;

	ADC1->CR &= ~ADC_CR_DEEPPWD;
	ADC1->CR |= ADC_CR_ADVREGEN;

	for (int i=0; i<200; i++);

	ADC1->IER |= ADC_IER_EOCIE;
	NVIC_EnableIRQ(ADC1_2_IRQn);

	ADC1->CR |= ADC_CR_ADEN;
	while (!(ADC1->ISR & ADC_ISR_ADRDY));
	ADC1->CR |= ADC_CR_ADSTART;
}

int ADC_data = 1;

void ADC1_2_IRQHandler(){
	NVIC_ClearPendingIRQ(ADC1_2_IRQn);
	ADC_data = ADC1->DR;
	ADC1->ISR |= ADC_ISR_EOC;
	UART_Transmit_Number(ADC_data);

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

	// Set system clock as HSI
	RCC->CFGR |= 1;
}

void systick_enable() {
	SysTick->CTRL |= 1;
}

void systick_disable() {
	SysTick->CTRL &= ~1;
}

void systick_config() {
	SysTick->CTRL |= 7;
	SysTick->LOAD = 500000;
	 NVIC_SetPriority(SysTick_IRQn, 1);
	 NVIC_SetPriority(ADC1_2_IRQn, 0);
}

void SysTick_Handler() {
	ADC1->CR |= ADC_CR_ADSTART;
}

int main() {
	gpio_init();
	set_clock();
	systick_config();
	init_UART();
	init_ADC();
	systick_disable();

	UART_Transmit((uint8_t*)"Start\r\n", 250);

	while (1) {
		UART_Transmit((uint8_t*)"> ", 2);
		read_cmd();

		if (buf[0] == '\r'){
			// no cmd, do nothing
		}
		else if (strcmp(buf, "showid\r")==0) {
			UART_Transmit((uint8_t*)"0716026\r\n", 15);
		} else if (strcmp(buf, "light\r") == 0) {
			systick_enable();
			char c;
			do {
				c = receive_char();
			} while (c != 'q');
			systick_disable();
		} else if (strcmp(buf, "led on\r") == 0) {
			GPIOA->ODR |= (1 << 5);
		} else if (strcmp(buf, "led off\r") == 0) {
			GPIOA->ODR &= ~(1 << 5);
		} else {
			UART_Transmit((uint8_t*)"Unknown Command\r\n", 20);
		}
	}
}
