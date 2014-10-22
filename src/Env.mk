# Environment setup (shared between HACS and CRSX rulescompiler generation).


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
JAVACC = javacc
ANT = ant

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
CFLAGS= -I/usr/include/icu4c $(C99FLAG) $(CLANGFLAGS)
CCFLAGS+=-g -Wall
UNAME_S=$(shell uname -s)
ifeq ($(UNAME_S),Darwin)
CCFLAGS+=-Wno-gnu-variable-sized-type-not-at-end -Wbitwise-op-parentheses
endif

# icu4c libraries for UTF-8 support.
ifndef ICU4CDIR
ICU4CDIR=
ifeq ($(UNAME_S),Darwin)
ICU4CDIR=/usr/local/opt/icu4c/lib
endif
endif


# CRSX HOOKS.

# Rule generating CRSX command...
RUNCRSXRC = $(JAVA) -ea -cp "$(dir $(MAKEFILE_CC))/../lib/crsx.jar" -Dfile.encoding=UTF-8 -Xss20000K -Xmx2000m net.sf.crsx.run.Crsx allow-unnamed-rules allow-missing-cases
