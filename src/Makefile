# Makefile for compiling hacs/src.
#
# Generate and/or install all HACS runtime artifacts.
#
# Usage:
#   make prefix="/usr/local"
#   make DESTDIR="" prefix="/usr/local" install
#   make DESTDIR="" prefix="/usr/local" install-support
#
# Environment variables (all with suitable defaults):
# - DESTDIR - root of installation (empty by default)
# - prefix - prefix of installation ($HOME/.hacs by default).
# - CRSXJAR - full path to CRSX jar
# - JAVACCJAR - full path to JavaCC jar (at least version 5.0).
# - ICU4CINCLUDE - directory where the ICU unicode/ include directory is a subdirectory.
# - ICU4CDIR - directory where ICU library binaries live.
#
# Bootstrap by using Hacs.mk with HACSJAR set to the current directory.


# STANDARD TARGETS.

.PHONY: all install install-support clean realclean gitclean
all ::
install ::
install-support ::
clean ::; rm -f *.tmp *~ ./#* *.log *~
realclean :: clean
gitclean :: realclean
	rm -fr $(shell cat .gitignore)


# SETUP.

# External library setup.
ifndef CRSXJAR
CRSXVERSION = 3.3.0.6
CRSXJAR = $(abspath ../lib/crsx-$(CRSXVERSION).jar)
all :: $(CRSXJAR)
endif
ifndef JAVACCJAR
JAVACCVERSION = 6.0
JAVACCJAR = $(abspath ../lib/javacc-$(JAVACCVERSION).jar)
all :: $(JAVACCJAR)
endif
ifndef ICU4CDIR
ICU4CDIR = $(abspath ../lib/icu4c/lib)
ICU4CINCLUDE = $(abspath ../lib/icu4c/include)
all :: $(ICU4CDIR)/libicudata.so
endif
CRSXC = env LD_LIBRARY_PATH='$(ICU4CDIR):' $(BUILD)/lib/hacs/crsxc

# HACS bootstrapping setup.
BUILD = $(abspath ../build)
HACSJAR = $(abspath .)
include Hacs.mk

realclean ::; rm -fr $(BUILD)

# Install setup.
prefix = $$HOME/.hacs
LIBDIR = $(prefix)/lib/hacs
BINDIR = $(prefix)/bin
DOCDIR = $(prefix)/share/doc/hacs
SHAREDIR = $(prefix)/share/hacs
SHAREJAVA = $(prefix)/share/java


# DOWNLOAD STUFF.

all ::

# The CRSX platform.
$(CRSXJAR) :
	wget "http://crsx.org/$(notdir $(CRSXJAR))"
	@mkdir -p $(dir $(CRSXJAR))
	mv $(notdir $(CRSXJAR)) $(CRSXJAR)

clean ::; rm -f crsx*.jar

# The JavaCC utility.
all :: $(JAVACCJAR)
$(JAVACCJAR) :
	rm -fr javacc*
	wget "https://java.net/projects/javacc/downloads/download/$(basename $(notdir $(JAVACCJAR))).zip"
	unzip $(basename $(notdir $(JAVACCJAR))).zip
	@mkdir -p $(dir $(CRSXJAR))
	cp -a $(basename $(notdir $(JAVACCJAR)))/bin/lib/javacc.jar $(JAVACCJAR)
	chmod u+w $(JAVACCJAR)

clean ::; rm -fr javacc*

# The ICU4C libraries (dependency uses one arbitrary library file).
$(ICU4CDIR)/libicudata.so : icu4c-54_1-RHEL6-x64.tgz
	rm -fr usr ../lib/icu4c
	tar xpzf icu4c-54_1-RHEL6-x64.tgz
	mv usr/local $(dir $(dir $(ICU4CDIR)))
	rmdir usr

icu4c-54_1-RHEL6-x64.tgz :
	wget "http://download.icu-project.org/files/icu4c/54.1/icu4c-54_1-RHEL6-x64.tgz"

# HACS MASTER FILE LIST

