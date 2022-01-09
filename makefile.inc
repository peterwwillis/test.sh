# vim: syntax=make

PROJECT_NAME = project-name

INSTALL ?= install
INSTALL_PROGRAM ?= $(INSTALL) -m 0755

# Path defaults
PREFIX ?= /usr/local
EXEC_PREFIX ?= $(PREFIX)
BINDIR ?= $(EXEC_PREFIX)/bin
LIBDIR ?= $(EXEC_PREFIX)/lib

# The prefix added to the installed programs
BINPREFIX ?= $(PROJECT_NAME)-

# Macros for m4 to replace in scripts
M4_ARGS := -D_PREFIX_=$(PREFIX) -D_EXEC_PREFIX=$(EXEC_PREFIX) \
    -D_BINDIR_=$(BINDIR) -D_LIBDIR_=$(LIBDIR) -D_BINPREFIX_=$(BINPREFIX)

INSTALLDIR ?= $(BINDIR)

##################################################################################

# This will end up as whatever directory you run 'make' from
PROJDIR := $(shell cd $(CURDIR) && pwd -P)

export PATH := $(PATH):$(DESTDIR)$(BINDIR):$(PROJDIR)

.PHONY: all all-default build build-default clean clean-default clean-install clean-install-default lint lint-default install install-default test test-default

.SUFFIXES: .m4 .sh

all-default: $(PROGRAMS)

build-default: $(PROGRAMS)
	@set -e; if [ -n "$(SUBDIRS)" ] ; then for i in $(SUBDIRS) ; do make -C $$i build ; done ; fi
	@for i in $(PROGRAMS) ; do chmod +x $$i ; done

clean-default:
	@for i in $(PROGRAMS) ; do rm -v -f "$$i" ; done
	@set -e; if [ -n "$(SUBDIRS)" ] ; then for i in $(SUBDIRS) ; do make -C $$i clean ; done ; fi

lint-default: $(PROGRAMS)
	@set -e; for i in $(PROGRAMS) ; do shellcheck -x $$i ; done
	@set -e; if [ -n "$(SUBDIRS)" ] ; then for i in $(SUBDIRS) ; do make -C $$i lint ; done ; fi

clean-install-default:
	@for i in $(PROGRAMS) ; do rm -v -f "$(DESTDIR)$(INSTALLDIR)/$$i" ; done
	@set -e; if [ -n "$(SUBDIRS)" ] ; then for i in $(SUBDIRS) ; do make -C $$i clean-install ; done ; fi

install-default:
	$(INSTALL) -d -m 0755 $(DESTDIR)$(INSTALLDIR)
	set -e; for i in $(PROGRAMS) ; do $(INSTALL) -m 0755 $$i "$(DESTDIR)$(INSTALLDIR)/$$i" ; done
	@set -e; if [ -n "$(SUBDIRS)" ] ; then for i in $(SUBDIRS) ; do make -C $$i install ; done ; fi

%.sh: %.m4
	m4 $(M4_ARGS) -P <'$<' >'$@'

%.t:
	@true

test-default: lint-default
	@ls *.t 2>/dev/null | while read TEST ; do test.sh $$TEST ; done
	@set -e; if [ -n "$(SUBDIRS)" ] ; then for i in $(SUBDIRS) ; do make -C $$i test ; done ; fi

%: %-default
	@	true
