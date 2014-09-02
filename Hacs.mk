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
JAVACC = $(JAVA) -cp "$(abspath $(BUILD)/..)/lib/javacc.jar:" javacc
#
CC = gcc -std=c99 -g
FLEX = flex
#
WGET = wget
UNZIP = unzip -q


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

# Main rule: Generate "build stamp" by generating everything

%.build-stamp : %.hx
	@/bin/echo -e '\n>>> GENERATING $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) ( cd $(HACS) && find . -name '*.crs' | while read fn; do dir=$(BUILD)/$$(dirname $$fn) && mkdir -p $$dir && cp $$fn $(BUILD)/$$dir; done ) \
	&& module=$$( $(CRSX_NOEXTRA) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=$(HACS)/org/crsx/hacs/CookPG.crs wrapper=PG-GetModuleName \
		input='$<' category=rawHxModule sink=net.sf.crsx.text.TextSink ) \
	&& dir=$(dir $@) && package=$${module%.*} && name=$${module##*.} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(NOEXEC) mkdir -p $(TEMP)/$$packagedir \
	&& $(NOEXEC) cp $< $(TEMP)/$$packagedir/ \
	&& $(NOEXEC) $(MAKE) $(TEMP)/$$packagedir/$${name}.pgbase $(BUILD)/$$packagedir/$${name}Parser.class \
	&& touch $@

clean::; find . -name '*.build-stamp' | xargs rm -f

# Process HACS (.hx) source files.

# Workflow:
#   %.hx
#   ↳ %.hxp
#     ↳ %.pgbase (by CookPG system)
#
#       ↳ %Meta.pgtemplate
#         ↳ %Meta.pg → %Meta.jj → %Meta.java



#       ↳ %Meta-sorts.crs
#
#       ↳ %.crs ↲

#       ↳ %Parser.pg → %Parser.jj → %Parser.java
#       ↳ %-sorts.crs

# Parse HACS for CookPG using the HxRaw parser.
%.hxp : %.hx
	@/bin/echo -e '\n>>> PARSING HACS TO TERM $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) mkdir -p $(TEMP) \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		input='$<' category=rawHxModule \
		output='$@.tmp' simple-terms max-indent=10 width=255 \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.hxp

# Process (pre-raw-parsed) HACS with CookPG to get initial "PG and sort base".
%.pgbase : %.hxp
	@/bin/echo -e '\n>>> GENERATING PARSER GENERATOR BASE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=$(HACS)/org/crsx/hacs/CookPG.crs wrapper=PG \
		input='$<' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.pgbase

# Extract template from "PG and sort base".
%Meta.pgtemplate : %.pgbase
	@/bin/echo -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR TEMPLATE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -e 's;\(^class [^ ]*\) ;\1Meta ;' -e 's;/[*][*][*]METAPG: *\(\([^*]\|[*][^*]\)*\)[*][*][*]/;\1;' -e 's;/[*][*][*]\([^*]\|[*][^*]\)*[*][*][*]/;;g' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %.pgtemplate

# Assemble PG parser from template and Hx parser fragments.
%Meta.pg: %Meta.pgtemplate
	@/bin/echo -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR $@.\n' && $(SH_EXTRA) && set -x \
	&& prefix=$$($(NOEXEC) sed -n 's/prefix"\(.*\)".*/\1/p' $<) \
	&& $(NOEXEC) sed \
	 -e '/^%%%HXNONTERMINALS%%%$$/    bnames' \
	 -e '/^%%%HXDECLARATIONS%%%$$/    bdecs' \
	 -e '/^%%%HXPREPRODUCTIONS%%%$$/  bpre' \
	 -e '/^%%%HXPOSTPRODUCTIONS%%%$$/ bpost' \
	 -e 'b' \
	 -e ':names' -e 'r org/crsx/hacs/Hx.pgnames' -e 'd' \
	 -e ':decs'  -e 'r org/crsx/hacs/Hx.pgdecs'  -e 'd' \
	 -e ':pre'   -e 'r org/crsx/hacs/Hx.pgpre'   -e 'd' \
	 -e ':post'  -e 'r org/crsx/hacs/Hx.pgpost'  -e 'd' \
	 $< \
	| sed -e "s/%%%PREFIX%%%/$$prefix/g" > '$@.tmp'
	@set -x && mv '$@.tmp' '$@'
.SECONDARY: %Meta.pg

# Extract sorts from template for use by GenerateCRS.
%Meta-sorts.crs : %.pgbase
	@/bin/echo -e '\n>>> GENERATING META-SOURCE SORT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -n -e 's;/[*][*][*]METASORTS: *\(\([^*]\|[*][^*]\)*\)[*][*][*]/;\1;p' -e 's;/[*][*][*]\([^*]\|[*][^*]\)*[*][*][*]/;;g' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

# Generate PG parser for straight terms.
%Parser.pg : %.pgbase
	@/bin/echo -e '\n>>> GENERATING PLAIN TERM PARSER GENERATOR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -e 's;/[*][*][*]PG: *\(\([^*]\|[*][^*]\)*\)[*][*][*]/;\1;' -e 's;/[*][*][*]\([^*]\|[*][^*]\)*[*][*][*]/;;g' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
.SECONDARY: %Parser.pg

# Extract sort declarations for user's compiler from template.
%-sorts.crs : %.pgbase
	@/bin/echo -e '\n>>> GENERATING PLAIN TERM SORT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -n -e 's;/[*][*][*]SORTS: *\(\([^*]\|[*][^*]\)*\)[*][*][*]/;\1;p' -e 's;/[*][*][*]\([^*]\|[*][^*]\)*[*][*][*]/;;g' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

# Compile PG parser specification to JavaCC.
%.jj : %.pg
	@/bin/echo -e '\n>>> GENERATING JavaCC GRAMMAR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(PG) -source=$(TEMP) $<
.SECONDARY: %.jj

# Compile JavaCC parser to Java.
%.java: %.jj
	@/bin/echo -e '\n>>> GENERATING JAVA PARSER SOURCE $@.\n' && $(SH_EXTRA) && set -x \
	&& cd $(dir $<) && $(NOEXEC) $(JAVACC) $(notdir $<)
.SECONDARY: %.java

# Compile Java to class file.
$(BUILD)/%.class: $(TEMP)/%.java
	@/bin/echo -e '\n>>> COMPILING JAVA CLASS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) mkdir -p $(BUILD) \
	&& $(NOEXEC) cd $(TEMP) && $(NOEXEC) $(JAVAC) -cp ":$(CRSXJAR)" -d $(BUILD) $*.java



# Debugging helpers.

%.crsp: %.crs
	@/bin/echo -e '\n>>> GENERATING PARSED CRSX FILE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[^/]*CheckGrammar\[\(.*\)\]/\1/p' $<) \
	&& $(NOEXEC) $(CRSX) grammar="($$parsers)" rules='$*.crs' dump-rules='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