# All CRSX rules of HACS.
RULES = \
	org/crsx/hacs/Prelude.crs \
	org/crsx/hacs/Prelude.pg \
	org/crsx/hacs/Util.crs \
	org/crsx/hacs/Prep.crs \
	org/crsx/hacs/Cook.crs \
	org/crsx/hacs/Hacs.crs \
	org/crsx/hacs/HxRaw.crs \
	org/crsx/hacs/MakeRun.crs \
	org/crsx/hacs/Hx.pgnames \
	org/crsx/hacs/Hx.pgdecs \
	org/crsx/hacs/Hx.pgpre \
	org/crsx/hacs/Hx.pgpost \

define FROM_SOURCE
$(BUILD)/$(1) : $(1)
	@mkdir -p $(dir $(BUILD)/$(1))
	cp $(1) $(BUILD)/$(1)
endef
$(foreach R,$(RULES),$(eval $(call FROM_SOURCE,$(R))))

# HACS BUILD DEPENDENCIES.

# Version.

all :: $(BUILD)/org/crsx/hacs/VERSION

$(BUILD)/org/crsx/hacs/VERSION: ../VERSION
	@mkdir -p $(BUILD)/org/crsx/hacs
	cp ../VERSION $(BUILD)/org/crsx/hacs

# Hack to set HACSVERSION and HACSMAJORVERSION for this Makefile.
$(eval HACS$(shell cat ../VERSION))
$(eval HACSMAJOR$(shell cat ../VERSION))
### $(eval HACSMAJOR$(basename $(shell cat ../VERSION)))

# Jar has classes and resources...

all :: $(BUILD)/share/java/hacs.jar
install ::
	@mkdir -p $(DESTDIR)$(SHAREJAVA)
	cp $(BUILD)/share/java/hacs-$(HACSMAJORVERSION).jar $(DESTDIR)$(SHAREJAVA)
	cd $(DESTDIR)$(SHAREJAVA) && $(X) ln -fs hacs-$(HACSMAJORVERSION).jar hacs.jar

$(BUILD)/share/java/hacs.jar: \
		$(BUILD)/org/crsx/hacs/HxRaw.class \
		$(BUILD)/org/crsx/hacs/Prelude.class \
		$(BUILD)/org/crsx/hacs/VERSION \
		$(addprefix $(BUILD)/,$(RULES))
	rm -f $(BUILD)/share/java/hacs-$(HACSMAJORVERSION).jar $(BUILD)/share/java/hacs.jar
	@mkdir -p $(BUILD)/org/crsx/hacs $(BUILD)/share/java
	for java in $$(find $(BUILD)/org -name '*.java'); do $(X) rm -f $${java%.java}.class; $(X) $(MAKE) $${java%.java}.class; done
	$(MAKE) $(BUILD)/org/crsx/hacs/Prelude.java
	cd $(BUILD) && classes=$$($(X) find org -name '*.class') && $(X) $(JAR) cf $(BUILD)/share/java/hacs-$(HACSMAJORVERSION).jar $(RULES) org/crsx/hacs/VERSION $$classes
	cd $(BUILD)/share/java && $(X) ln -fs hacs-$(HACSMAJORVERSION).jar hacs.jar

# Support jars & libraries.

all :: $(BUILD)/share/java/crsx.jar
install-support :: $(BUILD)/share/java/crsx.jar
	@mkdir -p $(DESTDIR)$(SHAREJAVA)
	cp $(BUILD)/share/java/crsx-$(CRSXVERSION).jar $(DESTDIR)$(SHAREJAVA)
	cd $(DESTDIR)$(SHAREJAVA) && $(X) ln -fs crsx-$(CRSXVERSION).jar crsx.jar

$(BUILD)/share/java/crsx.jar: $(CRSXJAR)
	rm -f $(BUILD)/share/java/crsx-$(CRSXVERSION).jar $(BUILD)/share/java/crsx.jar
	@mkdir -p $(BUILD)/share/java
	cp $(CRSXJAR) $(BUILD)/share/java/crsx-$(CRSXVERSION).jar
	cd $(BUILD)/share/java && $(X) ln -fs crsx-$(CRSXVERSION).jar crsx.jar

