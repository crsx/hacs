# Main -*-Makefile-*- for Building HACS distribution.

.PHONY: all clean realclean install gitclean
all::
install::
clean::
	rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
	rm -fr build rulecompiler
gitclean:: realclean

# All targets propagate to subdirectories.
all clean realclean install gitclean::
	$(MAKE) -C src $@
	$(MAKE) -C doc $@
