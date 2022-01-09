SUBDIRS = 
PROGRAMS = sample-test.t

all: test

include ../../../makefile.inc

test: test-default
lint: lint-default

clean: # do not call clean-default or '*.t' will be deleted!
	@for i in *.log ; do rm -v -f "$$i" ; done

