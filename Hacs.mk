# -*-Makefile-*- definitions for HACS distribution.
#
# Assumes the following environment variables set:
# CRSXROOT - the root of the CRSX project (TODO: eliminate).
# HACS - the (existing) root directory of main HACS source files.
# TEMP - the root directory for all generated source files.
# BUILD - the root directory for all generated binary and resource files.


# STANDARD TARGETS.

.PHONY: all clean realclean install
all::
clean::; rm -f *.tmp *~ ./#* *.log *~
realclean:: clean
install::


# SYSTEM COMMANDS.

# These are suitable defaults for many systems.
#
ifdef JAVA_HOME
JAVA = $(JAVA_HOME)/jre/bin/java
else
JAVA = java
endif
#
JAVAC = javac
JAR = jar
JAVACC = javacc
#
CC = gcc -std=c99 -g
FLEX = flex
#
WGET = wget
UNZIP = unzip -q
#
ECHO = /bin/echo
#
GNUSED = sed

EXTRACT = $(GNUSED) \
	-e ':start' \
	-e '/[/][*][*][*]\([^*]\|[*][^*]\)*$$/{N; bstart;}' \
	-e 's./[*][*][*]\([A-Z]*[&]\)*$(1)\([&][A-Z]*\)*: *\(\([^*]\|[*][^*]\)*\)[*][*][*]/.\3.g' \
	-e 'tstart' \
	-e 's./[*][*][*]\([^*]\|[*][^*]\)*[*][*][*]/..g' \
	-e 'tstart' \
	-e 's/ *$$//gM' '$(2)'

EXTRACTONLY = $(GNUSED) \
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


# CRSX ENVIRONMENT.

# HACK: FOR NOW YOU MUST SET CRSXROOT !!!

# Note: currently direct link to crsx repo...
#
# The jar (TODO: from package libcrsx-java).
CRSXJAR = $(CRSXROOT)/crsx.jar
$(CRSXJAR):; cd $(CRSXROOT) && make
#
# The rulecompiler (TODO: from package crsx).
RULEC = $(CRSXROOT)/bin/crsxc
$(RULEC):; cd $(CRSXROOT) && make bin/crsx
#
PG = $(JAVA) -ea -cp "$(CRSXJAR)" net.sf.crsx.pg.PG $(EXTRA)
CRSX = $(JAVA) -ea -cp "$(BUILD):$(CRSXJAR)" -Dfile.encoding=UTF-8 -Xss20000K -Xmx2000m net.sf.crsx.run.Crsx allow-unnamed-rules verbose=1 $(EXTRA)
CRSX_NOEXTRA = $(JAVA) -ea -cp "$(BUILD):$(CRSXJAR)" -Dfile.encoding=UTF-8 -Xss20000K -Xmx2000m net.sf.crsx.run.Crsx allow-unnamed-rules verbose=1

# So -n works...
NOEXEC = $(if,$(findstring -n,$(MAKE)),echo)
SH_EXTRA = :


# RULES.

# Main rules: Progress to generate
# %.env: the setup for compiler
# %.prepared: marker that all parsers have been generated
# %.run: script implementing user comiler

%.env : %.hx
	@$(ECHO) -e '\n>>> GENERATING ENVIRONMENT DECLARATIONS $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) ( cd $(HACS) && find . -name '*.crs' | while read fn; do dir=$(BUILD)/$$(dirname $$fn) && mkdir -p $$dir && cp -f $$fn $(BUILD)/$$dir; done ) \
	&& $(CRSX_NOEXTRA) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=$(HACS)/org/crsx/hacs/Prep.crs wrapper=P-PrintEnvironment \
		input='$<' category=rawHxModule \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%.prepared : %.env
	@$(ECHO) -e '\n>>> GENERATING $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) ( cd $(HACS) && find . -name '*.crs' | while read fn; do dir=$(BUILD)/$$(dirname $$fn) && mkdir -p $$dir && cp -f $$fn $(BUILD)/$$dir; done ) \
	&& eval $$($(NOEXEC) cat '$<') \
	&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(NOEXEC) mkdir -p $(TEMP)/$$packagedir \
	&& ( $(NOEXEC) rsync -v '$*.hx' $(TEMP)/$$packagedir/ || : ) \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}.prep \
	&& $(NOEXEC) $(MAKE) $(BUILD)/$$packagedir/$${NAME}Parser.class \
	&& $(NOEXEC) $(MAKE) $(BUILD)/$$packagedir/$${NAME}Hx.class \
	&& $(NOEXEC) $(MAKE) $(BUILD)/$$packagedir/$${NAME}Embed.class \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}-sorts.crs \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}.crs \
	&& $(NOEXEC) touch '$@'

