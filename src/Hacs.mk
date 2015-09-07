# -*-GNUMakefile-*- helper definition for HACS executable.
#
# Context environment variables (should all contain absolute paths):
# - HACSJAR - jar archive or directory containing HACS shared resources.
# - CRSXJAR - jar archive containing CRSX rewrite engine runtime.
# - JAVACCJAR - jar archive containing JavaCC parser generator runtime.
# - CRSXC - compiled CRSX rulecompiler.
#
# - ICU4CINCLUDE - directory with ICU4C headers.
# - ICU4CDIR - directory with ICU4C libraries.
# - LIBDIR - directory with generated HACS binary support files
# - SHAREDIR - directory with HACS support headers
#
# - BUILD - the root directory for intermediate generated files.


# STANDARD TARGETS.

.PHONY: all clean realclean install
all::
clean::; @rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
install:: all

# Common commands.
include Env.mk

# SCRIPTS.

# Parser generator command.
RUNJAVACC = $(JAVA) -cp "$(JAVACCJAR)" javacc

# CRSX tool commands.
RUNPG = $(JAVA) -ea -cp "$(BUILD):$(HACSJAR):$(CRSXJAR)" net.sf.crsx.pg.PG verbose=1 $(EXTRA)
RUNCRSX = $(JAVA) -ea -cp "$(BUILD):$(HACSJAR):$(CRSXJAR)" -Dfile.encoding=UTF-8 -Xss80000K -Xmx4000m net.sf.crsx.run.Crsx allow-unnamed-rules allow-missing-cases sortify verbose=1 $(EXTRA)

# Magic...
X = $(if $(findstring -n,$(MAKE)),$(ECHO))

# Log all commands.
SH_EXTRA = set -x

# Dissect .prep file.
# Usage: $(call PREPEXTRACT,METAPG,source.prep) > 'target.extension'
PREPEXTRACT = $(X) $(GNUSED) \
	-e ':start' \
	-e '/[/][*][*][*]\([^*]\|[*][^*]\)*$$/{N; bstart;}' \
	-e 's./[*][*][*]\([A-Z]*[&]\)*$(1)\([&][A-Z]*\)*: *\(\([^*]\|[*][^*]\)*\)[*][*][*]/.\3.g' \
	-e 'tstart' \
	-e 's./[*][*][*]\([^*]\|[*][^*]\)*[*][*][*]/..g' \
	-e 'tstart' \
	-e 's/ *$$//gM' '$(2)'
#
PREPEXTRACTONLY = $(X) $(GNUSED) \
	-e '/[/][*][*][*]/bstart' \
	-e 'd' \
	-e ':start' \
	-e '/[/][*][*][*]\([^*]\|[*][^*]\)*$$/{N; bstart;}' \
	-e 's./[*][*][*]\(\([^*]\|[*][^*]\)*\)[*][*][*]/.{@@@\1@@@}.g' \
	-e 'tstart' \
	-e ':inner' \
	-e 's.{@@@\([A-Z]*[&]\)*$(1)\([&][A-Z]*\)*: *\(\([^@*]\|[@*][^@*]\)*\)@@@}.{***\3***}.g' \
	-e 's.{@@@\([^@*]\|[@*][^@*]\)*@@@}..g' \
	-e 's.{@@@\(\([A-Z]*[&]\)*$(1)\([&][A-Z]*\)*: *\([^@*]\|[@*][^@*]\)*\){[*][*][*]\(\([^@*]\|[@*][^@*]\)*\)[*][*][*]}.{@@@\1\5.g' \
	-e 'tinner' \
	-e ':outer' \
	-e 's.^\([^*]\|[*][^*]\)\+{[*][*][*].{***.' \
	-e 's.[*][*][*]}\([^*]\|[*][^*]\)*{[*][*][*]..' \
	-e 's.[*][*][*]}\([^*]\|[*][^*]\)\+$$.***}.' \
	-e 'touter' \
	-e 's.{[*][*][*]\(\([^*]\|[*][^*]\)*\)[*][*][*]}.\1.' \
	-e '/^$$/d' \
	-e 's/ *$$//gM' '$(2)'

