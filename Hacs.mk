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
UNIQ = uniq
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
	-e 's/ *$$//gM' '$(2)' | $(UNIQ)

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
	-e 's/ *$$//gM' '$(2)' | $(UNIQ)


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
CRSX = $(JAVA) -ea -cp "$(BUILD):$(CRSXJAR)" net.sf.crsx.run.Crsx allow-unnamed-rules $(EXTRA)
CRSX_NOEXTRA = $(JAVA) -ea -cp "$(BUILD):$(CRSXJAR)" net.sf.crsx.run.Crsx allow-unnamed-rules

# So -n works...
NOEXEC = $(if,$(findstring -n,$(MAKE)),echo)
SH_EXTRA = :


# RULES.

# Main rules: Progress to generate
# %.env: the setup for compiler
# %.cooked: marker that all parsers have been generated
# %.run: script implementing user comiler

%.env : %.hx
	@$(ECHO) -e '\n>>> GENERATING ENVIRONMENT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) ( cd $(HACS) && find . -name '*.crs' | while read fn; do dir=$(BUILD)/$$(dirname $$fn) && mkdir -p $$dir && cp -f $$fn $(BUILD)/$$dir; done ) \
	&& $(CRSX_NOEXTRA) \
		"grammar=('org.crsx.hacs.HxRaw';'org.crsx.hacs.HxPP';'net.sf.crsx.text.Text';)" \
		rules=$(HACS)/org/crsx/hacs/CookPG.crs wrapper=PG-PrintEnvironment \
		input='$<' category=rawHxModule \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%.cooked : %.env
	@$(ECHO) -e '\n>>> GENERATING $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) ( cd $(HACS) && find . -name '*.crs' | while read fn; do dir=$(BUILD)/$$(dirname $$fn) && mkdir -p $$dir && cp -f $$fn $(BUILD)/$$dir; done ) \
	&& eval $$($(NOEXEC) cat '$<') \
	&& dir=$(dir $@) && package=$${MODULE%.*} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(NOEXEC) mkdir -p $(TEMP)/$$packagedir \
	&& ( $(NOEXEC) cp -f '$*.hx' $(TEMP)/$$packagedir/ || : ) \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}.pgbase \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Parser.pg \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Hx.pgtemplate \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Hx.pg \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Embed.pg \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}-sorts.crs \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Hx-sorts.crs \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Parser.jj \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Hx.jj \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Embed.jj \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Parser.java \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Hx.java \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${NAME}Embed.java \
	&& $(NOEXEC) $(MAKE) $(BUILD)/$$packagedir/$${NAME}Parser.class \
	&& $(NOEXEC) $(MAKE) $(BUILD)/$$packagedir/$${NAME}Hx.class \
	&& $(NOEXEC) $(MAKE) $(BUILD)/$$packagedir/$${NAME}Embed.class \
	&& $(NOEXEC) touch '$@'

%.run : %.env
	@$(ECHO) -e '\n>>> GENERATING $@.\n' && $(SH_EXTRA) && set -x \
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
#	@$(ECHO) -e '\n>>> GENERATING $@.\n' && $(SH_EXTRA) && set -x \
#	&& HACSVERSION=
#	&& MODULE=$$( $(CRSX_NOEXTRA) \
#		"grammar=('org.crsx.hacs.HxRaw';'org.crsx.hacs.HxPP';'net.sf.crsx.text.Text';)" \
#		rules=$(HACS)/org/crsx/hacs/CookPG.crs wrapper=PG-PrintModuleName \
#		input='$<' category=rawHxModule sink=net.sf.crsx.text.TextSink ) \
#	&& SORT=$$( $(CRSX_NOEXTRA) \
#		"grammar=('org.crsx.hacs.HxRaw';'org.crsx.hacs.HxPP';'net.sf.crsx.text.Text';)" \
#		rules=$(HACS)/org/crsx/hacs/CookPG.crs wrapper=PG-PrintTopSort \
#		input='$<' category=rawHxModule sink=net.sf.crsx.text.TextSink ) \
#	&& SORT=$$( $(CRSX_NOEXTRA) \
#		"grammar=('org.crsx.hacs.HxRaw';'org.crsx.hacs.HxPP';'net.sf.crsx.text.Text';)" \
#		rules=$(HACS)/org/crsx/hacs/CookPG.crs wrapper=PG-PrintTopSort \
#		input='$<' category=rawHxModule sink=net.sf.crsx.text.TextSink ) \
#	&& PACKAGE=$${module%.*} \
#	&& NAME=$${module##*.} \

