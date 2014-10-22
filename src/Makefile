# Makefile for compiling hacs/src.
#
# Generate and install all HACS runtime artifacts.
#
# Usage:
#   make
#   make USR=/usr/local install
#
# Environment variables:
# - USR - root of installation (/usr/local by default).


# STANDARD TARGETS.

.PHONY: all clean realclean install
all ::
clean ::; rm -f *.tmp *~ ./#* *.log *~
realclean :: clean
install ::


# SETUP.

DESTDIR = $(abspath .)
USR = $(DESTDIR)/usr/local

# Environment.
include Env.mk

# Hacs.mk setup
HACSJAR = $(abspath .)
HACSLIB = $(USR)/lib/hacs
HACSBIN = $(USR)/bin
HACSSHARE = $(USR)/share/hacs
BUILD = $(abspath build)
CRSXJAR = $(abspath ../lib/crsx.jar)
include Hacs.mk
#
realclean ::
	rm -fr build

# Install setup.
JAVAJARDIR = $(USR)/share/java


# HACS MASTER FILE LIST

# All CRSX rules of HACS.
RULES = \
	org/crsx/hacs/Prelude.crs \
	org/crsx/hacs/Util.crs \
	org/crsx/hacs/Prep.crs \
	org/crsx/hacs/Cook.crs \
	org/crsx/hacs/Main.crs \
	org/crsx/hacs/MakeRun.crs


# HACS BUILD DEPENDENCIES.

# Version.

all :: $(BUILD)/org/crsx/hacs/VERSION

$(BUILD)/org/crsx/hacs/VERSION: ../VERSION
	mkdir -p $(BUILD)/org/crsx/hacs
	cp ../VERSION $(BUILD)/org/crsx/hacs

# Hack to set HACSVERSION and HACSMAJORVERSION for this Makefile.
$(eval HACS$(shell cat ../VERSION))
$(eval HACSMAJOR$(basename $(shell cat ../VERSION)))

# Jar has classes and resources...

all :: $(BUILD)/share/java/hacs.jar
install ::
	cp hacs-$(HACSMAJORVERSION).jar $(JAVAJARDIR)
	cd $(JAVAJARDIR) && $(NOEXEC) ln -s hacs-$(HACSMAJORVERSION).jar hacs.jar

$(BUILD)/share/java/hacs.jar: \
		$(BUILD)/org/crsx/hacs/HxRaw.class \
		$(BUILD)/org/crsx/hacs/VERSION \

	rm -f $(BUILD)/share/java/hacs-$(HACSMAJORVERSION).jar $(BUILD)/share/java/hacs.jar
	mkdir -p $(BUILD)/org/crsx/hacs $(BUILD)/share/java/hacs.jar
	cp $(RULES) $(BUILD)/org/crsx/hacs
	cd $(BUILD) && classes=$$($(NOEXEC) find org -name '*.class') && $(NOEXEC) $(JAR) cf $(BUILD)/share/java/hacs-$(HACSMAJORVERSION).jar $(RULES) $$classes
	cd $(BUILD)/share/java && $(NOEXEC) ln -s hacs-$(HACSMAJORVERSION).jar hacs.jar

realclean ::
	rm -f *.jar

# HACS "raw" parser bootstrapping dependencies.

$(BUILD)/org/crsx/hacs/HxRaw.pgtemplate: org/crsx/hacs/HxRaw.pgtemplate
	mkdir -p $(BUILD)/org/crsx/hacs
	cp org/crsx/hacs/HxRaw.pgtemplate $(BUILD)/org/crsx/hacs

$(BUILD)/org/crsx/hacs/HxRaw.jj: $(BUILD)/org/crsx/hacs/HxRaw.pg
$(BUILD)/org/crsx/hacs/HxRaw.java: $(BUILD)/org/crsx/hacs/HxRaw.jj
$(BUILD)/org/crsx/hacs/HxRaw.class: $(BUILD)/org/crsx/hacs/HxRaw.java

# Rulecompiler.

all :: $(BUILD)/bin/crsxc
install :: $(BUILD)/bin/crsxc
	mkdir -p $(HACSBIN)
	cp -a $(BUILD)/bin/crsxc $(HACSBIN)

crsx-rulecompiler/net/sf/crsx/compiler/c/build/crsxc : $(CRSXJAR)
	rm -fr crsx-rulecompiler
	mkdir -p crsx-rulecompiler
	cd crsx-rulecompiler && $(NOEXEC) $(JAR) xvf $(CRSXJAR) net/sf/crsx/compiler
	$(MAKE) -C crsx-rulecompiler/net/sf/crsx/compiler/c

$(BUILD)/bin/crsxc : crsx-rulecompiler/net/sf/crsx/compiler/c/build/crsxc
	mkdir -p $(BUILD)/bin
	cp -a crsx-rulecompiler/net/sf/crsx/compiler/c/build/crsxc $(BUILD)/bin/crsxc

realclean ::
	rm -fr crsx-rulecompiler