# Copy resource.
#  - $(call XRESOURCE,resourcepath,targetdir) 
XRESOURCE = $(if $(findstring .jar,$(HACSJAR)), $(X) cd $(2) && $(X) $(JAR) xf $(HACSJAR) $(1), $(X) mkdir -p $(dir $(2)/$(1)) && $(X) cp $(HACSJAR)/$(1) $(2)/$(1) )
#  - $(call CATRESOURCE,resourcepath) 
CATRESOURCE = $(if $(findstring .jar,$(HACSJAR)), $(X) $(UNZIP) -p $(HACSJAR) $(1), $(X) cat $(HACSJAR)/$(1) )


# RULES.

# %.env: the internal setup for generated compiler
%.env : %.hxraw
	@$(ECHO) '\nHACS: Generating environment declarations $@...' $(OUT) && $(SH_EXTRA) \
	&&	( if [ -x "$(LIBDIR)/HacsRewriter" -a -z "$(INTERPRET)" ]; then \
		    $(X) LD_LIBRARY_PATH='$(ICU4CDIR)' $(LIBDIR)/HacsRewriter wrapper=P-PrintEnvironment input='$<' output='$@.tmp' \
		    && $(X) mv '$@.tmp' '$@' ; \
		  else \
		    $(X) $(RUNCRSX) \
			"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
			rules=org/crsx/hacs/Prep.crs wrapper=P-PrintEnvironment \
			input='$<' \
			output='$@.tmp' sink=net.sf.crsx.text.TextSink \
		    && mv '$@.tmp' '$@' ; \
		  fi \
		) $(LOG)

clean::; @rm -f  *.env

# %.run: script implementing user compiler...
%.run : %.env
	@$(ECHO) -e '' $(OUT) && $(NOEXEC) $(ECHO) 'HACS: Generating user script $@ (can be moved)...' && $(SH_EXTRA) \
	&&	( $(shell $(X) cat '$*.env') \
		&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
		&& if [ -x "$(LIBDIR)/HacsRewriter" -a -z "$(INTERPRET)" ]; then \
		     $(X) LD_LIBRARY_PATH='$(ICU4CDIR)' $(LIBDIR)/HacsRewriter term=MakeRun output='$@.tmp' \
		   	$(shell $(X) cat '$*.env') PACKAGE="$$package" PACKAGEDIR="$$packagedir" BUILD='$(BUILD)' \
		   	HACS$$($(call CATRESOURCE,org/crsx/hacs/VERSION)) CRSXJAR='$(CRSXJAR)' HACSJAR='$(HACSJAR)' CRSXC='$(CRSXC)' \
		   	ICU4CINCLUDE='$(ICU4CINCLUDE)' ICU4CDIR='$(ICU4CDIR)' \
		   	LIBDIR='$(LIBDIR)' BINDIR='$(BINDIR)' DOCDIR='$(DOCDIR)' SHAREDIR='$(SHAREDIR)' SHAREJAVA='$(SHAREJAVA)' \
		   	SHELL='$(SHELL)' JAVA='$(JAVA)' JAVAC='$(JAVAC)' \
		     && $(X) mv '$@.tmp' '$@' ; \
		   else \
		     $(X) $(RUNCRSX) \
		   	rules=org/crsx/hacs/MakeRun.crs term=MakeRun "grammar=('net.sf.crsx.text.Text';)" \
		   	$(shell $(X) cat '$*.env') PACKAGE="$$package" PACKAGEDIR="$$packagedir" BUILD='$(BUILD)' \
		   	HACS$$($(call CATRESOURCE,org/crsx/hacs/VERSION)) CRSXJAR='$(CRSXJAR)' HACSJAR='$(HACSJAR)' CRSXC='$(CRSXC)' \
		   	ICU4CINCLUDE='$(ICU4CINCLUDE)' ICU4CDIR='$(ICU4CDIR)' \
		   	LIBDIR='$(LIBDIR)' BINDIR='$(BINDIR)' DOCDIR='$(DOCDIR)' SHAREDIR='$(SHAREDIR)' SHAREJAVA='$(SHAREJAVA)' \
		   	SHELL='$(SHELL)' JAVA='$(JAVA)' JAVAC='$(JAVAC)' \
		   	output='$@.tmp' sink=net.sf.crsx.text.TextSink \
		     && $(X) mv '$@.tmp' '$@' ; \
		   fi \
		) $(LOG)
	@chmod +x '$@'

realclean::; @rm -f *.run

# Process HACS (.hx) source files.

