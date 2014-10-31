# -*-GNUMakefile-*- helper definition for HACS executable.
#
# Context environment variables (should all contain absolute paths):
# - HACSJAR - the jar archive or directory containing HACS shared resources.
# - CRSXJAR - the jar archive containing the CRSX rewrite engine runtime.
# - JAVACCJAR - the jar archive containing the JavaCC parser generator runtime.
# - CRSXC - the compiled CRSX rulecompiler.

# - BUILD - the root directory for intermediate generated files.


# STANDARD TARGETS.

.PHONY: all clean realclean install
all::
clean::; @rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
install::

# Common commands.
include Env.mk

# SCRIPTS.

# Parser generator command.
RUNJAVACC = $(JAVA) -cp "$(JAVACCJAR)" javacc

# CRSX tool commands.
RUNPG = $(JAVA) -ea -cp "$(BUILD):$(HACSJAR):$(CRSXJAR)" net.sf.crsx.pg.PG verbose=1 $(EXTRA)
RUNCRSX = $(JAVA) -ea -cp "$(BUILD):$(HACSJAR):$(CRSXJAR)" -Dfile.encoding=UTF-8 -Xss20000K -Xmx2000m net.sf.crsx.run.Crsx allow-unnamed-rules allow-missing-cases sortify verbose=1 $(EXTRA)

# Magic...
NOEXEC = $(if $(findstring -n,$(MAKE)),$(ECHO))

# Log all commands.
SH_EXTRA = set -x

# Dissect .prep file.
# Usage: $(call PREPEXTRACT,METAPG,source.prep) > 'target.extension'
PREPEXTRACT = $(NOEXEC) $(GNUSED) \
	-e ':start' \
	-e '/[/][*][*][*]\([^*]\|[*][^*]\)*$$/{N; bstart;}' \
	-e 's./[*][*][*]\([A-Z]*[&]\)*$(1)\([&][A-Z]*\)*: *\(\([^*]\|[*][^*]\)*\)[*][*][*]/.\3.g' \
	-e 'tstart' \
	-e 's./[*][*][*]\([^*]\|[*][^*]\)*[*][*][*]/..g' \
	-e 'tstart' \
	-e 's/ *$$//gM' '$(2)'
#
PREPEXTRACTONLY = $(NOEXEC) $(GNUSED) \
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
XRESOURCE = $(if $(findstring .jar,$(HACSJAR)), $(NOEXEC) cd $(2) && $(NOEXEC) $(JAR) xf $(HACSJAR) $(1), $(NOEXEC) mkdir -p $(dir $(2)/$(1)) && $(NOEXEC) cp $(HACSJAR)/$(1) $(2)/$(1) )
#  - $(call CATRESOURCE,resourcepath) 
CATRESOURCE = $(if $(findstring .jar,$(HACSJAR)), $(NOEXEC) $(UNZIP) -p $(HACSJAR) $(1), $(NOEXEC) cat $(HACSJAR)/$(1) )


# RULES.

# %.env: the internal setup for generated compiler
%.env : %.hx
	@$(ECHO) -e 'HACS: Generating environment declarations $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(NOEXEC) $(RUNCRSX) \
			"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
			rules=org/crsx/hacs/Main.crs wrapper=P-PrintEnvironment \
			input='$<' category=rawHxModule \
			output='$@.tmp' sink=net.sf.crsx.text.TextSink \
		&& mv '$@.tmp' '$@' \
		) $(LOG) 

clean::; @rm -f  *.env

## %.prepared: marker that all parsers have been generated
#%.prepared : %.env
#	@$(ECHO) -e 'HACS: Generating $@...' $(OUT) && $(SH_EXTRA) \
#	&& ( eval $$($(NOEXEC) cat '$<') \
#		&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
#		&& $(NOEXEC) mkdir -p $(BUILD)/$$packagedir \
#		&& ( $(NOEXEC) rsync -v '$*.hx' $(BUILD)/$$packagedir/ || : ) \
#		&& $(MAKE) $(BUILD)/$$packagedir/$${NAME}Parser.class \
#		&& $(MAKE) $(BUILD)/$$packagedir/$${NAME}Hx.class \
#		&& $(MAKE) $(BUILD)/$$packagedir/$${NAME}Embed.class \
#		&& $(MAKE) $(BUILD)/$$packagedir/$${NAME}Rewriter.crs \
#		&& $(NOEXEC) touch '$@' ) $(LOG)

# %.run: script implementing user compiler...
%.run : %.env
	@$(ECHO) -e 'HACS: Generating $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(shell $(NOEXEC) cat '$*.env') \
		&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
		&& $(RUNCRSX) \
			rules=org/crsx/hacs/Main.crs term=MakeRun "grammar=('net.sf.crsx.text.Text';)" \
			$(shell $(NOEXEC) cat '$*.env') PACKAGE="$$package" PACKAGEDIR="$$packagedir" BUILD='$(BUILD)' \
			HACS$$($(call CATRESOURCE,org/crsx/hacs/VERSION)) CRSXJAR='$(CRSXJAR)' HACSJAR='$(HACSJAR)' CRSXC='$(CRSXC)' \
			LIBDIR='$(LIBDIR)' BINDIR='$(BINDIR)' DOCDIR='$(DOCDIR)' SHAREDIR='$(SHAREDIR)' SHAREJAVA='$(SHAREJAVA)' \
			SHELL='$(SHELL)' JAVA='$(JAVA)' JAVAC='$(JAVAC)' \
			output='$@.tmp' sink=net.sf.crsx.text.TextSink \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)
	@chmod +x '$@'