all :: $(BUILD)/share/java/javacc.jar
install-support :: $(BUILD)/share/java/javacc.jar
	@mkdir -p $(DESTDIR)$(SHAREJAVA)
	cp $(BUILD)/share/java/javacc-$(JAVACCVERSION).jar $(DESTDIR)$(SHAREJAVA)
	cd $(DESTDIR)$(SHAREJAVA) && $(X) ln -fs javacc-$(JAVACCVERSION).jar javacc.jar

$(BUILD)/share/java/javacc.jar: $(JAVACCJAR)
	rm -f $(BUILD)/share/java/javacc-$(JAVACCVERSION).jar $(BUILD)/share/java/javacc.jar
	@mkdir -p $(BUILD)/share/java
	cp $(JAVACCJAR) $(BUILD)/share/java/javacc-$(JAVACCVERSION).jar
	cd $(BUILD)/share/java && $(X) ln -fs javacc-$(JAVACCVERSION).jar javacc.jar

install-support :: $(ICU4CDIR)/libicudata.so
	@mkdir -p "$(DESTDIR)$(LIBDIR)/icu4c"
	$(RSYNC) -a "$(ICU4CDIR)/.." "$(DESTDIR)$(LIBDIR)/icu4c/."

# CRSX rulecompiler (crsxc).

CRSXC_H = crsx.h invariant.h linter.h prof.h
CRSXC_C = crsx.c crsx_scan.l invariant.c linter.c prof.c
CRSXC_O = crsx.o crsx_scan.o linter.o prof.o

all :: $(BUILD)/lib/hacs/crsxc $(addprefix $(BUILD)/share/hacs/,$(CRSXC_H))
install ::
	@mkdir -p $(DESTDIR)$(LIBDIR) $(DESTDIR)$(SHAREDIR)
	cp -a $(BUILD)/lib/hacs/crsxc $(DESTDIR)$(LIBDIR)
	cp -a $(addprefix $(BUILD)/share/hacs/,$(CRSXC_H)) $(DESTDIR)$(SHAREDIR)

$(BUILD)/lib/hacs/crsxc : crsx-rulecompiler/net/sf/crsx/compiler/c/build/crsxc
	@mkdir -p $(BUILD)/lib/hacs
	cp -a crsx-rulecompiler/net/sf/crsx/compiler/c/build/crsxc $(BUILD)/lib/hacs/

define FROM_RULECOMPILER
$(2)/$(1) : crsx-rulecompiler/net/sf/crsx/compiler/c/$(1)
	@mkdir -p $(2)
	cp -a crsx-rulecompiler/net/sf/crsx/compiler/c/$(1) $(2)/

crsx-rulecompiler/net/sf/crsx/compiler/c/$(1) : $(CRSXJAR) crsx-rulecompiler/net/sf/crsx/compiler/c/build/crsxc
endef

$(foreach H,$(CRSXC_H), $(eval $(call FROM_RULECOMPILER,$(H),$(BUILD)/share/hacs)))

$(foreach C,$(CRSXC_C), $(eval $(call FROM_RULECOMPILER,$(C),$(BUILD)/org/crsx/hacs)))

crsx-rulecompiler/net/sf/crsx/compiler/c/build/crsxc :
	@mkdir -p crsx-rulecompiler
	cd crsx-rulecompiler && $(X) $(JAR) xf $(CRSXJAR) net/sf/crsx/compiler
	$(MAKE) -j3 ICU4CDIR=$(ICU4CDIR) ICU4CINCLUDE=$(ICU4CINCLUDE) -C crsx-rulecompiler/net/sf/crsx/compiler/c build/crsxc

gitclean ::
	rm -fr crsx-rulecompiler

# HACS standard prelude.

$(BUILD)/org/crsx/hacs/Prelude.jj: $(BUILD)/org/crsx/hacs/Prelude.pg
$(BUILD)/org/crsx/hacs/Prelude.java: $(BUILD)/org/crsx/hacs/Prelude.jj
$(BUILD)/org/crsx/hacs/Prelude.class: $(BUILD)/org/crsx/hacs/Prelude.java

