//8-1

#include "stm32l476xx.h"
#include "core_cm4.h"


GPIO_TypeDef* GPIO[16] = {[0xA]=GPIOA, [0xB]=GPIOB, [0xC]=GPIOC};
const unsigned int X[4] = {0xA5, 0xA6, 0xA7, 0xB6};
const unsigned int Y[4] = {0xC7, 0xA9, 0xA8, 0xBA};

void read_button() {
	int cnt = 0;
	while(1) {
		int button = GPIOC->IDR & (1 << 13);
		if (button == 0) { // 0
			cnt ++;
		} else if (cnt > (1 << 13)) { // 1 trigger
			cnt = 0;
			break;
		} else {
			cnt = 0;
		}
	}
}

void set_moder(int addr, int mode) {
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
	GPIOA->AFR[1] |= (7 << 4) + (7 << 8);
}


int UART_Transmit(uint8_t *arr, uint32_t size) {
	char *str = arr;
	for (int i = 0; i < size; i++) {
		while ((USART1->ISR & USART_ISR_TXE) == 0);
		USART1->TDR = str[i];
	}
	while ((USART1->ISR & USART_ISR_TXE) == 0);
	return size;
}

void init_UART() {
	RCC->APB2ENR |= RCC_APB2ENR_USART1EN;

	// CR1
	USART1->CR1 &= ~(USART_CR1_M | USART_CR1_PS | USART_CR1_PCE | USART_CR1_OVER8);
	USART1->CR1 |= (USART_CR1_TE | USART_CR1_RE); //open TE RE

	// CR2
	USART1->CR2 &= ~(USART_CR2_STOP); //stop bits = 1


	// original
	USART1->BRR = 4000000 / 9600 ;
	// live coding
//	USART1->BRR = 2000000 / 115200 ;


	/* In asynchronous mode, the following bits must be kept cleared:
	- LINEN and CLKEN bits in the USART_CR2 register,
	- SCEN, HDSEL and IREN bits in the USART_CR3 register.*/
	USART1->CR2 &= ~(USART_CR2_LINEN | USART_CR2_CLKEN);

	// Enable UART
	USART1->CR1 |= (USART_CR1_UE);
}


void set_clock() {
	// Set system clock as MSI
	RCC->CFGR &= ~3;

//	// live co
//	// HPRE -> 2MHz
//	RCC->CFGR &= ~(0xF << 4);
//	RCC->CFGR |= 10 << 4;
//
//	// enable HSION
//	RCC->CR |= 1 << 8;
//
//	// Set system clock as PLL
//	RCC->CFGR |= 1;

}

int main() {
	gpio_init();
	set_clock();
	init_UART();

	while (1) {
		read_button();
		UART_Transmit((uint8_t*)"Hello World!\r\n", 14);
	}
}