realclean::; @rm -f *.run

# Process HACS (.hx) source files.

# Parse HACS for Prep using the HxRaw parser.
%.hxraw : %.hx
	@$(ECHO) -e 'HACS: Parsing .hx to term $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(NOEXEC) $(RUNCRSX) \
			"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
			input='$<' category=rawHxModule \
			output='$@.tmp' simple-terms max-indent=10 width=255 \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)
.SECONDARY: %.hxraw

# Process (pre-raw-parsed) HACS with Prep to create all files needed by Cook system.
%.prep : %.hxraw
	@$(ECHO) -e 'HACS: Generating parser generator base $@...' $(OUT) && $(SH_EXTRA) \
	&&	($(NOEXEC) $(RUNCRSX) \
			"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
			rules=org/crsx/hacs/Main.crs wrapper=Prep \
			input='$<' \
			output='$@.tmp' sink=net.sf.crsx.text.TextSink \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)
.SECONDARY: %.prep

# Extract template from "PG and sort base".
%Hx.pgtemplate : %.prep
	@$(ECHO) -e 'HACS: Generating meta-source parser generator template $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(call PREPEXTRACT,METAPG,$<) > '$@.tmp' \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)
.SECONDARY: %Hx.pgtemplate

# Assemble PG parser from template and Hx parser fragments.
%.pg: %.pgtemplate
	@$(ECHO) -e 'HACS: Generating meta-source parser generator $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(NOEXEC) mkdir -p $(BUILD)/org/crsx/hacs \
		&& $(call XRESOURCE,org/crsx/hacs/Hx.pgnames,$(BUILD)) \
		&& $(call XRESOURCE,org/crsx/hacs/Hx.pgdecs,$(BUILD)) \
		&& $(call XRESOURCE,org/crsx/hacs/Hx.pgpre,$(BUILD)) \
		&& $(call XRESOURCE,org/crsx/hacs/Hx.pgpost,$(BUILD)) \
		&& prefix=$$($(NOEXEC) $(GNUSED) -n 's/prefix *"\(.*\)".*/\1/p' $<) \
		&& $(NOEXEC) $(GNUSED) \
			-e '/%%%HXNONTERMINALS%%%/ bnames' \
			-e '/%%%HXDECLARATIONS%%%/ bdecs' \
			-e '/%%%HXPREPRODUCTIONS%%%/ bpre' \
			-e '/%%%HXPOSTPRODUCTIONS%%%/ bpost' \
			-e 'b' \
			-e ':names' -e 'r $(BUILD)/org/crsx/hacs/Hx.pgnames' -e 'd' \
			-e ':decs'  -e 'r $(BUILD)/org/crsx/hacs/Hx.pgdecs'  -e 'd' \
			-e ':pre'   -e 'r $(BUILD)/org/crsx/hacs/Hx.pgpre'   -e 'd' \
			-e ':post'  -e 'r $(BUILD)/org/crsx/hacs/Hx.pgpost'  -e 'd' \
			-e 's/ *$$//' $<  |  $(NOEXEC) $(GNUSED) -e "s/%%%PREFIX%%%/$$prefix/g" > '$@.tmp' \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)
.SECONDARY: %.pg

# Generate PG parser for embedded user meta- terms.
%Embed.pg : %.prep
	@$(ECHO) -e 'HACS: Generating embedded meta-term parser $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(call PREPEXTRACT,EMBEDPG,$<) > '$@.tmp' \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)
.SECONDARY: %Embed.pg

# Generate PG parser for straight terms.
%Parser.pg : %.prep
	@$(ECHO) -e 'HACS: Generating plain term parser generator $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(call PREPEXTRACT,USERPG,$<) > '$@.tmp' \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)
.SECONDARY: %Parser.pg

# Extract sort declarations for user's compiler from template.
%-sorts.crs : %.prep
	@$(ECHO) -e 'HACS: Generating plain term sort declarations $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(call PREPEXTRACTONLY,SORTS,$<) > '$@.tmp' \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)

# Compile PG parser specification to JavaCC.
%.jj : %.pg
	@$(ECHO) -e 'HACS: Generating JavaCC grammar $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(NOEXEC) $(RUNPG) -source=$(BUILD) $< \
		) $(LOG)
.SECONDARY: %.jj

# Compile JavaCC parser to Java.
%.java: %.jj
	@$(ECHO) -e 'HACS: Generating Java parser source $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(NOEXEC) mkdir -p $(dir $<) && $(NOEXEC) cd $(dir $<) && $(NOEXEC) $(JAVACC) $(notdir $<) \
		) $(LOG)
