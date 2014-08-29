# Makefile for compiling hacs/src.


# SETUP.

#TODO: Eliminate this hard-coding once crsx package exists...
CRSXROOT = $(abspath ../../crsx)
BUILD = ../build
include ../Hacs.mk


# STANDARD TARGETS.

.PHONY: all clean realclean install
all::
clean::; rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
install::


# HACS BUILD DEPENDENCIES.

# Get ball rolling...
all:: $(BUILD)/org/crsx/hacs/HxRaw.class

# Generic cleanup.
clean::
	rm -f org/crsx/hacs/*~ org/crsx/hacs/#*
	rm -f org/crsx/hacs/*.java org/crsx/hacs/*.jj org/crsx/hacs/*.crsp
	rm -fr $(BUILD)

# Raw parser for .hx files (as used by CookPG).
org/crsx/hacs/HxRaw.pg: org/crsx/hacs/HxRaw.pgtemplate org/crsx/hacs/Hx.pgnames org/crsx/hacs/Hx.pgpre org/crsx/hacs/Hx.pgpost
	sed \
	 -e '/%%%HXNONTERMINALS%%%/ bnames' \
	 -e '/%%%HXPREPRODUCTIONS%%%/ bpre' \
	 -e '/%%%HXPOSTPRODUCTIONS%%%/ bpost' \
	 -e 'b' \
	 -e ':names' -e 'r org/crsx/hacs/Hx.pgnames' -e 'd' \
	 -e ':pre'   -e 'r org/crsx/hacs/Hx.pgpre' -e 'd' \
	 -e ':post'  -e 'r org/crsx/hacs/Hx.pgpost' -e 'd' \
	 org/crsx/hacs/HxRaw.pgtemplate \
	| sed -e 's/%%%PREFIX%%%/Hx/g' \
	> '$@.tmp'
	mv '$@.tmp' '$@'
#
org/crsx/hacs/HxRaw.jj: org/crsx/hacs/HxRaw.pg
org/crsx/hacs/HxRaw.java: org/crsx/hacs/HxRaw.jj
$(BUILD)/org/crsx/hacs/HxRaw.class: org/crsx/hacs/HxRaw.java
#
clean::; rm -f org/crsx/hacs/HxRaw.pg








### # Distribution.
### TOPFILES = 00README-hacs Makefile-hacs-template first.hx doc/hacs-gently.pdf
### HACSSOURCES = Makefile Makefile-hx crsx.jar Cookmain.c run-hacs.sh
### HACSGENERATED = Cook.h Cook_sorts.c Cook_rules.c Cook_symbols.c
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
### # HACS Cook utility dependencies.
### Cookmain.o: Cookmain.c Cook.h crsx.h
### Cookmain: Cookmain.o Cook_sorts.o Cook_rules.o Cook_symbols.o crsx.o crsx_scan.o
### #	$(CC) -o Cookmain Cookmain.o Cook_sorts.o Cook_rules.o Cook_symbols.o crsx.o crsx_scan.o -licuuc -licudata -licui18n -licuio
### clean::; rm -f Cook_* Cook.*
### realclean::; rm -fr Cookmain tmp

### # Distribution.
### TOPFILES = 00README-hacs Makefile-hx Makefile-hacs-template
### HACSSOURCES = Makefile crsx.jar Cookmain.c run-hacs.sh
### HACSGENERATED = Cook.h Cook_sorts.c Cook_rules.c Cook_symbols.c
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
### # HACS Cook utility dependencies.
### Cookmain.o: Cookmain.c Cook.h crsx.h
### Cookmain: Cookmain.o Cook_sorts.o Cook_rules.o Cook_symbols.o crsx.o crsx_scan.o
### #	$(CC) -o Cookmain Cookmain.o Cook_sorts.o Cook_rules.o Cook_symbols.o crsx.o crsx_scan.o -licuuc -licudata -licui18n -licuio
### clean::; rm -f Cook_* Cook.*
### realclean::; rm -fr Cookmain tmp
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
### # Build HACS 'Cook' utility.
### $(COOK): $(CRSXJAR)
### 	@/bin/echo -e '\n* Regenerate internal HACS binaries...'
### 	$(MAKE) -C $(ROOT) Cookmain
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
### %.crs : %.hxt $(COOK) 
### 	$(COOK) CRS $< > $@
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
### 		rules=org/crsx/hacs/CookPG.crs wrapper=PG \
### 		input='$<' category=rawModule \
### 		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
### 	&& $(NOEXEC) mv '$@.tmp' '$@'
### 
### # (2a, using interpreter)
### %.crs-ref : %.hx
### 	@set -x \
### 	&& $(NOEXEC) $(CRSX) \
### 		"grammar=('org.crsx.hacs.bootstrap.Raw';'net.sf.crsx.text.Text';)" \
### 		rules=org/crsx/hacs/CookCRS.crs wrapper=CRS \
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
