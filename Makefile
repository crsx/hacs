# Main -*-Makefile-*- for Building HACS distribution.

.PHONY: all install clean realclean gitclean
all ::
install ::
clean :: ; rm -f *.tmp *~ ./#* *.log *~
realclean :: clean
gitclean :: realclean

# Targets propagate to subdirectories...

all install ::
	$(MAKE) -C src -I $(abspath src) $@
	$(MAKE) -C doc -I $(abspath src) $@

clean realclean gitclean ::
	$(MAKE) -C src -I $(abspath src) $@
	$(MAKE) -C doc -I $(abspath src) $@
	$(MAKE) -C samples -I $(abspath src) $@

src/% :
	$(MAKE) -C src -I $(abspath src) ../$@

samples/% :
	$(MAKE) -C samples -I $(abspath src) ../$@

doc/% :
	$(MAKE) -C doc -I $(abspath src) ../$@

# Quick-install .zip.

$(eval HACSMAJOR$(basename $(shell cat VERSION)))

HACSTOP = README.md VERSION LICENSE src doc samples

hacs.zip :
	$(MAKE) all
	$(MAKE) clean
	rm -f hacs-$(HACSMAJORVERSION).zip hacs.zip
	cd .. && zip -r hacs/hacs-$(HACSMAJORVERSION).zip $(addprefix hacs/,$(HACSTOP)) -x crsxc hacs/src hacs/doc hacs/LICENSE hacs/ -x crsxc '*.o' '*.dr' '*.symlist' '*.zip'
	ln -s hacs-$(HACSMAJORVERSION).zip hacs.zip

realclean ::; rm -f *.zip
