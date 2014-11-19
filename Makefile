# Main -*-Makefile-*- for Building HACS distribution.

.PHONY: all all-debug install install-support clean realclean gitclean
all ::
all-debug ::
install ::
install-support ::
clean :: ; rm -f *.tmp *~ ./#* *.log *~
realclean :: clean
gitclean :: realclean

# Targets propagate to subdirectories...

all install clean realclean gitclean ::
	$(MAKE) -C src $@
	$(MAKE) -C doc -I $(abspath src) $@

all-debug install-support ::
	$(MAKE) -C src $@

src/% :
	$(MAKE) -C src ../$@

samples/% :
	$(MAKE) -C samples -I $(abspath src) ../$@

doc/% :
	$(MAKE) -C doc -I $(abspath src) ../$@

gitclean ::; rm -fr lib

# Quick-install .zip.

$(eval HACS$(shell cat VERSION))

hacs.zip : all
	$(MAKE) $(shell cat ziplist)
	$(MAKE) clean
	rm -f *.zip
	cd .. && zip -r hacs/hacs-$(HACSVERSION).zip $(addprefix hacs/,$(shell cat ziplist))
	ln -fs hacs-$(HACSVERSION).zip hacs.zip

realclean ::; rm -f *.zip
