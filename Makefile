CXX       	:= g++
EXECUTABLE  = main
BUILD_DIR  	?= build
BIN        	= $(BUILD_DIR)/$(EXECUTABLE)
LIB     	:= lib
# The following line of code will automaticly find all *.cpp files in src 
# SRCS = $(shell find src -name '*.cpp')
SRCS    	:= 	src/example.cpp \
				src/math.cpp
MAIN       	= src/main.cpp
INCLUDE 	:= inc

OBJS            = $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(SRCS) $(MAIN))

COMMON_CFLAGS       = -Wall -Werror -Wextra -MMD

ifneq ($(DEBUG),)
  COMMON_CFLAGS     += -g
  BUILD_DIR         := $(BUILD_DIR)/debug
else
  COMMON_CFLAGS     += -DNDEBUG -O3
  BUILD_DIR         := $(BUILD_DIR)/release
endif

CFLAGS              += $(COMMON_CFLAGS)
CXXFLAGS            += $(COMMON_CFLAGS) -std=c++11

ifneq ($(V),)
	SILENCE         =
else
	SILENCE     	= @
endif

SHOW_COMMAND        := @printf "%-15s%s\n"
SHOW_CXX            := $(SHOW_COMMAND) "[ $(CXX) ]"
SHOW_CLEAN          := $(SHOW_COMMAND) "[ CLEAN ]"

DEPS                = $(OBJS:.o=.d) 

all: $(BIN)
.PHONY: all

$(BIN): $(OBJS)
	@echo "🚧 Building..."
	$(SHOW_CXX) $@
	$(SILENCE)$(CXX) $(CXXFLAGS) $(OBJS) -o $@ 

$(BUILD_DIR)/%.o: %.cpp
	$(SHOW_CXX) $@
	$(SILENCE)mkdir -p $(dir $@)
	$(SILENCE)$(CXX) $(CXXFLAGS) -I$(INCLUDE) -c $< -o $@

run: clean all
	clear
	@echo "🚀 Executing..."
	./$(BIN)

clean:
	@echo "🧹 Clearing..."
	$(SHOW_CLEAN) $(BUILD_DIR)
	$(SILENCE)rm -rf $(BUILD_DIR)
	$(MAKE) -C tests clean
.PHONY: clean

test: 
	$(MAKE) -C tests test
.PHONY: test

