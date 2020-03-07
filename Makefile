#$(warning default goal is $(.DEFAULT_GOAL))
TARGET_LIB_SO ?= libhmc_mck.so

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src
#HMC_COM_DIR ?= ../hmc_com/src
XENO_PATH ?= ../preset_32/xenomai
SHM_PATH ?= ../hmc_com/src
PRESET ?= ../preset_32

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.s)


OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
#INC_DIRS += $(shell find $(HMC_COM_DIR) -type d -name "include")
INC_DIRS += $(shell find $(PRESET) -type d -name "include")
INC_DIRS += $(shell find $(XENO_PATH) -type d -name "include")
INC_DIRS += $(shell find $(SHM_PATH) -type d -name "include")
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

LIB_DIRS := $(shell find $(SRC_DIRS)/ -type d -name "lib")
#LIB_DIRS |= $(shell find $(XENO_PATH)/ -type d -name "lib")
LIB_FLAGS := $(addprefix -L,$(LIB_DIRS))

CPPFLAGS ?= $(INC_FLAGS) -MMD -MP 
#CFLAGS ?= $(INC_FLAGS) -MMD -MP -pthread -fPIC -m32
CFLAGS ?= $(INC_FLAGS) -MMD -MP -pthread -fPIC -m32 -D_XENOMAI_2_6_ -DECAT_EABLE
#CFLAGS ?= $(INC_FLAGS) -MMD -MP -pthread -fPIC -std=c99
LDFLAGS = $(LIB_FLAGS) -lpthread -lm -shared

$(BUILD_DIR)/$(TARGET_LIB_SO): $(OBJS)
		$(CC) $(OBJS) -g -o $@ $(LDFLAGS) -fPIC -m32

# assembly
$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -g -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CFLAGS) -c $< -g -o $@ $(LDFLAGS) 

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -g -o $@

.PHONY: clean

clean:
	$(RM) -r $(BUILD_DIR)

-include $(DEPS)

MKDIR_P ?= mkdir -p

list_test:
	echo "list test"
	gcc -g -ggdb -o list_test src/list_test.c src/client.c -I./src

#gcc -g -o reserv sysserv.c -pthread
#gcc -g -ggdb -o reserv sysserv.c -pthread
