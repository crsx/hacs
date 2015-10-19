# Main -*-GNUMakefile-*- for Building HACS distribution.

.PHONY: all all-debug install install-support clean realclean gitclean
all ::
all-debug ::
install ::
install-support ::
clean :: ; rm -f *.tmp *~ ./#* *.log *~
realclean :: clean
gitclean :: realclean

# Set default install directories.

ifndef prefix
prefix=$(shell echo $$HOME)/.hacs
endif
ifndef SHAREJAVA
SHAREJAVA="$(prefix)/share/java/"
endif
ifndef ICU4CINCLUDE
ICU4CINCLUDE="$(prefix)/lib/icu4c/include"
endif
ifndef ICU4CDIR
ICU4CDIR="$(prefix)/lib/icu4c/lib"
endif

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

all install :: doc/hacs.pdf
doc/% :
	$(MAKE) -C doc -I $(abspath src) $(subst doc/,,$@)

gitclean ::; rm -fr lib

# Quick-install .zip.

$(eval HACS$(shell cat VERSION))

hacs.zip : ziplist
	$(MAKE) clean
	$(MAKE)
	$(MAKE) clean
	rm -f *.zip
	cd .. && zip -r hacs/hacs-$(HACSVERSION).zip $(addprefix hacs/,$(shell cat ziplist))
	ln -fs hacs-$(HACSVERSION).zip hacs.zip

.PHONY : release
release : ziplist
	$(MAKE) gitclean
	$(MAKE) hacs.zip
	scp hacs.zip krisrose.net:/var/www/crsx/hacs-$(HACSVERSION).zip; scp hacs.zip doc/hacs.pdf krisrose.net:/var/www/crsx/

realclean ::; rm -f *.zip