.SECONDARY: %.java

# Compile Java to class file.
$(BUILD)/%.class: $(BUILD)/%.java
	@$(ECHO) -e 'HACS: Compiling Java class $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(NOEXEC) cd $(BUILD) && $(NOEXEC) $(JAVAC) -cp ":$(HACSJAR):$(CRSXJAR)" $*.java \
		) $(LOG)

# Parse HACS for Cook using the Prep-generated parser.
%.hxprep : %.env
	@$(ECHO) -e 'HACS: Parsing custom HACS to term $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(shell $(NOEXEC) cat '$<') \
		&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
		&& $(NOEXEC) $(RUNCRSX) \
			"grammar=('$$METAPARSERCLASS';'$$EMBEDPARSERCLASS';'net.sf.crsx.text.Text';)" \
			input='$*.hx' category="$${METAPREFIX}HxModule" \
			no-parse-verbose \
			output='$@.tmp' simple-terms max-indent=10 width=255 \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)
.SECONDARY: %.hxprep

# Process (pre-parsed) HACS with Cook to create rewrite rules!
%Rewriter.crs : %.hxprep
	@$(ECHO) -e 'HACS: Generating rewriter $@...' $(OUT) && $(SH_EXTRA) \
	&&	( $(NOEXEC) $(RUNCRSX) \
			"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
			rules=org/crsx/hacs/Main.crs wrapper=Cook trace-dm \
			input='$<' \
			output='$@.tmp' sink=net.sf.crsx.text.TextSink \
		&& $(NOEXEC) mv '$@.tmp' '$@' \
		) $(LOG)


# GENERATING BINARY.

# Dispatchify.
%.dr: %.crs
	$(RUNCRSX) rules='$<' sortify dispatchify reify=$@ simple-terms omit-linear-variables canonical-variables

# Generate C files.
%.h: %.dr
	$(CRSXC) wrapper=ComputeHeader HEADERS="crsx.h" input=$< output=$@

%_sorts.c: %.dr
	$(CRSXC) wrapper=ComputeSorts HEADERS="$*.h" input=$< output=$@

%_rules.c: %.dr
	$(CRSXC) wrapper=ComputeRules HEADERS="$*.h" input=$< output=$@

%.rawsymlist: %.dr
	$(CRSXC) wrapper=ComputeSymbols input=$< output=$@.tmp
	sed 's/ {/\n{/g' $@.tmp | sed -n '/^[{]/p' >$@

%_symbols.c: %.rawsymlist
	LC_ALL=C sort -bu $< | sed -n '/./p' > $@.tmp
	@(echo '/* $* symbols. */'; \
	  echo '#include "$*.h"'; \
	  echo "size_t symbolDescriptorCount = $$(wc -l <$@.tmp);"; \
	  echo 'struct _SymbolDescriptor symbolDescriptorTable[] = {';\
	  cat $@.tmp;\
	  echo '{NULL, NULL}};') > $@

# Load compiled files.
%.o: %.c
	cd $(dir $<) && $(NOEXEC) $(CC) -std=c99 -DOMIT_TIMESPEC -I$(SHAREDIR) -I$(BUILD)/share/hacs $(CFLAGS) -c $(notdir $<)

%Rewriter: %.o %_sorts.o %_rules.o %_symbols.o
	cd $(dir $<) && $(NOEXEC) $(CC) -std=c99 -o $(notdir $*)Rewriter $(notdir $*).o $(notdir $*)_sorts.o $(notdir $*)_rules.o $(notdir $*)_symbols.o crsx.o crsx_scan.o linter.o prof.o -licuuc -licudata -licui18n -licuio

crsx.o crsx_scan.o:
	@if [ -f $(LIBDIR)/crsx.o ]; then cp $(LIBDIR)/crsx.o $(LIBDIR)/crsx_scan.o .; \
	elif [ -f $(BUILD)/lib/hacs/crsx.o ]; then cp $(BUILD)/lib/hacs/crsx.o $(BUILD)/lib/hacs/crsx_scan.o .; \
	else false; fi


# Debugging helpers.

%.crsp: %.crs
	@$(ECHO) -e 'HACS: Generating parsed CRSX file $@...' $(OUT) && $(SH_EXTRA) \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[$$]CheckGrammar\[\(.*\)\]/\1/p' $<) \
	&& $(NOEXEC) $(RUNCRSX) $${parsers:+"grammar=($$parsers)"} rules='$*.crs' dump-rules='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%.pp: %
	@$(ECHO) -e 'HACS: Pretty-printing CRSX term file $@...' $(OUT) && $(SH_EXTRA) \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[$$]CheckGrammar\[\(.*\)\]/\1;/p' $<) \
	&& $(NOEXEC) $(RUNCRSX) "grammar=($$parsers 'org.crsx.hacs.HxRaw'; 'net.sf.crsx.text.Text';)" input='$<' rules=org/crsx/hacs/Cook.crs omit-properties output='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