# Parse HACS for Prep using the HxRaw parser.
%.hxraw : %.hx
	@$(ECHO) -e '\nHACS: Parsing .hx to term $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(X) $(RUNCRSX) \
			"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
			input='$<' category=rawHxModule \
			output='$@.tmp' simple-terms max-indent=10 width=255 \
		&& $(X) mv '$@.tmp' '$@' \
		) $(LOG)

# Process (pre-raw-parsed) HACS with Prep to create all files needed by Cook system.
%.prep : %.hxraw
	@$(ECHO) -e '\nHACS: Generating parser generator base $@...' $(OUT) && $(SH_EXTRA) \
	&&	( if [ -x "$(LIBDIR)/HacsRewriter" -a -z "$(INTERPRET)" ]; then \
		    $(X) LD_LIBRARY_PATH='$(ICU4CDIR)' $(LIBDIR)/HacsRewriter wrapper=Prep input='$<' output='$@.tmp' \
		    && $(X) mv '$@.tmp' '$@' ; \
		  else \
		    $(X) $(RUNCRSX) \
			"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
			rules=org/crsx/hacs/Prep.crs wrapper=Prep \
			input='$<' \
			output='$@.tmp' sink=net.sf.crsx.text.TextSink \
		    && $(X) mv '$@.tmp' '$@' ; \
		  fi \
		) $(LOG)

# Extract template from "PG and sort base".
%Hx.pgtemplate : %.prep
	@$(ECHO) -e '\nHACS: Generating meta-source parser generator template $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(call PREPEXTRACT,METAPG,$<) > '$@.tmp' \
		&& $(X) mv '$@.tmp' '$@' \
		) $(LOG)

# Assemble PG parser from template and Hx parser fragments.
%.pg: %.pgtemplate
	@$(ECHO) -e '\nHACS: Generating meta-source parser generator $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(X) mkdir -p $(BUILD)/org/crsx/hacs \
		&& $(call XRESOURCE,org/crsx/hacs/Hx.pgnames,$(BUILD)) \
		&& $(call XRESOURCE,org/crsx/hacs/Hx.pgdecs,$(BUILD)) \
		&& $(call XRESOURCE,org/crsx/hacs/Hx.pgpre,$(BUILD)) \
		&& $(call XRESOURCE,org/crsx/hacs/Hx.pgpost,$(BUILD)) \
		&& prefix=$$($(X) $(GNUSED) -n 's/prefix *"\(.*\)".*/\1/p' $<) \
		&& $(X) $(GNUSED) \
			-e '/%%%HXNONTERMINALS%%%/ bnames' \
			-e '/%%%HXDECLARATIONS%%%/ bdecs' \
			-e '/%%%HXPREPRODUCTIONS%%%/ bpre' \
			-e '/%%%HXPOSTPRODUCTIONS%%%/ bpost' \
			-e 'b' \
			-e ':names' -e 'r $(BUILD)/org/crsx/hacs/Hx.pgnames' -e 'd' \
			-e ':decs'  -e 'r $(BUILD)/org/crsx/hacs/Hx.pgdecs'  -e 'd' \
			-e ':pre'   -e 'r $(BUILD)/org/crsx/hacs/Hx.pgpre'   -e 'd' \
			-e ':post'  -e 'r $(BUILD)/org/crsx/hacs/Hx.pgpost'  -e 'd' \
			-e 's/ *$$//' $<  |  $(X) $(GNUSED) -e "s/%%%PREFIX%%%/$$prefix/g" > '$@.tmp' \
		&& $(X) mv '$@.tmp' '$@' \
		) $(LOG)

# Generate PG parser for embedded user meta- terms.
%Embed.pg : %.prep
	@$(ECHO) -e '\nHACS: Generating embedded meta-term parser $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(call PREPEXTRACT,EMBEDPG,$<) > '$@.tmp' \
		&& $(X) mv '$@.tmp' '$@' \
		) $(LOG)

# Generate PG parser for straight terms.
%Parser.pg : %.prep
	@$(ECHO) -e '\nHACS: Generating plain term parser generator $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(call PREPEXTRACT,USERPG,$<) > '$@.tmp' \
		&& $(X) mv '$@.tmp' '$@' \
		) $(LOG)

