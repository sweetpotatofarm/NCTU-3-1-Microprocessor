################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Utilities/STM32L4xx_Nucleo/stm32l4xx_nucleo.c 

OBJS += \
./Utilities/STM32L4xx_Nucleo/stm32l4xx_nucleo.o 

C_DEPS += \
./Utilities/STM32L4xx_Nucleo/stm32l4xx_nucleo.d 


# Each subdirectory must supply rules for building sources it contributes
Utilities/STM32L4xx_Nucleo/%.o: ../Utilities/STM32L4xx_Nucleo/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DSTM32 -DSTM32L4 -DSTM32L476RGTx -DNUCLEO_L476RG -DDEBUG -DSTM32L476xx -DUSE_HAL_DRIVER -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc/Legacy" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/device" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/core" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/Utilities/STM32L4xx_Nucleo" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


