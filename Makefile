# Main -*-Makefile-*- for Building HACS distribution.

.PHONY: all install clean realclean gitclean
all ::
install ::
clean :: ; rm -f *.tmp *~ ./#* *.log *~
realclean :: clean
gitclean :: realclean

# Targets propagate to subdirectories...

all install clean realclean gitclean ::
	$(MAKE) -C src -I $(abspath src) $@
	$(MAKE) -C doc -I $(abspath src) $@

src/% :
	$(MAKE) -C src -I $(abspath src) ../$@

samples/% :
	$(MAKE) -C samples -I $(abspath src) ../$@

doc/% :
	$(MAKE) -C doc -I $(abspath src) ../$@

# Quick-install .zip.

$(eval HACSMAJOR$(basename $(shell cat VERSION)))

hacs.zip : all $(shell cat ziplist)
	$(MAKE) all
	$(MAKE) clean
	rm -f *.zip
	touch build/org/crsx/hacs/Main.dr.gz
	cd .. && zip -r hacs/hacs-$(HACSMAJORVERSION).zip $(addprefix hacs/,$(shell cat ziplist))
	ln -fs hacs-$(HACSMAJORVERSION).zip hacs.zip

realclean ::; rm -f *.zip