# Extract sort declarations for user's compiler from template.
%-sorts.crs : %.prep
	@$(ECHO) -e '\nHACS: Generating plain term sort declarations $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(call PREPEXTRACTONLY,SORTS,$<) > '$@.tmp' \
		&& $(X) mv '$@.tmp' '$@' \
		) $(LOG)

# Compile PG parser specification to JavaCC.
%.jj : %.pg
	@$(ECHO) -e '\nHACS: Generating JavaCC grammar $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(X) $(RUNPG) -source=$(BUILD) $< \
		) $(LOG)
.SECONDARY: %.jj

# Compile JavaCC parser to Java.
%.java: %.jj
	@$(ECHO) -e '\nHACS: Generating Java parser source $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(X) mkdir -p $(dir $<) && $(X) cd $(dir $<) && $(X) $(JAVACC) $(notdir $<) \
		) $(LOG)
.SECONDARY: %.java

# Compile Java to class file.
%.class: %.java
	@$(ECHO) -e '\nHACS: Compiling Java class $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(X) cd $(BUILD) && $(X) $(JAVAC) -cp ":$(HACSJAR):$(CRSXJAR)" $*.java \
		) $(LOG)

# Parse HACS for Cook using the Prep-generated parser.
%.hxprep : %.env
	@$(ECHO) -e '\nHACS: Parsing custom HACS to term $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(shell $(X) cat '$<') \
		&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
		&& $(X) $(RUNCRSX) \
			"grammar=('$$METAPARSERCLASS';'$$EMBEDPARSERCLASS';'net.sf.crsx.text.Text';'org.crsx.hacs.Prelude';)" \
			input='$*.hx' category="$${METAPREFIX}HxModule" \
			output='$@.tmp' simple-terms max-indent=10 width=255 \
		&& $(X) mv '$@.tmp' '$@' \
		) $(LOG)

# Process (pre-parsed) HACS with Cook to create rewrite rules!
%Rewriter.crs : %.hxprep
	@$(ECHO) -e '\nHACS: Generating rewriter $@...' $(OUT) && $(SH_EXTRA) \
	&&	( if [ -x "$(LIBDIR)/HacsRewriter" -a -z "$(INTERPRET)" ]; then \
		    $(X) LD_LIBRARY_PATH='$(ICU4CDIR)' $(LIBDIR)/HacsRewriter crsx-debug-steps wrapper=Cook input='$<' output='$@.tmp' \
		    && $(X) $(GNUSED) 's/222222222/9/g' '$@.tmp' >'$@' ; \
		  else \
		    $(X) $(RUNCRSX) \
			"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
			rules=org/crsx/hacs/Cook.crs wrapper=Cook \
			input='$<' \
			output='$@.tmp' sink=net.sf.crsx.text.TextSink \
		    && $(X) $(GNUSED) 's/222222222/9/g' '$@.tmp' >'$@' ; \
		  fi \
		) $(LOG)

ifndef FROMZIP

# GENERATING BINARY.

# Dispatchify.

%.dr.gz %_literals.dr.gz : %.crs
	$(RUNCRSX) rules='$<' sortify dispatchify reify=$*.dr simple-terms omit-linear-variables canonical-variables
	@gzip <$*.dr >$*.dr.gz
	@gzip <$*_literals.dr >$*_literals.dr.gz

# Generate C files.

%_literals.h : %_literals.dr.gz
	@gunzip <$< >$*_literals.dr
	$(CRSXC) wrapper=ComputeLiteralsHeader input=$*_literals.dr output=$@.tmp
	$(GNUSED) 's/222222222/9/g' '$@.tmp' >'$@'
	@rm -f '$*_literals.dr' '$@.tmp'

%.h : %.dr.gz %_literals.h
	@gunzip <$< >$*.dr
	$(CRSXC) wrapper=ComputeHeader HEADERS="crsx.h;$(notdir $*)_literals.h" input=$*.dr output=$@.tmp
	$(GNUSED) 's/222222222/9/g' '$@.tmp' >'$@'
	@rm -f '$*.dr' '$@.tmp'

%_literals.c : %_literals.dr.gz
	@gunzip <$< >$*_literals.dr
	$(CRSXC) rules=literals.crs wrapper=ComputeLiterals MODULE="$(notdir $*)" input=$*_literals.dr output=$@.tmp
	$(GNUSED) 's/222222222/9/g' '$@.tmp' >'$@'
	@rm -f '$*_literals.dr' '$@.tmp'

