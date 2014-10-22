# Main -*-Makefile-*- for Building HACS distribution.

.PHONY: all clean realclean install gitclean
all::
install::
clean::
	rm -f *.tmp *~ ./#* *.log *~
	rm -fr build temp rulecompiler
realclean:: clean
gitclean:: realclean

# Targets propagate to subdirectories...
all install ::
	$(MAKE) -C src $@
	$(MAKE) -C doc $@

clean realclean gitclean ::
	$(MAKE) -C src $@
	$(MAKE) -C doc $@
	$(MAKE) -C samples $@

src/% build/% temp/% : all
	$(MAKE) -C src ../$@

samples/% : all
	$(MAKE) -C samples ../$@

doc/% : .
	$(MAKE) -C doc ../$@
