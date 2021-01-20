#include "stm32l476xx.h"
#include "core_cm4.h"

#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (~(MASK))) | (VAL));};

void read_button() {
	while(1) {
		int pressed = GPIOC->IDR & (1 << 13);
		if (pressed == 0) {
			int k = 50000;
			while(k >= 0){
				k--;
			}
			pressed = GPIOC->IDR & (1 << 13);
			if(pressed == 0){
				break;
			}
		}
	}
}

void gpio_init() {

	// Enable GPIOA, GPIOC
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOCEN;

	// Set PA9(white), PA10(green) as AF mode
	SET_REG(GPIOA->MODER, 0x3c0000, 0x280000)

	// Set PC13(user button) as input mode
	SET_REG(GPIOC->MODER, 0x0c000000, 0x0)

	// Set PA9 PA10 to AF7(USART1-3)
	GPIOA->AFR[1] |= (7 << 4) + (7 << 8);
}


int UART_Transmit(uint8_t *arr, uint32_t size) {
	char *str = arr;
	for (int i = 0; i < size; i++) {
		USART1->TDR = str[i];
		while ((USART1->ISR & USART_ISR_TC) == 0);
	}
	return size;
}

void init_UART() {
	// Enable USART1
	RCC->APB2ENR |= RCC_APB2ENR_USART1EN;

	// CR1
	// M(0): 1 Start bit, 8 Data bits, n Stop bit
	// disable parity control
	USART1->CR1 &= ~(USART_CR1_M | USART_CR1_PCE);

	// Enable receiver and transmitter
	USART1->CR1 |= (USART_CR1_TE | USART_CR1_RE);

	// CR2 STOP bit(00): 1 stop bit
	USART1->CR2 &= ~(USART_CR2_STOP);

	// Baud rate register
	//USART1->BRR = 4000000 / 9600 ;
	// live coding
	USART1->BRR = 2000000 / 115200 ;

	// Enable UART
	USART1->CR1 |= (USART_CR1_UE);
}


void set_clock() {
	// Set system clock as MSI
	RCC->CFGR &= ~RCC_CFGR_SW;
	RCC->CFGR |= RCC_CFGR_SW_MSI;
	while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_MSI);

	// live co
	// HPRE -> 2MHz
	// prescalar( 10(0x1010): DIV8)
	RCC->CFGR &= ~(0xF << 4);
	RCC->CFGR |= 10 << 4;

	// enable HSION
	RCC->CR |= 1 << 8;

	// Set system clock as HSI
	RCC->CFGR |= 1;
	while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_HSI);
}

int main() {
	gpio_init();
	set_clock();
	init_UART();

	while (1) {
		read_button();
		UART_Transmit("Hello World!\r\n", 14);
		// print only once for long press
		while(1){
			if(GPIOC->IDR & (1 << 13))
				break;
		}
	}
}
