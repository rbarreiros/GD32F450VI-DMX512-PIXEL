$(info "lib/Rules.mk")
$(info $$MAKE_FLAGS [${MAKE_FLAGS}])

PREFIX ?= arm-none-eabi-

CC	= $(PREFIX)gcc
CPP	= $(PREFIX)g++
AS	= $(CC)
LD	= $(PREFIX)ld
AR	= $(PREFIX)ar

FAMILY?=gd32f4xx
MCU?=GD32F450VI
BOARD?=BOARD_GD32F450VI
ENET_PHY?=DP83848

FAMILY:=$(shell echo $(FAMILY) | tr A-Z a-z)
FAMILY_UC=$(shell echo $(FAMILY) | tr a-w A-W)

$(info $$FAMILY [${FAMILY}])
$(info $$FAMILY_UC [${FAMILY_UC}])
$(info $$BOARD [${BOARD}])
$(info $$ENET_PHY [${ENET_PHY}])

SRCDIR=src src/gd32 $(EXTRA_SRCDIR)

include ../firmware-template-gd32/Includes.mk

DEFINES:=$(addprefix -D,$(DEFINES))
DEFINES+=-D_TIME_STAMP_YEAR_=$(shell date  +"%Y") -D_TIME_STAMP_MONTH_=$(shell date  +"%-m") -D_TIME_STAMP_DAY_=$(shell date  +"%-d")

COPS=-DBARE_METAL -DGD32 -DGD32F450 -D$(MCU) -D$(BOARD) -DPHY_TYPE=$(ENET_PHY)
COPS+=$(DEFINES) $(MAKE_FLAGS) $(INCLUDES)
COPS+=-Os -mcpu=cortex-m4 -mthumb -g -mfloat-abi=hard -fsingle-precision-constant -mfpu=fpv4-sp-d16
COPS+=-DARM_MATH_CM4 -D__FPU_PRESENT=1
COPS+=-nostartfiles -ffreestanding -nostdlib
COPS+=-fstack-usage -Wstack-usage=16384
COPS+=-ffunction-sections -fdata-sections
COPS+=-Wall -Werror -Wpedantic -Wextra -Wunused -Wsign-conversion -Wconversion
COPS+=-Wduplicated-cond -Wlogical-op

CPPOPS=-std=c++11
CPPOPS+=-Wnon-virtual-dtor -Woverloaded-virtual -Wnull-dereference -fno-rtti -fno-exceptions -fno-unwind-tables
CPPOPS+=-Wuseless-cast -Wold-style-cast
CPPOPS+=-fno-threadsafe-statics

CURR_DIR:=$(notdir $(patsubst %/,%,$(CURDIR)))
LIB_NAME:=$(patsubst lib-%,%,$(CURR_DIR))

BUILD=build_gd32/
BUILD_DIRS:=$(addprefix build_gd32/,$(SRCDIR))
$(info $$BUILD_DIRS [${BUILD_DIRS}])

C_OBJECTS=$(foreach sdir,$(SRCDIR),$(patsubst $(sdir)/%.c,$(BUILD)$(sdir)/%.o,$(wildcard $(sdir)/*.c)))
CPP_OBJECTS=$(foreach sdir,$(SRCDIR),$(patsubst $(sdir)/%.cpp,$(BUILD)$(sdir)/%.o,$(wildcard $(sdir)/*.cpp)))
ASM_OBJECTS=$(foreach sdir,$(SRCDIR),$(patsubst $(sdir)/%.S,$(BUILD)$(sdir)/%.o,$(wildcard $(sdir)/*.S)))

EXTRA_C_OBJECTS=$(patsubst %.c,$(BUILD)%.o,$(EXTRA_C_SOURCE_FILES))
EXTRA_C_DIRECTORIES=$(shell dirname $(EXTRA_C_SOURCE_FILES))
EXTRA_BUILD_DIRS:=$(addsuffix $(EXTRA_C_DIRECTORIES), $(BUILD))

OBJECTS:=$(strip $(ASM_OBJECTS) $(C_OBJECTS) $(CPP_OBJECTS) $(EXTRA_C_OBJECTS))

TARGET=lib_gd32/lib$(LIB_NAME).a
$(info $$TARGET [${TARGET}])

LIST = lib.list

define compile-objects
$(BUILD)$1/%.o: $1/%.c
	$(CC) $(COPS) -c $$< -o $$@
	
$(BUILD)$1/%.o: $1/%.cpp
	$(CPP) $(COPS) $(CPPOPS)  -c $$< -o $$@
	
$(BUILD)$1/%.o: $1/%.S
	$(CC) $(COPS) -D__ASSEMBLY__ -c $$< -o $$@
endef

all : builddirs $(TARGET)

.PHONY: clean builddirs

builddirs:
	mkdir -p $(BUILD_DIRS)
	mkdir -p $(EXTRA_BUILD_DIRS)
	mkdir -p lib_gd32

clean:
	rm -rf build_gd32
	rm -rf lib_gd32
	
$(BUILD)%.o: %.c
	$(CC) $(COPS) -c $< -o $@
	
$(BUILD_DIRS) :	
	mkdir -p $(BUILD_DIRS)
	mkdir -p lib_gd32
	
$(TARGET): Makefile.GD32 $(OBJECTS)
	$(AR) -r $(TARGET) $(OBJECTS)
	$(PREFIX)objdump -d $(TARGET) | $(PREFIX)c++filt > lib_gd32/$(LIST)
	
$(foreach bdir,$(SRCDIR),$(eval $(call compile-objects,$(bdir))))