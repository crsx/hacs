# -*-Makefile-*- definitions for HACS distribution.


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
# The jar.
CRSXJAR = $(CRSXROOT)/crsx.jar
$(CRSXJAR):; cd $(CRSXROOT) && make
#
# The rulecompiler.
RULEC = $(CRSXROOT)/bin/crsxc
$(RULEC):; cd $(CRSXROOT) && make bin/crsx
#
CRSX = $(JAVA) -ea -cp ":$(CRSXJAR)" net.sf.crsx.run.Crsx allow-unnamed-rules $(EXTRA)
PG = $(JAVA) -cp ":$(CRSXJAR)" net.sf.crsx.pg.PG $(EXTRA)

# So -n works...
NOEXEC = $(if,$(findstring -n,$(MAKE)),echo)
SH_EXTRA = :


# RULES.

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

%.hxp : %.hx
	@/bin/echo -e '\n>>> PARSING HACS TO TERM $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxParser';'net.sf.crsx.text.Text';)" \
		input='$<' category=hxModule \
		output='$@.tmp' simple-terms max-indent=10 width=255 \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%.pgbase : %.hxp
	@/bin/echo -e '\n>>> GENERATING PARSER GENERATOR BASE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(CRSX) \
		"grammar=('org.crsx.hacs.HxParser';'net.sf.crsx.text.Text';)" \
		rules=org/crsx/hacs/CookPG.crs wrapper=PG \
		input='$<' \
		output='$@.tmp' sink=net.sf.crsx.text.TextSink \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%.pg : %.pgbase
	@/bin/echo -e '\n>>> GENERATING PLAIN TERM PARSER GENERATOR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -n -e 's;%%%VERSION%%%;$(VERSION);' -e 's;////PG:;;p' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%-sorts.crs : %.pgbase
	@/bin/echo -e '\n>>> GENERATING PLAIN TERM SORT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -n -e 's;%%%VERSION%%%;$(VERSION);' -e 's;////SORTS:;;p' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%Meta.pg : %.pgbase
	@/bin/echo -e '\n>>> GENERATING META-SOURCE PARSER GENERATOR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -e 's;%%%VERSION%%%;$(VERSION);' -e 's;\(^class [^ ]*\) ;\1Meta ;' -e 's;////METAPG:;;' -e '\;^[ ]*////;d' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

%Meta-sorts.crs : %.pgbase
	@/bin/echo -e '\n>>> GENERATING META-SOURCE SORT DECLARATIONS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) sed -n -e 's;%%%VERSION%%%;$(VERSION);' -e 's;////METASORTS:;;p' '$<' > '$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'

# Compile PG+CRSX source files to Java source files.

%.jj: %.pg
	@/bin/echo -e '\n>>> GENERATING JavaCC GRAMMAR $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(PG) $<

# Compile PG+CRSX source files to C source files.

# Compile JavaCC+Java source files.

%.java: %.jj
	@/bin/echo -e '\n>>> GENERATING JAVA PARSER SOURCE $@.\n' && $(SH_EXTRA) && set -x \
	&& cd $(dir $<) && $(NOEXEC) $(JAVACC) $(notdir $<)

%.class: %.java
	@/bin/echo -e '\n>>> COMPILING JAVA CLASS $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) $(JAVAC) -cp ":$(CRSXJAR)" $<

# Debugging helpers.

%.crsp: %.crs
	@/bin/echo -e '\n>>> GENERATING PARSED CRSX FILE $@.\n' && $(SH_EXTRA) && set -x \
	&& $(NOEXEC) parsers=$$(sed -n 's/^[^/]*CheckGrammar\[\(.*\)\]/\1/p' $<) \
	&& $(NOEXEC) $(CRSX) grammar="($$parsers)" rules='$*.crs' dump-rules='$@.tmp' \
	&& $(NOEXEC) mv '$@.tmp' '$@'
