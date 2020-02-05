# BareMin_STM32 - Compile only

Bare minimum project for STM32 devices: Setup with vector table for f4 device family. Used to make sure that the mem is mapped out 
correctly. This project requires the ARM embedded tool chain and the windows linux runtime terminal. 

No additional addresses or externals are setup - this project acts as nothing but a "ready" to compile bare minimum project. GPIO/CLOCK/FPU 
ext are NOT mapped and created. It will run - but if uploaded to your device it will do NOTHING and likely 'brick' it - due to lack of clock.

Project functions as a reference - to change the tables just switch out for the stm32 chip set - these can be pulled from STM32cube easily.

Will work easily with other ARM cortex devices provided appropriate changes are made.  

Use windows Linux::Ubunto to compile - shift - linux terminal -> then run: Command: make -j4 -l4
