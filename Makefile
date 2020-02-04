TARGET = Embedded_Events

OPT = -Og
DEBUG = 1
BUILD_DIR = build

# cpu
CPU = -mcpu=cortex-m4

# fpu
FPU = -mfpu=fpv4-sp-d16

# float-abi
FLOAT-ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# GNU ARM Embedded Toolchain(s) - Full general include for ubunto builds.

################################# specs none to get arround linker issue with c++ and C names spaces. ##########

CC=arm-none-eabi-gcc --specs=nosys.specs

CXX=arm-none-eabi-g++ --specs=nosys.specs

LD=arm-none-eabi-ld

AR=arm-none-eabi-ar

AS=arm-none-eabi-as

CP=arm-none-eabi-objcopy

OD=arm-none-eabi-objdump

NM=arm-none-eabi-nm

SIZE=arm-none-eabi-size

A2L=arm-none-eabi-addr2line

#################################
# Working directories
#################################
ROOT		 = .

SRC_DIR		 = Src 

OBJECT_DIR	 = $(ROOT)/Build

BIN_DIR		 = $(ROOT)/Build

ASOURCES = \
startup_stm32f446xx.s \
#usr/lib/gcc/arm-none-eabi/6.3.1/thumb/v7e-m/crti.o \ #std reference - do not use. 

#could simplify
CSOURCES =  \
core/main/main.c\
core/main/systemInit.c\

CSOURCES += \




#################################
# Object List
#################################

OBJECTS=$(addsuffix .o,$(addprefix $(OBJECT_DIR)/$(TARGET)/,$(basename $(ASOURCES))))

# OBJECTS+=$(addsuffix .o,$(addprefix $(OBJECT_DIR)/$(TARGET)/,$(basename $(CSOURCES))))
# subsititure path with below. 
OBJECTS += $(patsubst %.c, $(OBJECT_DIR)/$(TARGET)/%.o, $(CSOURCES))

OBJECTS+=$(addsuffix .o,$(addprefix $(OBJECT_DIR)/$(TARGET)/,$(basename $(CXXSOURCES))))


#################################
# Target Output Files
#################################

TARGET_ELF=$(BIN_DIR)/$(TARGET).elf
TARGET_HEX=$(BIN_DIR)/$(TARGET).hex
TARGET_BIN=$(BIN_DIR)/$(TARGET).bin

#################################
# Flags
#################################

MCFLAGS=-mcpu=cortex-m4 -mthumb

OPTIMIZE = -Os

# DEFS=-DTARGET_STM32F10X_MD -D__CORTEX_M4 -DWORDS_STACK_SIZE=200 -DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER
DEFS=-DSTM32F446xx

CFLAGS=-c $(MCFLAGS) $(DEFS) $(OPTIMIZE) $(addprefix -I,$(INCLUDE_DIRS)) -std=c99

CXXFLAGS=-c $(MCFLAGS) $(DEFS) $(OPTIMIZE) $(addprefix -I,$(INCLUDE_DIRS)) -std=c++11

CXXFLAGS+=-U__STRICT_ANSI__

LDSCRIPT=$(ROOT)/STM32F446RETx_FLASH.ld

LDFLAGS =-T $(LDSCRIPT) $(MCFLAGS) -lm -lc $(ARCH_FLAGS)  $(LTO_FLAGS)  $(DEBUG_FLAGS) -static  -Wl,-gc-sections

DEPDIR = $(BUILD_DIR)/deps
DEPFLAGS= -MT $@ -MMD -MP -MF $(^:%=$(DEPDIR)/%.d)

################################# -nostartfiles  --specs=nano.specs --specs=rdimon.specs
# Build
#################################

#Main Mem
$(TARGET_HEX): $(TARGET_ELF)

	$(CP) -O ihex --set-start 0x8000000 $< $@



$(TARGET_ELF): $(OBJECTS)

	$(CXX) -o $@ $^ $(LDFLAGS)

	$(SIZE) $(TARGET_ELF)


$(OBJECT_DIR)/$(TARGET)/%.o: %.c

	@mkdir -p $(dir $@) $(dir $(^:%=$(DEPDIR)/%.d))

	@echo %% $(notdir $<)

	$(CXX) $(DEPFLAGS) -c -o $@ $(CXXFLAGS) $<


$(OBJECT_DIR)/$(TARGET)/%.o: %.cpp

	@mkdir -p $(dir $@) $(dir $(^:%=$(DEPDIR)/%.d))

	@echo %% $(notdir $<)

	$(CXX) $(DEPFLAGS) -c -o $@ $(CXXFLAGS) $<

$(OBJECT_DIR)/$(TARGET)/%.o: %.s

	@mkdir -p $(dir $@) $(dir $(^:%=$(DEPDIR)/%.d))

	@echo %% $(notdir $<)

	@$(CC) -c -o $@ $(CFLAGS) $<

$(DEPDIR):
	@mkdir -p $@

DEPFILES := $(CSOURCES:%.c=$(DEPDIR)/%.d) $(CXXSOURCES:%.cpp=$(DEPDIR)/%.d)
$(DEPFILES):



#################################

# Recipes

#################################

.PHONY: all flash clean print

print:
	@echo DEPFILES = $(DEPFILES)
	@echo OBJECTS  = $(OBJECTS)

all: $(TARGET_HEX)


clean:

	#rm -f $(OBJECTS) $(TARGET_ELF) $(TARGET_HEX) $(BIN_DIR)/output.map
	rm -rf $(BIN_DIR)



flash: $(TARGET_HEX)

	stty raw ignbrk -echo 921600 < $(SERIAL_DEVICE)

	stm32flash -w $(TARGET_HEX) -v -g 0x0 -b 921600 $(SERIAL_DEVICE)

-include $(DEPFILES)
