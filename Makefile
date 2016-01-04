CPPFLAGS=-g -O2 -Wall -Wextra -Isrc -rdynamic -std=c++14 -DNDEBUG $(OPTFLAGS)

LIBS=-ldl $(OPTLIBS)
PREFIX?=/usr/local

SOURCES=$(wildcard src/**/*.cpp src/*.cpp)
OBJECTS=$(patsubst %.cpp,%.o,$(SOURCES))

TEST_SRC=$(wildcard tests/*_tests.cpp)
TESTS=$(patsubst %.cpp,%,$(TEST_SRC))

PROGRAMS_SRC=$(wildcard bin/*.cpp)
PROGRAMS=$(patsubst %.cpp,%,$(PROGRAMS_SRC))

TARGET=build/libYOUR_LIBRARY.a
SO_TARGET=$(patsubst %.a,%.so,$(TARGET))

# The Target Build
all: $(TARGET) $(SO_TARGET) tests $(PROGRAMS)

dev: CPPFLAGS=-g -Wall -Isrc -Wall -Wextra $(OPTFLAGS)
dev: all

$(TARGET): CPPFLAGS += -fPIC
$(TARGET): build $(OBJECTS)
	ar rcs $@ $(OBJECTS)
	ranlib $@

$(SO_TARGET): $(TARGET) $(OBJECTS)
	$(CXX) -shared -o $@ $(OBJECTS)

build:
	@mkdir -p build
	@mkdir -p bin

# The Unit Tests
.PHONY: tests
tests: LDLIBS += $(TARGET)
tests: CPPFLAGS += -lgtest
tests: $(TESTS)
	sh ./tests/runtests.sh

valgrind:
	VALGRIND="valgrind --log-file=/tmp/valgrind-%p.log" $(MAKE)

# The Cleaner
clean:
	rm -rf build $(OBJECTS) $(TESTS) $(PROGRAMS)
	rm -f tests/tests.log
	find . -name "*.gc*" -exec rm {} \;
	rm -rf `find . -name "*.dSYM" -print`

# The Install
install: all
	install -d $(DESTDIR)/$(PREFIX)/lib/
	install $(TARGET) $(DESTDIR)/$(PREFIX)/lib/”

# The Checker
check:
	@echo Files with potentially dangerous functions in $(SOURCES)
	@egrep '[^_.>a-zA-Z0-9](str(n?cpy|n?cat|xfrm|n?dup|str|pbrk|tok|_)|stpn?cpy|a?sn?printf|byte_)' $(SOURCES) || true