clean::; find . -name '*.env' | xargs rm -f
realclean::; find . -name '*.run' | xargs rm -f

# Process HACS (.hx) source files.

# Parse HACS for CookPG using the HxRaw parser.
%.hxraw : %.hx
	@$(ECHO) -e '\n>>> PARSING HACS TO TERM $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) mkdir -p $(TEMP) \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'org.crsx.hacs.HxPP';'net.sf.crsx.text.Text';)" \
		input='$<' category=rawHxModule \
		output='$@.tmp' simple-terms max-indent=10 width=255 \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.hxraw

# Process (pre-raw-parsed) HACS with CookPG to get initial "PG and sort base".
%.pgbase : %.hxraw
	@$(ECHO) -e '\n>>> GENERATING PARSER GENERATOR BASE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'org.crsx.hacs.HxPP';'net.sf.crsx.text.Text';)" \
		rules=$(HACS)/org/crsx/hacs/CookPG.crs wrapper=PG \
		input='$<' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.pgbase

# Extract template from "PG and sort base".
%Hx.pgtemplate : %.pgbase
	@$(ECHO) -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR TEMPLATE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(call EXTRACT,METAPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.pgtemplate

# Assemble PG parser from template and Hx parser fragments.
%.pg: %.pgtemplate
	@$(ECHO) -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR $@.\n' && $(SH_EXTRA) && set -x \
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
	 -e 's/ *$$//' $< | $(UNIQ) \
	| $(GNUSED) -e "s/%%%PREFIX%%%/$$prefix/g" > '$@.tmp'
	@set -x && mv '$@.tmp' '$@'
.SECONDARY: %Hx.pg

# Generate PG parser for embedded user meta- terms.
%Embed.pg : %.pgbase
	$(ECHO) -e '\n>>> GENERATING EMBEDDED META-TERM PARSER $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(call EXTRACT,EMBEDPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %Embed.pg

# Extract sorts from template for use by GenerateCRS.
%Hx-sorts.crs : %.pgbase
	@$(ECHO) -e '\n>>> GENERATING META-SOURCE SORT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(call EXTRACTONLY,METASORTS,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

# Generate PG parser for straight terms.
%Parser.pg : %.pgbase
	@$(ECHO) -e '\n>>> GENERATING PLAIN TERM PARSER GENERATOR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(call EXTRACT,USERPG,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %Parser.pg

# Extract sort declarations for user's compiler from template.
%-sorts.crs : %.pgbase
	@$(ECHO) -e '\n>>> GENERATING PLAIN TERM SORT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(call EXTRACTONLY,SORTS,$<) > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

# Compile PG parser specification to JavaCC.
%.jj : %.pg
	@$(ECHO) -e '\n>>> GENERATING JavaCC GRAMMAR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(PG) -source=$(TEMP) $<
.SECONDARY: %.jj

# Compile JavaCC parser to Java.
%.java: %.jj
	@$(ECHO) -e '\n>>> GENERATING JAVA PARSER SOURCE $@.\n' && $(SH_EXTRA) && set -x \
	&& cd $(dir $<) && $(NOEXEC) $(JAVACC) $(notdir $<)
.SECONDARY: %.java

# Compile Java to class file.
$(BUILD)/%.class: $(TEMP)/%.java
	@$(ECHO) -e '\n>>> COMPILING JAVA CLASS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) mkdir -p $(BUILD) \
	&& $(NOEXEC) cd $(TEMP) && $(NOEXEC) $(JAVAC) -cp ":$(CRSXJAR)" -d $(BUILD) $*.java



# Debugging helpers.

%.crsp: %.crs
	@$(ECHO) -e '\n>>> GENERATING PARSED CRSX FILE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[^/]*CheckGrammar\[\(.*\)\]/\1/p' $<) \
	&& $(NOEXEC) $(CRSX) grammar="($$parsers)" rules='$*.crs' dump-rules='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
