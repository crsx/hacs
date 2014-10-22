# -*-GNUMakefile-*- helper definition for HACS executable.
#
# Context environment variables (should all contain absolute paths):
# - HACSJAR - the jar archive or directory containing HACS shared resources.
# - HACSSHARE - directory with HACS internal helper files.
# - HACSLIB - directory with HACS internal architecture-dependent binaries.
# - HACSBIN - directory with HACS user accessible commands.
# - BUILD - the root directory for intermediate generated files.
# - CRSXJAR - the jar archive containing the CRSX rewrite engine runtime.
#
# Java ecosystem:
# - JAVA - Java execution command.
# - JAVAC - Java compiler command.
# - JAVACC - JavaCC parser generator command.
# - JAR - Java Archiver command.
# - ANT - Java build command.
#
# C ecosystem:
# - CC - C99 compiler command.
# - CXX - C++ compiler command.
# - FLEX - lexical generator command.
#
# Unix ecosystem:
# - SHELL - shell compatible with GNU's Bourne Again Shell command.
# - ECHO - extended echo command (that accepts -e option).
# - GNUSED - the GNU stream editor command.
#
# Net ecosystem:
# - UNZIP - decompression and unpacking command.


# STANDARD TARGETS.

.PHONY: all clean realclean install
all::
clean::; rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
install::


# SCRIPTS.

# CRSX tool commands.
RUNPG = $(JAVA) -ea -cp "$(BUILD):$(HACSJAR):$(CRSXJAR)" net.sf.crsx.pg.PG $(EXTRA)
RUNCRSX = $(JAVA) -ea -cp "$(BUILD):$(HACSJAR):$(CRSXJAR)" -Dfile.encoding=UTF-8 -Xss20000K -Xmx2000m net.sf.crsx.run.Crsx allow-unnamed-rules allow-missing-cases verbose=1 sortify $(EXTRA)

# So -n works...
NOEXEC = $(if $(findstring -n,$(MAKE)),$(ECHO))
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
XRESOURCE = $(if $(findstring .jar,$(HACSJAR)), $(NOEXEC) $(JAR) xf $(HACSJAR) -C $(2) $(1), $(NOEXEC) mkdir -p $(dir $(2)/$(1)) && $(NOEXEC) cp $(HACSJAR)/$(1) $(2)/$(1) )
#  - $(call CATRESOURCE,resourcepath) 
CATRESOURCE = $(if $(findstring .jar,$(HACSJAR)), $(NOEXEC) $(UNZIP) -p $(HACSJAR) $(1), $(NOEXEC) cat $(HACSJAR)/$(1) )


# RULES.

# Main rules: Progress to generate
# %.env: the setup for compiler
# %.prepared: marker that all parsers have been generated
# %.run: script implementing user comiler

%.env : %.hx
	@$(ECHO) -e '\n>>> GENERATING ENVIRONMENT DECLARATIONS $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(RUNCRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=org/crsx/hacs/Prep.crs wrapper=P-PrintEnvironment \
		input='$<' category=rawHxModule \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%.prepared : %.env
	@$(ECHO) -e '\n>>> GENERATING $@.' && $(SH_EXTRA) \
	&& eval $$($(NOEXEC) cat '$<') \
	&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(NOEXEC) mkdir -p $(BUILD)/$$packagedir \
	&& ( $(NOEXEC) rsync -v '$*.hx' $(BUILD)/$$packagedir/ || : ) \
	&& $(MAKE) $(BUILD)/$$packagedir/$${NAME}Parser.class \
	&& $(MAKE) $(BUILD)/$$packagedir/$${NAME}Hx.class \
	&& $(MAKE) $(BUILD)/$$packagedir/$${NAME}Embed.class \
	&& $(MAKE) $(BUILD)/$$packagedir/$${NAME}Rewriter.crs \
	&& $(NOEXEC) touch '$@'

%.run : %.env
	@$(ECHO) -e '\n>>> GENERATING $@.' && $(SH_EXTRA) \
	&& eval $$($(NOEXEC) cat '$*.env') \
	&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(RUNCRSX) \
		rules=org/crsx/hacs/MakeRun.crs term=Run "grammar=('net.sf.crsx.text.Text';)" \
		MODULE="$$MODULE" PACKAGE="$$package" NAME="$$NAME" SORT="$$SORT" SORTS="$$SORTS" REWRITER="$$packagedir/$${NAME}Rewriter.crs" \
		SINKCLASS="$$SINKCLASS" PARSERCLASS="$$PARSERCLASS" METAPARSERCLASS="$$METAPARSERCLASS" EMBEDPARSERCLASS="$$EMBEDPARSERCLASS" \
		PREFIX="$$PREFIX" METAPREFIX="$$METAPREFIX" EMBEDPREFIX="$$EMBEDPREFIX" \
		HACS$(call CATRESOURCE,VERSION) \
		SHELL='$(SHELL)' JAVA='$(JAVA)' JAVAC='$(JAVAC)' CRSXJAR='$(CRSXJAR)' HACSJAR='$(HACSJAR)' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'
	chmod +x '$@'

