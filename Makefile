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
all install::
	mkdir -p build
	$(MAKE) -C src BUILD=../build $@
	$(MAKE) -C doc BUILD=../build $@

clean realclean gitclean::
	$(MAKE) -C src BUILD=../build $@
	$(MAKE) -C doc BUILD=../build $@

samples/% src/%: .
	$(MAKE) -C src BUILD=../build ../$@