### # Distribution.
### TOPFILES = 00README-hacs Makefile-hacs-template first.hx doc/hacs-gently.pdf
### HACSSOURCES = Makefile Makefile-hx crsx.jar Prepmain.c run-hacs.sh
### HACSGENERATED = Prep.h Prep_sorts.c Prep_rules.c Prep_symbols.c
### 
### hacs.zip: $(TOPFILES)
### 	@rm -fr hacs.zip tmp
### 	$(MAKE) -C $(BUILD) clean $(HACSSOURCES) $(HACSGENERATED)
### 	mkdir -p tmp/hacs
### 	cp -vp $(TOPFILES) tmp/
### 	d="`pwd`" && cd $(HACS) && cp -vp $(HACSSOURCES) $(HACSGENERATED) $$d/tmp/hacs/
### 	d="`pwd`" && cd tmp && zip -r $$d/hacs.zip .
### 	rm -fr tmp
### 
### # HACS Prep utility dependencies.
### Prepmain.o: Prepmain.c Prep.h crsx.h
### Prepmain: Prepmain.o Prep_sorts.o Prep_rules.o Prep_symbols.o crsx.o crsx_scan.o
### #	$(CC) -o Prepmain Prepmain.o Prep_sorts.o Prep_rules.o Prep_symbols.o crsx.o crsx_scan.o -licuuc -licudata -licui18n -licuio
### clean::; rm -f Prep_* Prep.*
### realclean::; rm -fr Prepmain tmp