# HACS "raw" parser bootstrapping dependencies.

$(BUILD)/org/crsx/hacs/HxRaw.pgtemplate: org/crsx/hacs/HxRaw.pgtemplate
	@mkdir -p $(BUILD)/org/crsx/hacs
	cp org/crsx/hacs/HxRaw.pgtemplate $(BUILD)/org/crsx/hacs

$(BUILD)/org/crsx/hacs/HxRaw.jj: $(BUILD)/org/crsx/hacs/HxRaw.pg
$(BUILD)/org/crsx/hacs/HxRaw.java: $(BUILD)/org/crsx/hacs/HxRaw.jj
$(BUILD)/org/crsx/hacs/HxRaw.class: $(BUILD)/org/crsx/hacs/HxRaw.java

# HACS main rewriter.

all :: $(BUILD)/lib/hacs/HacsRewriter
install ::
	@mkdir -p $(DESTDIR)$(LIBDIR)
	cp -a $(BUILD)/lib/hacs/HacsRewriter $(DESTDIR)$(LIBDIR)

$(BUILD)/lib/hacs/HacsRewriter : $(BUILD)/org/crsx/hacs/HacsRewriter
	@mkdir -p $(BUILD)/lib/hacs
	cp $(BUILD)/org/crsx/hacs/HacsRewriter $(BUILD)/lib/hacs

$(BUILD)/org/crsx/hacs/HacsRewriter: $(addprefix $(BUILD)/org/crsx/hacs/Hacs, .o _sorts.o _rules.o _symbols.o) $(addprefix $(BUILD)/org/crsx/hacs/, crsx.o crsx_scan.o linter.o prof.o)

$(BUILD)/org/crsx/hacs/Hacs.o: $(BUILD)/org/crsx/hacs/Hacs.c $(BUILD)/org/crsx/hacs/Hacs.h $(BUILD)/share/hacs/crsx.h $(BUILD)/share/hacs/linter.h
$(BUILD)/org/crsx/hacs/Hacs_sorts.o: $(BUILD)/org/crsx/hacs/Hacs_sorts.c $(BUILD)/org/crsx/hacs/Hacs.h $(BUILD)/share/hacs/crsx.h
$(BUILD)/org/crsx/hacs/Hacs_rules.o: $(BUILD)/org/crsx/hacs/Hacs_rules.c $(BUILD)/org/crsx/hacs/Hacs.h $(BUILD)/share/hacs/crsx.h
$(BUILD)/org/crsx/hacs/Hacs_symbols.o: $(BUILD)/org/crsx/hacs/Hacs_symbols.c $(BUILD)/org/crsx/hacs/Hacs.h $(BUILD)/share/hacs/crsx.h

$(BUILD)/org/crsx/hacs/crsx.o : $(BUILD)/org/crsx/hacs/crsx.c $(BUILD)/share/hacs/crsx.h $(BUILD)/share/hacs/prof.h $(BUILD)/share/hacs/invariant.h
$(BUILD)/org/crsx/hacs/crsx_scan.o : $(BUILD)/org/crsx/hacs/crsx_scan.c $(BUILD)/share/hacs/crsx.h
$(BUILD)/org/crsx/hacs/linter.o : $(BUILD)/org/crsx/hacs/linter.c $(BUILD)/share/hacs/crsx.h
$(BUILD)/org/crsx/hacs/prof.o : $(BUILD)/org/crsx/hacs/prof.c $(BUILD)/share/hacs/crsx.h

ifndef FROMZIP

$(BUILD)/org/crsx/hacs/Hacs.h: $(BUILD)/org/crsx/hacs/Hacs.dr.gz
$(BUILD)/org/crsx/hacs/Hacs_sorts.c: $(BUILD)/org/crsx/hacs/Hacs.dr.gz
$(BUILD)/org/crsx/hacs/Hacs_rules.c: $(BUILD)/org/crsx/hacs/Hacs.dr.gz
$(BUILD)/org/crsx/hacs/Hacs_symbols.c: $(BUILD)/org/crsx/hacs/Hacs.dr.gz

