CXX       	:= g++
EXECUTABLE  = main
BUILD_DIR  	?= build
BIN        	= $(BUILD_DIR)/$(EXECUTABLE)
LIB     	:= lib
LIBRARIES   := -L$(CPPUTEST_HOME)/lib -lCppUTest -lCppUTestExt
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


ifneq ($(CPPUTEST_HOME),)
	HAS_CPPUTEST          = 1
	CPPUTEST_FLAGS        = -I$(CPPUTEST_HOME)/include -fprofile-arcs -ftest-coverage
	CPPUTEST_LDFLAGS      = -L$(CPPUTEST_HOME)/lib -lCppUTest -lgcov --coverage -lCppUTestExt
else
	HAS_CPPUTEST          = $(shell pkg-config cpputest && echo 1)
	ifeq ($(HAS_CPPUTEST),1)
		CPPUTEST_FLAGS      = $(shell pkg-config --cflags cpputest 2>/dev/null)
		CPPUTEST_LDFLAGS    = $(shell pkg-config --libs cpputest 2>/dev/null)
	endif
endif

ifneq ($(V),)
	SILENCE         =
else
	SILENCE     	= @
endif


SHOW_COMMAND        := @printf "%-15s%s\n"
SHOW_CXX            := $(SHOW_COMMAND) "[ $(CXX) ]"
SHOW_CLEAN          := $(SHOW_COMMAND) "[ CLEAN ]"

TEST_BIN            = $(BUILD_DIR)/$(EXECUTABLE)_tests
TEST_RESULTS        = ./tests/results
TEST_SRCS        	= $(SRCS) \
                      tests/first_test.cpp \
                      tests/main.cpp
TEST_OBJS           = $(patsubst %.cpp,$(BUILD_DIR)/tests/%.o,$(TEST_SRCS))

DEPS                = $(APP_OBJS:.o=.d) \
                      $(TEST_OBJS:.o=.d)

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
	@echo "🚀 Executing..."
	./$(BIN)

clean:
	@echo "🧹 Clearing..."
	$(SHOW_CLEAN) $(BUILD_DIR)
	$(SILENCE)-rm -rf $(BUILD_DIR)
	$(SILENCE)-rm -rf $(TEST_RESULTS)
.PHONY: clean

$(TEST_BIN): $(TEST_OBJS)
	$(SHOW_CXX) $@
	$(SILENCE)$(CXX) $(TEST_OBJS) $(CPPUTEST_LDFLAGS) -o $@

$(BUILD_DIR)/tests/%.o: %.cpp
ifneq ($(HAS_CPPUTEST),1)
	$(error CppUTest not found, cannot build the tests)
endif
	$(SHOW_CXX) $@
	$(SILENCE)mkdir -p $(dir $@)
	$(SILENCE)$(CXX) $(CXXFLAGS) $(CPPUTEST_FLAGS) -c $< -o $@

build_tests: $(TEST_BIN)
.PHONY: build_tests

test: build_tests
	@echo "🧪 Testing..."
	./$(TEST_BIN)
	gcovr -r .  
	$(SILENCE)mkdir -p $(TEST_RESULTS)
	gcovr -r . --html --html-details -o $(TEST_RESULTS)/coverage.html 
.PHONY: test

$(BUILD_DIR)/.tests_passed: $(TEST_BIN)
	$(SILENCE)./$< || rm $<
	$(SILENCE)touch $@