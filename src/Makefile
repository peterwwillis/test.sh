SUBDIRS = 
PROGRAMS = test.sh

include ../makefile.inc

clean: clean-default
clean-install: clean-install-default
build: build-default
lint: lint-default
install: install-default

# Also run the 'test' target in the 'tests' directory
test: test-default
	make -C tests test
