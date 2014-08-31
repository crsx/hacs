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
		input='$<' category=HxModule sink=net.sf.crsx.text.TextSink ) \
	&& dir=$(dir $@) && package=$${module%.*} && name=$${module##*.} && packagedir=$$(echo $$package | tr '.' '/') \
	&& $(NOEXEC) mkdir -p $(TEMP)/$$packagedir \
	&& $(NOEXEC) cp $< $(TEMP)/$$packagedir/ \
	&& $(NOEXEC) $(MAKE) $(BUILD)/$$packagedir/$$name.class \
	&& touch $@

clean::; find . -name '*.build-stamp' | xargs rm -f

# Process HACS (.hx) source files to PG+CRSX sources.
#
# Workflow: %.hx
#            ↳ %.hxp
#               ↳ %.pgbase
#                     ↳ %.pg → %.jj → %.java
#                     ↳ %-sorts.crs
#
#                     ↳ %Meta.pg → %.jj → %.java
#                     ↳ %Meta-sorts.crs
#
#               ↳ %.crs                    ↲

$(TEMP)/%.hxp : $(TEMP)/%.hx
	@/bin/echo -e '\n>>> PARSING HACS TO TERM $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) mkdir -p $(TEMP) \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		input='$<' category=HxModule \
		output='$@.tmp' simple-terms max-indent=10 width=255 \
	&& $(NOEXEC) mv '$@.tmp' '$@'

$(TEMP)/%.pgbase : $(TEMP)/%.hxp
	@/bin/echo -e '\n>>> GENERATING PARSER GENERATOR BASE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxRaw';'net.sf.crsx.text.Text';)" \
		rules=$(HACS)/org/crsx/hacs/CookPG.crs wrapper=PG \
		input='$<' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'

$(TEMP)/%.pg : $(TEMP)/%.pgbase
	@/bin/echo -e '\n>>> GENERATING PLAIN TERM PARSER GENERATOR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -e 's;/[*][*][*]PG: *\(.*\)[*][*][*]/;\1;' -e 's;/[*][*][*].*[*][*][*]/;;' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

$(BUILD)/%-sorts.crs : $(TEMP)/%.pgbase
	@/bin/echo -e '\n>>> GENERATING PLAIN TERM SORT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -n -e 's;/[*][*][*]SORTS: *\(.*\)[*][*][*]/;\1;p' -e 's;/[*][*][*].*[*][*][*]/;;' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

$(TEMP)/%Meta.pg : $(TEMP)/%.pgbase
	@/bin/echo -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -e 's;\(^class [^ ]*\) ;\1Meta ;' -e 's;/[*][*][*]METAPG: *\(.*\)[*][*][*]/;\1;' -e 's;/[*][*][*].*[*][*][*]/;;' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

$(BUILD)/%Meta-sorts.crs : $(TEMP)/%.pgbase
	@/bin/echo -e '\n>>> GENERATING META-SOURCE SORT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -n -e 's;/[*][*][*]METASORTS: *\(.*\)[*][*][*]/;\1;p' -e 's;/[*][*][*].*[*][*][*]/;;' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

# Compile PG+CRSX source files to Java source files.

$(TEMP)/%.jj: $(TEMP)/%.pg
	@/bin/echo -e '\n>>> GENERATING JavaCC GRAMMAR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(PG) -source=$(TEMP) $<

# Compile PG+CRSX source files to C source files.

# Compile JavaCC+Java source files.

$(TEMP)/%.java: $(TEMP)/%.jj
	@/bin/echo -e '\n>>> GENERATING JAVA PARSER SOURCE $@.\n' && $(SH_EXTRA) && set -x \
	&& cd $(dir $<) && $(NOEXEC) $(JAVACC) $(notdir $<)

$(BUILD)/%.class: $(TEMP)/%.java
	@/bin/echo -e '\n>>> COMPILING JAVA CLASS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) mkdir -p $(BUILD) \
	&& $(NOEXEC) cd $(TEMP) && $(NOEXEC) $(JAVAC) -d $(BUILD) -cp ":$(CRSXJAR)" $*.java

# Debugging helpers.

%.crsp: %.crs
	@/bin/echo -e '\n>>> GENERATING PARSED CRSX FILE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[^/]*CheckGrammar\[\(.*\)\]/\1/p' $<) \
	&& $(NOEXEC) $(CRSX) grammar="($$parsers)" rules='$*.crs' dump-rules='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
