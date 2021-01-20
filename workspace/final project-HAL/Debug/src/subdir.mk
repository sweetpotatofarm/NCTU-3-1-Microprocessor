################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/stm32l4xx_it.c \
../src/syscalls.c \
../src/system_stm32l4xx.c 

CPP_SRCS += \
../src/main.cpp 

OBJS += \
./src/main.o \
./src/stm32l4xx_it.o \
./src/syscalls.o \
./src/system_stm32l4xx.o 

C_DEPS += \
./src/stm32l4xx_it.d \
./src/syscalls.d \
./src/system_stm32l4xx.d 

CPP_DEPS += \
./src/main.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: MCU G++ Compiler'
	@echo $(PWD)
	arm-none-eabi-g++ -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DSTM32 -DSTM32L4 -DSTM32L476RGTx -DNUCLEO_L476RG -DDEBUG -DSTM32L476xx -DUSE_HAL_DRIVER -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc/Legacy" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/device" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/core" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/Utilities/STM32L4xx_Nucleo" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -fno-exceptions -fno-rtti -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -DSTM32 -DSTM32L4 -DSTM32L476RGTx -DNUCLEO_L476RG -DDEBUG -DSTM32L476xx -DUSE_HAL_DRIVER -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc/Legacy" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/device" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/CMSIS/core" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/HAL_Driver/Inc" -I"/Users/hsiaochuhao/Documents/workspace/final project-HAL/Utilities/STM32L4xx_Nucleo" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