clean::; find . -name '*.env' | xargs rm -f
realclean::; find . -name '*.run' | xargs rm -f

# Process HACS (.hx) source files.

# Parse HACS for Prep using the HxRaw parser.
%.hxraw : %.hx
	@$(ECHO) -e '\n>>> PARSING HACS TO TERM $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(RUNCRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		input='$<' category=rawHxModule \
		output='$@.tmp' simple-terms max-indent=10 width=255 \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.hxraw

# Process (pre-raw-parsed) HACS with Prep to create all files needed by Cook system.
%.prep : %.hxraw
	@$(ECHO) -e '\n>>> GENERATING PARSER GENERATOR BASE $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(RUNCRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=org/crsx/hacs/Prep.crs wrapper=Prep \
		input='$<' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.prep

# Extract template from "PG and sort base".
%Hx.pgtemplate : %.prep
	@$(ECHO) -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR TEMPLATE $@.' && $(SH_EXTRA) \
	&& $(call PREPEXTRACT,METAPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %Hx.pgtemplate

# Assemble PG parser from template and Hx parser fragments.
%.pg: %.pgtemplate
	@$(ECHO) -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR $@.' && $(SH_EXTRA) \
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
	 -e 's/ *$$//' $< \
	| $(NOEXEC) $(GNUSED) -e "s/%%%PREFIX%%%/$$prefix/g" > '$@.tmp'
	@mv '$@.tmp' '$@'
.SECONDARY: %.pg

# Generate PG parser for embedded user meta- terms.
%Embed.pg : %.prep
	$(ECHO) -e '\n>>> GENERATING EMBEDDED META-TERM PARSER $@.' && $(SH_EXTRA) \
	&& $(call PREPEXTRACT,EMBEDPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %Embed.pg

# Generate PG parser for straight terms.
%Parser.pg : %.prep
	@$(ECHO) -e '\n>>> GENERATING PLAIN TERM PARSER GENERATOR $@.' && $(SH_EXTRA) \
	&& $(call PREPEXTRACT,USERPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %Parser.pg

# Extract sort declarations for user's compiler from template.
%-sorts.crs : %.prep
	@$(ECHO) -e '\n>>> GENERATING PLAIN TERM SORT DECLARATIONS $@.' && $(SH_EXTRA) \
	&& $(call PREPEXTRACTONLY,SORTS,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

# Compile PG parser specification to JavaCC.
%.jj : %.pg
	@$(ECHO) -e '\n>>> GENERATING JavaCC GRAMMAR $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(RUNPG) -source=$(BUILD) $<
.SECONDARY: %.jj

# Compile JavaCC parser to Java.
%.java: %.jj
	@$(ECHO) -e '\n>>> GENERATING JAVA PARSER SOURCE $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) mkdir -p $(dir $<) && $(NOEXEC) cd $(dir $<) && $(NOEXEC) $(JAVACC) $(notdir $<)
.SECONDARY: %.java

# Compile Java to class file.
$(BUILD)/%.class: $(BUILD)/%.java
	$(ECHO) -e '\n>>> COMPILING JAVA CLASS $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) cd $(BUILD) && $(NOEXEC) $(JAVAC) -cp ":$(HACSJAR):$(CRSXJAR)" $*.java

# Parse HACS for Cook using the Prep-generated parser.
%.hxprep : %.env
	@$(ECHO) -e '\n>>> PARSING CUSTOM HACS TO TERM $@.' && $(SH_EXTRA) \
	&& eval $$($(NOEXEC) cat '$<') \
	&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(NOEXEC) $(RUNCRSX) \
		"grammar=('$$METAPARSERCLASS';'$$EMBEDPARSERCLASS';'net.sf.crsx.text.Text';)" \
		input='$*.hx' category="$${METAPREFIX}HxModule" \
		no-parse-verbose \
		output='$@.tmp' simple-terms max-indent=10 width=255 \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.hxprep

# Process (pre-parsed) HACS with Cook to create rewrite rules!
%Rewriter.crs : %.hxprep
	@$(ECHO) -e '\n>>> GENERATING REWRITER $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(RUNCRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=org/crsx/hacs/Cook.crs wrapper=Cook \
		input='$<' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'


# Debugging helpers.

%.crsp: %.crs
	@$(ECHO) -e '\n>>> GENERATING PARSED CRSX FILE $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[$$]CheckGrammar\[\(.*\)\]/\1/p' $<) \
	&& $(NOEXEC) $(RUNCRSX) $${parsers:+"grammar=($$parsers)"} rules='$*.crs' dump-rules='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%.pp: %
	@$(ECHO) -e '\n>>> PRETTY-PRINTING CRSX TERM FILE $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[$$]CheckGrammar\[\(.*\)\]/\1;/p' $<) \
	&& $(NOEXEC) $(RUNCRSX) "grammar=($$parsers 'org.crsx.hacs.HxRaw'; 'net.sf.crsx.text.Text';)" input='$<' rules=org/crsx/hacs/Cook.crs omit-properties output='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
