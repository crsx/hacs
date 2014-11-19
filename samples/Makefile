# Makefile for compiling hacs/src.

# SETUP.

HACSJAR = $(readlink -f ../build/share/java/hacs.jar)
CRSXJAR = $(readlink -f ../build/share/java/crsx.jar)
JAVACCJAR = $(readlink -f ../build/share/java/javacc.jar)
include Hacs.mk

# STANDARD TARGETS.

.PHONY: all install clean realclean gitclean
all::
	$(MAKE) -C ../src
clean::; rm -f *.tmp *~ ./#* *.log *~ *.pgbase *.pg *.crs *.build *.hxp
realclean:: clean
	rm -fr build
gitclean :: realclean