%_sorts.c : %.dr.gz
	@gunzip <$< >$*.dr
	$(CRSXC) wrapper=ComputeSorts HEADERS="$(notdir $*).h" input=$*.dr output=$@.tmp
	$(GNUSED) 's/222222222/9/g' '$@.tmp' >'$@'
	@rm -f '$*.dr' '$@.tmp'

%_rules.c : %.dr.gz
	@gunzip <$< >$*.dr
	$(CRSXC) wrapper=ComputeRules HEADERS="$(notdir $*).h" input=$*.dr output=$@.tmp
	$(GNUSED) 's/222222222/9/g' '$@.tmp' >'$@'
	@rm -f '$*.dr' '$@.tmp'

%.rawsymlist : %.dr.gz
	@gunzip <$< >$*.dr
	$(CRSXC) wrapper=ComputeSymbols input=$*.dr output=$@.tmp
	$(GNUSED) 's/ {/\n{/g' $@.tmp | sed -n '/^[{]/p' >$@
	@rm -f '$*.dr' '$@.tmp'

%_symbols.c : %.rawsymlist
	LC_ALL=C sort -bu $< | sed -n '/./p' > $@.tmp
	@(echo '/* $* symbols. */'; \
	  echo '#include "$(notdir $*).h"'; \
	  echo "size_t symbolDescriptorCount = $$(wc -l <$@.tmp);"; \
	  echo 'struct _SymbolDescriptor symbolDescriptorTable[] = {';\
	  cat $@.tmp;\
	  echo '{NULL, NULL}};') > $@

endif

# Load compiled files.

%.o : %.c
	sed -n 's/^#include "\(.*\)"/\1/p' $< | while read f; do echo $(MAKE) $(dir $<)$$f; done
	cd $(dir $<) && $(X) $(CC) -std=c99 -DOMIT_TIMESPEC -DGENERIC_LOADER -I$(SHAREDIR) -I$(BUILD)/share/hacs $(CFLAGS) -c $(notdir $<)

%Rewriter : %.o %_sorts.o %_rules.o %_symbols.o %_literals.o
	cd $(dir $<) && $(X) $(CC) -std=c99 $(CFLAGS) -o $(notdir $*)Rewriter $(notdir $*).o $(notdir $*)_sorts.o $(notdir $*)_rules.o $(notdir $*)_symbols.o $(notdir $*)_literals.o crsx.o crsx_scan.o linter.o prof.o -licuuc -licudata -licui18n -licuio

crsx.o crsx_scan.o :
	@if [ -f $(LIBDIR)/crsx.o ]; then cp $(LIBDIR)/crsx.o $(LIBDIR)/crsx_scan.o .; \
	elif [ -f $(BUILD)/lib/hacs/crsx.o ]; then cp $(BUILD)/lib/hacs/crsx.o $(BUILD)/lib/hacs/crsx_scan.o .; \
	else false; fi


# Debugging helpers.

%.crsp : %.crs
	@$(ECHO) -e '\nHACS: Generating parsed CRSX file $@...' $(OUT) && $(SH_EXTRA) \
	&& parsers=$$($(X) sed -n 's/^[$$]CheckGrammar\[\(.*\)\]/\1/p' $<) \
	&& $(X) $(RUNCRSX) $${parsers:+"grammar=($$parsers)"} rules='$*.crs' dump-rules='$@.tmp' \
	&& $(X) mv '$@.tmp' '$@'

%.pp : %
	@$(ECHO) -e '\nHACS: Pretty-printing CRSX term file $@...' $(OUT) && $(SH_EXTRA) \
	&& parsers=$$($(X) sed -n 's/^[$$]CheckGrammar\[\(.*\)\]/\1;/p' $<) \
	&& $(X) $(RUNCRSX) "grammar=($$parsers 'org.crsx.hacs.HxRaw'; 'net.sf.crsx.text.Text';)" input='$<' rules=org/crsx/hacs/Cook.crs omit-properties output='$@.tmp' \
	&& $(X) mv '$@.tmp' '$@'

%.crsd : %.crs
	$(RUNCRSX) rules='$<' sortify dispatchify dump-rules='$@' omit-linear-variables canonical-variables

%.crsE : %.crs
	$(RUNCRSX) rules='$<' sortify dump-rules='$@' omit-linear-variables canonical-variables