$(BUILD)/org/crsx/hacs/Hacs.c: crsx-rulecompiler/net/sf/crsx/compiler/c/main.c
	cp crsx-rulecompiler/net/sf/crsx/compiler/c/main.c $(BUILD)/org/crsx/hacs/Hacs.c

$(BUILD)/org/crsx/hacs/Hacs.dr.gz: $(BUILD)/org/crsx/hacs/Hacs.crs $(BUILD)/lib/hacs/crsxc $(addprefix $(BUILD)/,$(RULES))

all-debug :: $(BUILD)/org/crsx/hacs/Hacs.crsd

endif

# HACS user command.

all :: $(BUILD)/share/hacs/Hacs.mk $(BUILD)/share/hacs/Env.mk $(BUILD)/bin/hacs
install ::
	@mkdir -p $(DESTDIR)$(SHAREDIR) $(DESTDIR)$(BINDIR)
	cp $(BUILD)/share/hacs/Hacs.mk $(BUILD)/share/hacs/Env.mk $(DESTDIR)$(SHAREDIR)
	cp -a $(BUILD)/bin/hacs $(DESTDIR)$(BINDIR)

$(BUILD)/share/hacs/Hacs.mk $(BUILD)/share/hacs/Env.mk : Hacs.mk Env.mk
	@mkdir -p $(BUILD)/share/hacs
	cp Hacs.mk Env.mk $(BUILD)/share/hacs

$(BUILD)/bin/hacs: hacs.sh.template
	@mkdir -p $(BUILD)/bin
	$(GNUSED) \
		-e 's;%%%HACSVERSION%%%;$(HACSVERSION);' \
		-e 's;%%%LIBDIR%%%;$(LIBDIR);' \
		-e 's;%%%BINDIR%%%;$(BINDIR);' \
		-e 's;%%%DOCDIR%%%;$(DOCDIR);' \
		-e 's;%%%SHAREDIR%%%;$(SHAREDIR);' \
		-e 's;%%%SHAREJAVA%%%;$(SHAREJAVA);' \
		-e 's;%%%ICU4CINCLUDE%%%;$(ICU4CINCLUDE);' \
		-e 's;%%%ICU4CDIR%%%;$(ICU4CDIR);' \
		'$<' > '$@.tmp'
	chmod +x '$@.tmp'
	mv '$@.tmp' '$@'

# HACS documents.

DOCUMENTS = README.md
SAMPLES = samples/First.hx samples/Bool.hx samples/IsCat.hx samples/WordSet.hx samples/WordMap.hx samples/WordPairs.hx samples/WordSubst.hx

all :: $(addprefix $(BUILD)/share/doc/hacs/,$(notdir $(DOCUMENTS))) $(addprefix $(BUILD)/share/doc/hacs/examples/,$(notdir $(SAMPLES)))

$(addprefix $(BUILD)/share/doc/hacs/,$(notdir $(DOCUMENTS))) : $(addprefix ../,$(DOCUMENTS))
	@mkdir -p $(BUILD)/share/doc/hacs/examples
	cp $(addprefix ../,$(DOCUMENTS)) $(BUILD)/share/doc/hacs

$(addprefix $(BUILD)/share/doc/hacs/examples/,$(notdir $(SAMPLES))) : $(addprefix ../,$(SAMPLES))
	@mkdir -p $(BUILD)/share/doc/hacs/examples
	cp $(addprefix ../,$(SAMPLES)) $(BUILD)/share/doc/hacs/examples

install ::
	@mkdir -p $(DESTDIR)$(DOCDIR)/examples
	cp $(addprefix $(BUILD)/share/doc/hacs/,$(notdir $(DOCUMENTS))) $(DESTDIR)$(DOCDIR)
	cp $(addprefix $(BUILD)/share/doc/hacs/examples/,$(notdir $(SAMPLES))) $(DESTDIR)$(DOCDIR)/examples

# Documents.

clean::; rm -f *.tmp *~ ./#* *.log *~ *.aux *.bbl *.blg *.toc *.out *.idx *.ind
realclean::; rm -fr auto *.pdf

