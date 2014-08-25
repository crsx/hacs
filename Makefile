# Main -*-Makefile-*- for Building HACS distribution.

include Env.mk


# DIRECTORIES.
#
SRC = $(abspath src)


# STANDARD TARGETS.
#
.PHONY: all clean realclean install
all::
clean::; rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
install::

# Propagate to src.
all clean realclean::
	$(MAKE) -C src $@