%.run : %.env
	@$(ECHO) -e '\n>>> GENERATING $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) ( cd $(HACS) && find . -name '*.crs' | while read fn; do dir=$(BUILD)/$$(dirname $$fn) && mkdir -p $$dir && cp -f $$fn $(BUILD)/$$dir; done ) \
	&& eval $$($(NOEXEC) cat '$*.env') \
	&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(CRSX_NOEXTRA) \
		rules=$(HACS)/org/crsx/hacs/MakeRun.crs term=Run "grammar=('net.sf.crsx.text.Text';)" \
		MODULE="$$MODULE" PACKAGE="$$package" NAME="$$NAME" SORT="$$SORT" SORTS="$$SORTS" REWRITER="$$packagedir/$${NAME}Rewriter.crs" \
		SINKCLASS="$$SINKCLASS" PARSERCLASS="$$PARSERCLASS" METAPARSERCLASS="$$METAPARSERCLASS" EMBEDPARSERCLASS="$$EMBEDPARSERCLASS" \
		PREFIX="$$PREFIX" METAPREFIX="$$METAPREFIX" EMBEDPREFIX="$$EMBEDPREFIX" \
		HACSVERSION="$$(cat $(HACS)/../VERSION)" \
		SHELL='$(SHELL)' JAVA='$(JAVA)' JAVAC='$(JAVAC)' CRSXJAR='$(abspath $(CRSXJAR))' HACSBUILD='$(abspath $(BUILD))' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'
	chmod +x '$@'

##MAKERUN = $(JAVA) -ea -cp "$(BUILD):$(CRSXJAR)" net.sf.crsx.run.Crsx allow-unnamed-rules $(EXTRA)

# Environment definitions for module...
#
#%.env : %.hx
#	@$(ECHO) -e '\n>>> GENERATING $@.' && $(SH_EXTRA) \
#	&& HACSVERSION=
#	&& MODULE=$$( $(CRSX_NOEXTRA) \
#		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
#		rules=$(HACS)/org/crsx/hacs/Prep.crs wrapper=P-PrintModuleName \
#		input='$<' category=rawHxModule sink=net.sf.crsx.text.TextSink ) \
#	&& SORT=$$( $(CRSX_NOEXTRA) \
#		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
#		rules=$(HACS)/org/crsx/hacs/Prep.crs wrapper=P-PrintTopSort \
#		input='$<' category=rawHxModule sink=net.sf.crsx.text.TextSink ) \
#	&& SORT=$$( $(CRSX_NOEXTRA) \
#		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
#		rules=$(HACS)/org/crsx/hacs/Prep.crs wrapper=P-PrintTopSort \
#		input='$<' category=rawHxModule sink=net.sf.crsx.text.TextSink ) \
#	&& PACKAGE=$${module%.*} \
#	&& NAME=$${module##*.} \

clean::; find . -name '*.env' | xargs rm -f
realclean::; find . -name '*.run' | xargs rm -f

# Process HACS (.hx) source files.

# Parse HACS for Prep using the HxRaw parser.
%.hxraw : %.hx
	@$(ECHO) -e '\n>>> PARSING HACS TO TERM $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		input='$<' category=rawHxModule \
		output='$@.tmp' simple-terms max-indent=10 width=255 \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.hxraw

# Process (pre-raw-parsed) HACS with Prep to create all files needed by Cook system.
%.prep : %.hxraw
	@$(ECHO) -e '\n>>> GENERATING PARSER GENERATOR BASE $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=$(HACS)/org/crsx/hacs/Prep.crs wrapper=Prep \
		input='$<' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.prep

