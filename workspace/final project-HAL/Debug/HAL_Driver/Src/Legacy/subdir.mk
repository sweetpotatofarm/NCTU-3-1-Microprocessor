################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../HAL_Driver/Src/Legacy/stm32l4xx_hal_can.c 

OBJS += \
./HAL_Driver/Src/Legacy/stm32l4xx_hal_can.o 

C_DEPS += \
./HAL_Driver/Src/Legacy/stm32l4xx_hal_can.d 


# Each subdirectory must supply rules for building sources it contributes
HAL_Driver/Src/Legacy/%.o: ../HAL_Driver/Src/Legacy/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DSTM32 -DSTM32L4 -DSTM32L476RGTx -DNUCLEO_L476RG -DDEBUG -DSTM32L476xx -DUSE_HAL_DRIVER -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc/Legacy" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/device" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/core" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/Utilities/STM32L4xx_Nucleo" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


