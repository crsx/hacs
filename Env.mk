# -*-Makefile-*- definitions for HACS distribution.

# STANDARD TARGETS.
#
.PHONY: all clean realclean install
all::
clean::; rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
install::

# SYSTEM COMMANDS.
#
# These are suitable defaults for many systems.
#
ifdef JAVA_HOME
JAVA = $(JAVA_HOME)/jre/bin/java
else
JAVA = java
endif
JAVAC = javac
JAR = jar
#
JAVACC = javacc
JAVACCJAR = /usr/share/java/javacc.jar
#
CC = gcc -std=c99 -g
FLEX = flex
#
WGET = wget
UNZIP = unzip -q

# CRSX.
#
# Note: currently direct link to crsx repo...
CRSXROOT = $(abspath $(SRC)/../../crsx)
##CRSXROOT = $(abspath $(SRC)/../../../master/crsx/crsx)
#
# The jar.
CRSXJAR = $(CRSXROOT)/crsx.jar
$(CRSXJAR):; cd $(CRSXROOT) && make
#
# The rulecompiler.
RULEC = $(CRSXROOT)/bin/crsxc
$(RULEC):; cd $(CRSXROOT) && make bin/crsx
#
CRSX = $(JAVA) -ea -cp "$(SRC):$(CRSXJAR)" net.sf.crsx.run.Crsx allow-unnamed-rules $(EXTRA)
PG = $(JAVA) -cp "$(SRC):$(CRSXJAR):$(JAVACCJAR)" net.sf.crsx.pg.PG $(EXTRA)

# So -n works...
NOEXEC = $(if,$(findstring -n,$(MAKE)),echo)
SH_EXTRA = :