# Extract template from "PG and sort base".
%Hx.pgtemplate : %.prep
	@$(ECHO) -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR TEMPLATE $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(call EXTRACT,METAPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.pgtemplate

# Assemble PG parser from template and Hx parser fragments.
%.pg: %.pgtemplate
	@$(ECHO) -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR $@.' && $(SH_EXTRA) \
	&& prefix=$$($(NOEXEC) $(GNUSED) -n 's/prefix *"\(.*\)".*/\1/p' $<) \
	&& $(NOEXEC) $(GNUSED) \
	 -e '/%%%HXNONTERMINALS%%%/    bnames' \
	 -e '/%%%HXDECLARATIONS%%%/    bdecs' \
	 -e '/%%%HXPREPRODUCTIONS%%%/  bpre' \
	 -e '/%%%HXPOSTPRODUCTIONS%%%/ bpost' \
	 -e 'b' \
	 -e ':names' -e 'r $(HACS)/org/crsx/hacs/Hx.pgnames' -e 'd' \
	 -e ':decs'  -e 'r $(HACS)/org/crsx/hacs/Hx.pgdecs'  -e 'd' \
	 -e ':pre'   -e 'r $(HACS)/org/crsx/hacs/Hx.pgpre'   -e 'd' \
	 -e ':post'  -e 'r $(HACS)/org/crsx/hacs/Hx.pgpost'  -e 'd' \
	 -e 's/ *$$//' $< \
	| $(GNUSED) -e "s/%%%PREFIX%%%/$$prefix/g" > '$@.tmp'
	@mv '$@.tmp' '$@'
.SECONDARY: %Hx.pg

# Generate PG parser for embedded user meta- terms.
%Embed.pg : %.prep
	$(ECHO) -e '\n>>> GENERATING EMBEDDED META-TERM PARSER $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(call EXTRACT,EMBEDPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %Embed.pg

# Generate PG parser for straight terms.
%Parser.pg : %.prep
	@$(ECHO) -e '\n>>> GENERATING PLAIN TERM PARSER GENERATOR $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(call EXTRACT,USERPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %Parser.pg

# Extract sort declarations for user's compiler from template.
%-sorts.crs : %.prep
	@$(ECHO) -e '\n>>> GENERATING PLAIN TERM SORT DECLARATIONS $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(call EXTRACTONLY,SORTS,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

# Compile PG parser specification to JavaCC.
%.jj : %.pg
	@$(ECHO) -e '\n>>> GENERATING JavaCC GRAMMAR $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(PG) -source=$(TEMP) $<
.SECONDARY: %.jj

# Compile JavaCC parser to Java.
%.java: %.jj
	@$(ECHO) -e '\n>>> GENERATING JAVA PARSER SOURCE $@.' && $(SH_EXTRA) \
	&& cd $(dir $<) && $(NOEXEC) $(JAVACC) $(notdir $<)
.SECONDARY: %.java

# Compile Java to class file.
$(BUILD)/%.class: $(TEMP)/%.java
	@$(ECHO) -e '\n>>> COMPILING JAVA CLASS $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) mkdir -p $(BUILD) \
	&& $(NOEXEC) cd $(TEMP) && $(NOEXEC) $(JAVAC) -cp ":$(CRSXJAR)" -d $(BUILD) $*.java

# Parse HACS for Cook using the Prep-generated parser.
%.hxprep : %.env
	@$(ECHO) -e '\n>>> PARSING CUSTOM HACS TO TERM $@.' && $(SH_EXTRA) \
	&& eval $$($(NOEXEC) cat '$<') \
	&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('$$METAPARSERCLASS';'$$EMBEDPARSERCLASS';'net.sf.crsx.text.Text';)" \
		input='$*.hx' category="$${METAPREFIX}HxModule" \
		no-parse-verbose \
		output='$@.tmp' simple-terms max-indent=10 width=255 \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.hxprep

# Process (pre-parsed) HACS with Cook to create rewrite rules!
%.crs : %.hxprep
	@$(ECHO) -e '\n>>> GENERATING REWRITER $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=$(HACS)/org/crsx/hacs/Cook.crs wrapper=Cook \
		input='$<' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'


# Debugging helpers.

%.crsp: %.crs
	@$(ECHO) -e '\n>>> GENERATING PARSED CRSX FILE $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[$$]CheckGrammar\[\(.*\)\]/\1/p' $<) \
	&& $(NOEXEC) $(CRSX) $${parsers:+"grammar=($$parsers)"} rules='$*.crs' dump-rules='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%.pp: %
	@$(ECHO) -e '\n>>> PRETTY-PRINTING CRSX TERM FILE $@.' && $(SH_EXTRA) \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[$$]CheckGrammar\[\(.*\)\]/\1;/p' $<) \
	&& $(NOEXEC) $(CRSX) "grammar=($$parsers 'org.crsx.hacs.HxRaw'; 'net.sf.crsx.text.Text';)" input='$<' rules=$(HACS)/org/crsx/hacs/Cook.crs omit-properties output='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
