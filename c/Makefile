# Every src/NAME.c is built into its own program: build/NAME
#
#   make                  build all programs
#   make run              build and run $(P)          (default P=hello)
#   make run P=foo        ...or pick another program
#   make run-foo          same thing, shorter
#   make run-foo ARGS="a b < in.txt"   pass arguments/input (also debug, memcheck, asan)
#   make debug-foo        run under gdb
#   make memcheck-foo     run under valgrind (leaks, invalid reads/writes)
#   make asan-foo         build with AddressSanitizer + UBSan and run
#   make check-foo        run with tests/foo.in as input, compare to tests/foo.out
#   make lint             static analysis with cppcheck and clang-tidy
#   make format           format all code with clang-format
#   make clean            delete build/
#
# Override anything on the command line, e.g. make CC=gcc P=foo run
# Course projects that come with their own Makefile go in projects/: run make there

CC       = clang
CSTD     = c11
CFLAGS   = -std=$(CSTD) -Wall -Wextra -Wpedantic -Wshadow \
           -Wstrict-prototypes -Wold-style-definition \
           -Wformat=2 -g -O0 $(EXTRA_CFLAGS)
LDLIBS   = -lm
SANFLAGS = -fsanitize=address,undefined -fno-sanitize-recover=all \
           -fno-omit-frame-pointer

SRC_DIR   := src
BUILD_DIR := build
TEST_DIR  := tests

SRCS  := $(wildcard $(SRC_DIR)/*.c)
PROGS := $(patsubst $(SRC_DIR)/%.c,%,$(SRCS))
P     ?= hello

RESERVED := all run debug memcheck asan check lint format clean help build
ifneq ($(filter $(RESERVED),$(PROGS)),)
  $(error Rename $(patsubst %,$(SRC_DIR)/%.c,$(filter $(RESERVED),$(PROGS))): \
    these names are used by make ($(RESERVED)))
endif

.PHONY: all run debug memcheck asan check lint format clean help $(PROGS)
.SECONDARY:  # don't auto-delete binaries built via run-%/asan-% etc.

all: $(addprefix $(BUILD_DIR)/,$(PROGS))

# `make hello` builds build/hello
$(PROGS): %: $(BUILD_DIR)/%

# -Dtest_NAME as in the course's Makefiles: course files often put their
# tests and main inside #ifdef test_NAME
$(BUILD_DIR)/%: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -Dtest_$* -MMD -MP $< -o $@ $(LDLIBS)

$(BUILD_DIR)/asan/%: $(SRC_DIR)/%.c | $(BUILD_DIR)/asan
	$(CC) $(CFLAGS) $(SANFLAGS) -Dtest_$* -MMD -MP $< -o $@ $(LDLIBS)

$(BUILD_DIR) $(BUILD_DIR)/asan:
	@mkdir -p $@

run:      run-$(P)
debug:    debug-$(P)
memcheck: memcheck-$(P)
asan:     asan-$(P)
check:    check-$(P)

run-%: $(BUILD_DIR)/%
	./$<$(if $(ARGS), $(ARGS))

debug-%: $(BUILD_DIR)/%
	gdb -q$(if $(ARGS), -ex 'set args $(ARGS)') ./$<

memcheck-%: $(BUILD_DIR)/%
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --error-exitcode=1 ./$<$(if $(ARGS), $(ARGS))

asan-%: $(BUILD_DIR)/asan/%
	./$<$(if $(ARGS), $(ARGS))

# tests/NAME.in is optional (no input if missing); tests/NAME.out is required
# Passes only if the output matches and the program exits with status 0
check-%: $(BUILD_DIR)/%
	@test -f $(TEST_DIR)/$*.out || { echo "No expected output: create $(TEST_DIR)/$*.out"; exit 1; }
	@in=$(TEST_DIR)/$*.in; test -f $$in || in=/dev/null; \
	./$< < $$in > $(BUILD_DIR)/$*.actual; status=$$?; \
	diff -u --label expected --label actual $(TEST_DIR)/$*.out $(BUILD_DIR)/$*.actual; same=$$?; \
	if [ $$status -gt 128 ]; then echo "FAIL: $* crashed (signal $$((status - 128)))"; exit 1; \
	elif [ $$status -ne 0 ]; then echo "FAIL: $* exited with status $$status"; exit 1; \
	elif [ $$same -ne 0 ]; then echo "FAIL: $*"; exit 1; \
	else echo "PASS: $*"; fi

# constParameter would flag the standard main(int argc, char *argv[])
# clang-tidy takes its checks from .clang-tidy and its flags from compile_flags.txt;
# its "N warnings generated" count is filtered out (they are system header warnings it hides)
lint:
	@cppcheck --enable=warning,style,performance,portability --std=$(CSTD) \
	  --suppress=constParameter --error-exitcode=1 --quiet $(SRC_DIR)
	@out=$$(clang-tidy --quiet --warnings-as-errors="*" $(SRCS) 2>&1); status=$$?; \
	printf '%s\n' "$$out" | grep -v ' generated\.$$' || true; exit $$status

format:
	clang-format -i $(wildcard $(SRC_DIR)/*.c $(SRC_DIR)/*.h)

clean:
	rm -rf $(BUILD_DIR)

help:
	@sed -n '1,/^$$/p' $(MAKEFILE_LIST)
	@echo "Programs: $(PROGS)"

-include $(wildcard $(BUILD_DIR)/*.d $(BUILD_DIR)/asan/*.d)
