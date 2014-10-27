# Makefile for compiling hacs/src.


# SETUP.

#TODO: Eliminate this hard-coding once crsx package exists...


HACSJAR = $(abspath ../src/build/share/java/hacs.jar)
CRSXJAR = $(abspath ../src/build/share/java/crsx.jar)
JAVACCJAR = $(abspath ../src/build/share/java/javacc.jar)
BUILD = build
include Hacs.mk


# STANDARD TARGETS.

.PHONY: all clean realclean
all::
clean::; rm -f *.tmp *~ ./#* *.log *~ *.pgbase *.pg *.crs *.build *.hxp
realclean:: clean

$(TEMP)/org/crsx/hacs/samples/Lambda.pg: $(TEMP)/org/crsx/hacs/samples/Lambda.hx
$(TEMP)/org/crsx/hacs/samples/Lambda.jj: $(TEMP)/org/crsx/hacs/samples/Lambda.pg
$(TEMP)/org/crsx/hacs/samples/Lambda.java: $(TEMP)/org/crsx/hacs/samples/Lambda.pg

%.test : %.Lambda
	$(CRSX) "grammar=('org.crsx.hacs.samples.Lambda';)" input="$<" category='Lambda$$E' output=$@.tmp
	mv $@.tmp $@
