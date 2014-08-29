# Main -*-Makefile-*- for Building HACS distribution.

.PHONY: all clean realclean install gitclean
all::
install::
clean::
	rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
	rm -fr build rulecompiler
gitclean:: realclean

# Targets propagate to subdirectories...
all install ::
	mkdir -p build
	$(MAKE) -C src BUILD=../build $@
	$(MAKE) -C doc BUILD=../build $@

clean realclean gitclean ::
	$(MAKE) -C src BUILD=../build $@
	$(MAKE) -C doc BUILD=../build $@
	$(MAKE) -C samples BUILD=../build $@

src/% build/% : all
	$(MAKE) -C src BUILD=../build ../$@

samples/% : all
	$(MAKE) -C samples BUILD=../build ../$@

doc/% : .
	$(MAKE) -C doc BUILD=../build ../$@

### TODO: packaging and installation...