### # Distribution.
### TOPFILES = 00README-hacs Makefile-hx Makefile-hacs-template
### HACSSOURCES = Makefile crsx.jar Prepmain.c run-hacs.sh
### HACSGENERATED = Prep.h Prep_sorts.c Prep_rules.c Prep_symbols.c
### 
### hacs.zip: $(TOPFILES)
### 	@rm -fr hacs.zip tmp
### 	$(MAKE) -C $(BUILD) clean $(HACSSOURCES) $(HACSGENERATED)
### 	mkdir -p tmp/hacs
### 	cp -vp $(TOPFILES) tmp/
### 	d="`pwd`" && cd $(HACS) && cp -vp $(HACSSOURCES) $(HACSGENERATED) $$d/tmp/hacs/
### 	d="`pwd`" && cd tmp && zip -r $$d/hacs.zip .
### 	rm -fr tmp
### 
### # HACS Prep utility dependencies.
### Prepmain.o: Prepmain.c Prep.h crsx.h
### Prepmain: Prepmain.o Prep_sorts.o Prep_rules.o Prep_symbols.o crsx.o crsx_scan.o
### #	$(CC) -o Prepmain Prepmain.o Prep_sorts.o Prep_rules.o Prep_symbols.o crsx.o crsx_scan.o -licuuc -licudata -licui18n -licuio
### clean::; rm -f Prep_* Prep.*
### realclean::; rm -fr Prepmain tmp
### 
### # Final build location.
### BUILDROOT = build
### BUILDPACK = $(BUILDROOT)/org/crsx/hacs
### $(BUILDPACK):; mkdir -p $(BUILDPACK)
### realclean::; rm -fr $(BUILDROOT)
### 
### # Where the primary source files are.
### HACSSRC = src
### HACSSRCPACK = $(HACSSRC)/org/crsx/hacs
### clean::; rm -f $(HACSSRCPACK)


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
### 	&& $(NOEXEC) parser=$$(sed -n 's/^class \(.*\) :.*/\1/p' '$*.pg') \
### 	&& $(NOEXEC) $(CRSX) grammar='("'$$parser'";"net.sf.crsx.text.Text";)' rules='$*.crs' dump-rules=$@.tmp \
### 	&& $(NOEXEC) mv '$@.tmp' '$@'
### 
### %.crsD: %.crs %.pg-installed
### 	@set -x \
### 	&& $(NOEXEC) parser=$$(sed -n 's/^class \(.*\) :.*/\1/p' '$*.pg') \
### 	&& $(NOEXEC) $(CRSX) grammar='("'$$parser'";"net.sf.crsx.text.Text";)' rules='$*.crs' sortify dispatchify dump-rules=$@.tmp \
### 	&& $(NOEXEC) mv '$@.tmp' '$@'
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
### NOEXEC = $(if,$(findstring -n,$(MAKE)),echo)
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
### 	&& $(NOEXEC) $(CRSX) \
### 		"grammar=('org.crsx.hacs.Raw';'net.sf.crsx.text.Text';)" \
### 		input='$<' category=rawModule \
### 		output='$@.tmp' simple-terms max-indent=10 width=255 \
### 	&& $(NOEXEC) mv '$@.tmp' '$@'
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
### 	&& $(NOEXEC) class=$$(sed -n 's/^class \(.*\)Parser :.*/\1/p' '$*.pg') \
### 	&& $(NOEXEC) base=$$(echo $$class | sed 's:\.:/:g') \
### 	&& $(NOEXEC) mkdir -p $(BUILD)/$$(dirname $$base) \
### 	&& (test '$*.pg' -ot $(BUILD)/$${base}Parser.pg || $(NOEXEC) cp -v '$*.pg' $(BUILD)/$${base}Parser.pg) \
### 	&& (test '$*.pg' -ot $(BUILD)/$${base}Parser.jj || $(NOEXEC) $(PG) '$*.pg' -source=$(BUILD)) \
### 	&& (cd $(BUILD) && (test $${base}Parser.jj -ot $${base}Parser.java || $(NOEXEC) $(JAVACC) -OUTPUT_DIRECTORY=$$(dirname $$base) $${base}Parser.jj)) \
### 	&& (cd $(BUILD) && (test $${base}Parser.java -ot $(BUILD)/$${base}Parser.class || $(NOEXEC) $(JAVAC) -cp '$(BUILD):$(CRSXJAR):$(JAVACCJAR)' -sourcepath $(BUILD) -d $(BUILD) $${base}Parser.java))
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
### 	&& $(NOEXEC) parser=$$(sed -n 's/^class \(.*\) :.*/\1/p' '$*.pg') \
### 	&& $(NOEXEC) class=$$(sed -n 's/^class \(.*\)Parser :.*/\1/p' '$*.pg') \
### 	&& $(NOEXEC) base=$$(echo $$class | sed 's:\.:/:g') \
### 	&& $(NOEXEC) $(CRSX) grammar='("'$$parser'";"net.sf.crsx.text.Text";)' rules='$*.crs' \
### 	&& (test '$*.crs' -ot $(BUILD)/$${base}Rules.crs || $(NOEXEC) cp -v '$*.crs' $(BUILD)/$${base}Rules.crs)
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
### 	&& $(NOEXEC) class=$$(sed -n 's/^class \(.*\)Parser :.*/\1/p' '$*.pg') \
### 	&& $(NOEXEC) prefix=$$(sed -n 's/^prefix //p' '$*.pg') \
### 	&& $(NOEXEC) base=$$(echo $$class | sed -e 's:\.:/:g') \
### 	&& (echo exec env "JAVA='$(JAVA)'" "JAVAC='$(JAVAC)'" "CRSXJAR='$(CRSXJAR)'" \
### 			"HACSBUILD='$(BUILD)'" "HACSPARSERCLASS='$${class}Parser'" "HACSRULES='$(BUILD)/$${base}Rules.crs'" \
### 			"HACSPREFIX='$$prefix'" \
### 			'$(ROOT)/run-hacs.sh' '"$$@"' > '$@.tmp') \
### 	&& $(NOEXEC) mv '$@.tmp' '$@' \
### 	&& $(NOEXEC) chmod +x $@
### 
### 
### # ====================
### # INTERPRETER VARIANTS
### # ====================
### 
### # (1a, using interpreter)
### %.pg-ref : %.hx
### 	@set -x \
### 	&& $(NOEXEC) $(CRSX) \
### 		"grammar=('org.crsx.hacs.bootstrap.Raw';'net.sf.crsx.text.Text';)" \
### 		rules=org/crsx/hacs/PrepPG.crs wrapper=PG \
### 		input='$<' category=rawModule \
### 		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
### 	&& $(NOEXEC) mv '$@.tmp' '$@'
### 
### # (2a, using interpreter)
### %.crs-ref : %.hx
### 	@set -x \
### 	&& $(NOEXEC) $(CRSX) \
### 		"grammar=('org.crsx.hacs.bootstrap.Raw';'net.sf.crsx.text.Text';)" \
### 		rules=org/crsx/hacs/PrepCRS.crs wrapper=CRS \
### 		input='$<' category=rawModule \
### 		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
### 	&& $(NOEXEC) mv '$@.tmp' '$@'
### 
### # (3, using interpreter)
### %.run: %.crs-installed %.pg-installed
### 	@/bin/echo -e '\n* Generating custom compilation script $@.' && $(SH_EXTRA) \
### 	&& $(NOEXEC) class=$$(sed -n 's/^class \(.*\)Parser :.*/\1/p' '$*.pg') \
### 	&& $(NOEXEC) prefix=$$(sed -n 's/^prefix //p' '$*.pg') \
### 	&& $(NOEXEC) base=$$(echo $$class | sed -e 's:\.:/:g') \
### 	&& (echo exec env "JAVA='$(JAVA)'" "JAVAC='$(JAVAC)'" "CRSXJAR='$(CRSXJAR)'" \
### 			"HACSBUILD='$(BUILD)'" "HACSPARSERCLASS='$${class}Parser'" "HACSRULES='$(BUILD)/$${base}Rules.crs'" \
### 			"HACSPREFIX='$$prefix'" \
### 			'$(ROOT)/run-hacs.sh' '"$$@"' > '$@.tmp') \
### 	&& $(NOEXEC) mv '$@.tmp' '$@' \
### 	&& $(NOEXEC) chmod +x $@
### 
### realclean::; rm -f *.crs-ref *.pg-ref *.run
