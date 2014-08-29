# Makefile for compiling hacs/src.


# SETUP.

#TODO: Eliminate this hard-coding once crsx package exists...
CRSXROOT = $(abspath ../../crsx)
BUILD = ../build
include ../Hacs.mk


# STANDARD TARGETS.

.PHONY: all clean realclean
all::
clean::; rm -f *.tmp *~ ./#* *.log *~ *.pgbase *.pg *.crs *.build *.hxp
realclean:: clean

$(BUILD)/org/crsx/hacs/samples/Lambda.jj: $(BUILD)/org/crsx/hacs/samples/Lambda.pg
