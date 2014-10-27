# Environment setup (shared between HACS and CRSX rulescompiler generation).
#
# Java ecosystem:
# - JAVA - Java execution command.
# - JAVAC - Java compiler command.
# - JAR - Java Archiver command.
# - ANT - Java build command.
#
# C ecosystem:
# - CC - C99 compiler command.
# - CXX - C++ compiler command.
# - FLEX - lexical generator command.
#
# Unix ecosystem:
# - SHELL - shell compatible with GNU's Bourne Again Shell command.
# - ECHO - extended echo command (that accepts -e option).
# - GNUSED - the GNU stream editor command.
#
# Net ecosystem:
# - UNZIP - decompression and unpacking command.


# SYSTEM COMMANDS.

# Java ecosystem.
ifdef JAVA_HOME
JAVA = $(JAVA_HOME)/jre/bin/java
else
JAVA = java
endif
#
JAVAC = javac
JAR = jar
ANT = ant
JAVACC = $(JAVA) -cp $(JAVACCJAR) javacc

# C ecosystem.
CC = gcc
CXX = g++
FLEX = flex

# Base utilities.
SHELL = /bin/bash
ECHO = /bin/echo
GNUSED = sed

# Net utilities.
WGET = wget
UNZIP = unzip -q
RSYNC = rsync


# COMPILATION SETUP.

# C flags.
CLANGFLAGS= -Wno-gnu-variable-sized-type-not-at-end
CFLAGS= -I/usr/include/$(shell uname -m)-linux-gnu $(C99FLAG) $(CLANGFLAGS)
CCFLAGS+=-g -Wall
UNAME_S=$(shell uname -s)
ifeq ($(UNAME_S),Darwin)
CCFLAGS+=-Wno-gnu-variable-sized-type-not-at-end -Wbitwise-op-parentheses
endif

# icu4c libraries for UTF-8 support.
ifndef ICU4CDIR
ICU4CDIR = $(if $(wildcard /usr/lib*/libicu*.so),$(dir $(word 1,$(wildcard /usr/lib*/libicu*.so))),$(if $(wildcard /usr/lib*/*/libicu*.so),$(dir $(word 1,$(wildcard /usr/lib*/*/libicu*.so)))))
ifeq ($(UNAME_S),Darwin)
ICU4CDIR=/usr/local/opt/icu4c/lib
endif
endif


# CRSX HOOKS.

# Special hack for rulecompiler generation (guess CRSX jar).
ifdef MAKEFILE_CC
RUNCRSXRC = $(JAVA) -ea -cp "$(wildcard $(dir $(MAKEFILE_CC))lib/crsx*.jar)" -Dfile.encoding=UTF-8 -Xss20000K -Xmx2000m net.sf.crsx.run.Crsx allow-unnamed-rules allow-missing-cases
endif
