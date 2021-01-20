################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_UPPER_SRCS += \
../startup/startup_stm32l476xx.S 

OBJS += \
./startup/startup_stm32l476xx.o 

S_UPPER_DEPS += \
./startup/startup_stm32l476xx.d 


# Each subdirectory must supply rules for building sources it contributes
startup/%.o: ../startup/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DSTM32 -DSTM32L4 -DSTM32L476RGTx -DNUCLEO_L476RG -DDEBUG -DSTM32L476xx -DUSE_HAL_DRIVER -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc/Legacy" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/device" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/core" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/Utilities/STM32L4xx_Nucleo" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