%.pdf : %.tex
	pdflatex $*
	grep -vq bibcite $*.aux || bibtex $*
	pdflatex $*
	pdflatex $*


### # ===========
### # SETUP RULES
### # ===========
### 
### TMP = $(ROOT)/tmp
### 
### # Unpack support files from CRSX jar.
### crsx.h crsx.c crsx_scan.l: $(CRSXJAR)
### 	@rm -fr $(TMP)
### 	@mkdir -p $(TMP)
### 	(cd $(TMP) && $(JAR) xf $(CRSXJAR) net/sf/crsx/compiler/c/crsx.h net/sf/crsx/compiler/c/crsx.c net/sf/crsx/compiler/c/crsx_scan.l)
### 	@cp -v $(TMP)/net/sf/crsx/compiler/c/crsx.h crsx.h
### 	@cp -v $(TMP)/net/sf/crsx/compiler/c/crsx.c crsx.c
### 	@cp -v $(TMP)/net/sf/crsx/compiler/c/crsx_scan.l crsx_scan.l
### 	@rm -fr $(TMP)
### 
### crsx_scan.o: crsx_scan.c crsx.h
### crsx_scan.c: crsx_scan.l
### 	$(FLEX) -v -s -o crsx_scan.c crsx_scan.l
### clean::; rm -f crsx_scan.c
### 
### realclean::; rm -fr crsx.h crsx.c crsx_scan.l $(ROOT)/rulecompiler
### 
### 
### # Build HACS 'Prep' utility.
### $(PREP): $(CRSXJAR)
### 	@/bin/echo -e '\n* Regenerate internal HACS binaries...'
### 	$(MAKE) -C $(ROOT) Prepmain
### 
### 
### ## Debugging helpers.
### 
### %.crsE: %.crs %.pg-installed
### 	@set -x \
### 	&& $(X) parser=$$(sed -n 's/^class \(.*\) :.*/\1/p' '$*.pg') \
### 	&& $(X) $(CRSX) grammar='("'$$parser'";"net.sf.crsx.text.Text";)' rules='$*.crs' dump-rules=$@.tmp \
### 	&& $(X) mv '$@.tmp' '$@'
### 
### %.crsD: %.crs %.pg-installed
### 	@set -x \
### 	&& $(X) parser=$$(sed -n 's/^class \(.*\) :.*/\1/p' '$*.pg') \
### 	&& $(X) $(CRSX) grammar='("'$$parser'";"net.sf.crsx.text.Text";)' rules='$*.crs' sortify dispatchify dump-rules=$@.tmp \
### 	&& $(X) mv '$@.tmp' '$@'
### 
### realclean::; rm -f *.crsE
### 
### 
### 
### # Generic -*-Makefile-*- setup for HACS.
### # 
### 
### # Note: You should not need to modify anything in this file.
### # If any of the following system commands are not right then
### # set them correctly in your local Makefile.
### 
### # So -n works...
### X = $(if,$(findstring -n,$(MAKE)),echo)
### SH_EXTRA = :
### 
### 
### # =====================
### # HACS GENERATION RULES
### # =====================
### 
### # The following steps support dependencies of the form
### #   mycompiler.run : mycompiler.hx
### 
### .SECONDARY:
### 
### # (0) Preprocess .hx to get "raw" simple term.
### #
### %.hxp : %.hx
### 	@/bin/echo -e '\n* Processing $<.' && $(SH_EXTRA) \
### 	&& $(X) $(CRSX) \
### 		"grammar=('org.crsx.hacs.Raw';'net.sf.crsx.text.Text';)" \
### 		input='$<' category=rawModule \
### 		output='$@.tmp' simple-terms max-indent=10 width=255 \
### 	&& $(X) mv '$@.tmp' '$@'
### 
### clean::; rm -f *.hxp
### 
### # (1a) Generate PG grammar.
### #
### %.pg : %.hxt $(MAKEPG) 
### 	$(MAKEPG) PG $< > $@
### 
### # (1b) Install the PG grammar (process with JavaCC and compile the generated parser).
### #
### %.pg-installed : %.pg $(JAVACCJAR)
### 	@/bin/echo -e '\n* Generating and Compiling JavaCC parser for $<.' && $(SH_EXTRA) \
### 	&& $(X) class=$$(sed -n 's/^class \(.*\)Parser :.*/\1/p' '$*.pg') \
### 	&& $(X) base=$$(echo $$class | sed 's:\.:/:g') \
### 	&& $(X) mkdir -p $(BUILD)/$$(dirname $$base) \
### 	&& (test '$*.pg' -ot $(BUILD)/$${base}Parser.pg || $(X) cp -v '$*.pg' $(BUILD)/$${base}Parser.pg) \
### 	&& (test '$*.pg' -ot $(BUILD)/$${base}Parser.jj || $(X) $(PG) '$*.pg' -source=$(BUILD)) \
### 	&& (cd $(BUILD) && (test $${base}Parser.jj -ot $${base}Parser.java || $(X) $(JAVACC) -OUTPUT_DIRECTORY=$$(dirname $$base) $${base}Parser.jj)) \
### 	&& (cd $(BUILD) && (test $${base}Parser.java -ot $(BUILD)/$${base}Parser.class || $(X) $(JAVAC) -cp '$(BUILD):$(CRSXJAR):$(JAVACCJAR)' -sourcepath $(BUILD) -d $(BUILD) $${base}Parser.java))
### 	@touch $@
### 
### realclean::; rm -f *.pg *.pg-installed
### 
### # (2a) Generate CRSX system.
### #
### %.crs : %.hxt $(PREP) 
### 	$(PREP) CRS $< > $@
### 
### # (2b) Install generated CRSX system.
### #
### %.crs-installed: %.crs %.pg-installed
### 	@/bin/echo -e '\n* Checking and installing generated $< rules.' && $(SH_EXTRA) \
### 	&& $(X) parser=$$(sed -n 's/^class \(.*\) :.*/\1/p' '$*.pg') \
### 	&& $(X) class=$$(sed -n 's/^class \(.*\)Parser :.*/\1/p' '$*.pg') \
### 	&& $(X) base=$$(echo $$class | sed 's:\.:/:g') \
### 	&& $(X) $(CRSX) grammar='("'$$parser'";"net.sf.crsx.text.Text";)' rules='$*.crs' \
### 	&& (test '$*.crs' -ot $(BUILD)/$${base}Rules.crs || $(X) cp -v '$*.crs' $(BUILD)/$${base}Rules.crs)
### 	@touch $@
### 
### realclean::; rm -f *.crs *.crs-installed
### 
### # (3) Generate executable.
### 
### # (3a) Dispatchify.
### #
### %.dr: $(CRSXJAR)
### 	$(CRSX) rules=org/crsx/hacs/$*.crs sortify dispatchify reify=$@ simple-terms omit-linear-variables canonical-variables
### 
### clean::; rm -f *.dr
### 
### # (3b) Generate C files.
### #
### %.h: %.dr $(RULEC)
### 	$(RULEC) wrapper=ComputeHeader HEADERS="crsx.h" input=$< output=$@
### 
### %_sorts.c: %.dr $(RULEC)
### 	$(RULEC) wrapper=ComputeSorts HEADERS="$*.h" input=$< output=$@
### %_sorts.o: %_sorts.c %.h
### 
### %_rules.c: %.dr $(RULEC)
### 	$(RULEC) wrapper=ComputeRules HEADERS="$*.h" input=$< output=$@
### %_rules.o: %_rules.c %.h
### 
### %.rawsymlist: %.dr $(RULEC)
### 	$(RULEC) wrapper=ComputeSymbols input=$< output=$@.tmp
### 	sed 's/ {/\n{/g' $@.tmp | sed -n '/^[{]/p' >$@
### 
### %_symbols.c: %.rawsymlist
### 	LC_ALL=C sort -bu $< | sed -n '/./p' > $@.tmp
### 	@(echo '/* $*ing symbols. */'; \
### 	  echo '#include "$*.h"'; \
### 	  echo "size_t symbolDescriptorCount = $$(wc -l <$@.tmp);"; \
### 	  echo 'struct _SymbolDescriptor symbolDescriptorTable[] = {';\
### 	  cat $@.tmp;\
### 	  echo '{NULL, NULL}};') > $@
### %_symbols.o: %_symbols.c %.h
### 
### %main.o: %main.c %.h
### %main: %main.o %_sorts.o %_rules.o %_symbols.o crsx.o crsx_scan.o
### 	$(CC) -o $*main $*main.o $*_sorts.o $*_rules.o $*_symbols.o crsx.o crsx_scan.o -licuuc -licudata -licui18n -licuio
### clean::; rm -f *.o
### 
### # (3c) Generate executable.
### #
### %.run-c: %.crs-compiled %.pg-installed
### 	@/bin/echo -e '\n* Generating custom compilation script $@.' && $(SH_EXTRA) \
### 	&& $(X) class=$$(sed -n 's/^class \(.*\)Parser :.*/\1/p' '$*.pg') \
### 	&& $(X) prefix=$$(sed -n 's/^prefix //p' '$*.pg') \
### 	&& $(X) base=$$(echo $$class | sed -e 's:\.:/:g') \
### 	&& (echo exec env "JAVA='$(JAVA)'" "JAVAC='$(JAVAC)'" "CRSXJAR='$(CRSXJAR)'" \
### 			"HACSBUILD='$(BUILD)'" "HACSPARSERCLASS='$${class}Parser'" "HACSRULES='$(BUILD)/$${base}Rules.crs'" \
### 			"HACSPREFIX='$$prefix'" \
### 			'$(ROOT)/run-hacs.sh' '"$$@"' > '$@.tmp') \
### 	&& $(X) mv '$@.tmp' '$@' \
### 	&& $(X) chmod +x $@
### 
### 
### # ====================
### # INTERPRETER VARIANTS
### # ====================
### 
### # (1a, using interpreter)
### %.pg-ref : %.hx
### 	@set -x \
### 	&& $(X) $(CRSX) \
### 		"grammar=('org.crsx.hacs.bootstrap.Raw';'net.sf.crsx.text.Text';)" \
### 		rules=org/crsx/hacs/PrepPG.crs wrapper=PG \
### 		input='$<' category=rawModule \
### 		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
### 	&& $(X) mv '$@.tmp' '$@'
### 
### # (2a, using interpreter)
### %.crs-ref : %.hx
### 	@set -x \
### 	&& $(X) $(CRSX) \
### 		"grammar=('org.crsx.hacs.bootstrap.Raw';'net.sf.crsx.text.Text';)" \
### 		rules=org/crsx/hacs/PrepCRS.crs wrapper=CRS \
### 		input='$<' category=rawModule \
### 		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
### 	&& $(X) mv '$@.tmp' '$@'
### 
### # (3, using interpreter)
### %.run: %.crs-installed %.pg-installed
### 	@/bin/echo -e '\n* Generating custom compilation script $@.' && $(SH_EXTRA) \
### 	&& $(X) class=$$(sed -n 's/^class \(.*\)Parser :.*/\1/p' '$*.pg') \
### 	&& $(X) prefix=$$(sed -n 's/^prefix //p' '$*.pg') \
### 	&& $(X) base=$$(echo $$class | sed -e 's:\.:/:g') \
### 	&& (echo exec env "JAVA='$(JAVA)'" "JAVAC='$(JAVAC)'" "CRSXJAR='$(CRSXJAR)'" \
### 			"HACSBUILD='$(BUILD)'" "HACSPARSERCLASS='$${class}Parser'" "HACSRULES='$(BUILD)/$${base}Rules.crs'" \
### 			"HACSPREFIX='$$prefix'" \
### 			'$(ROOT)/run-hacs.sh' '"$$@"' > '$@.tmp') \
### 	&& $(X) mv '$@.tmp' '$@' \
### 	&& $(X) chmod +x $@
### 
### realclean::; rm -f *.crs-ref *.pg-ref *.run
