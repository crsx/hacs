#!/bin/bash

# Process options.

crsxcmd=""
for arg
do
    case "$arg" in
        --action=*) HACSACTION="Action-${arg:9}" ;;
        --mode=*) HACSMODE="${arg:7}" ;;
        --sort=*) HACSSORT="${arg:7}" ;;
        --x) set -x ;;
        --*) crsxcmd="$crsxcmd \"${arg:2}\"" ;;
        *) crsxcmd="$crsxcmd input=\"$arg\"" ;;
    esac
done

# Check arguments in environment variables.

success=:

if [ -z "$JAVA" -o ! -x "$(which $JAVA)" ]; then
  success=false; echo "$0: JAVA parameter does not point to an executable (the Java interpreter)." >&2
fi

if [ -z "$JAVAC" -o ! -x "$(which $JAVAC)" ]; then
  success=false; echo "$0: JAVAC parameter does not point to an executable (the Java compiler)." >&2
fi

if [ -z "$CRSXJAR" -o ! -r "$CRSXJAR" ]; then
  success=false; echo "$0: CRSXJAR parameter does not point to a file (the CRSX Java archive)." >&2
fi

if [ -z "$HACSBUILD" -o ! -d "$HACSBUILD" ]; then
  success=false; echo "$0: HACSBUILD parameter does not point to a directory." >&2
fi

if [ -z "$HACSPARSERCLASS" ]; then
  success=false; echo "$0: HACSPARSERCLASS is not defined (needs to be generated parser class)." >&2
fi

if [ -z "$HACSRULES" ]; then
  success=false; echo "$0: HACSRULES is not defined (needs to be file with generated rules)." >&2
fi

if [ -z "$HACSSINK" ]; then HACSSINK="net.sf.crsx.text.TextSink"; fi
if [ -z "$HACSMODE" ]; then HACSMODE="Print"; fi

if [ -z "$HACSPREFIX" ]; then
  success=false; echo "$0: HACSPREFIX is not defined (should be parser category prefix)." >&2
fi

if [ -z "$HACSACTION" ]; then
  HACSACTION="$HACSSORT";
elif [ -z "$HACSSORT" ]; then
  HACSSORT=$( $JAVA -cp "$HACSBUILD:$CRSXJAR" net.sf.crsx.run.Crsx allow-unnamed-rules "grammar=('$HACSPARSERCLASS';'net.sf.crsx.text.Text';)" "rules=$HACSRULES" "term=\$SortFor-$HACSACTION" sink="net.sf.crsx.text.TextSink" );
fi

# Run the command.

crsxcmd="$JAVA -cp '$HACSBUILD:$CRSXJAR' net.sf.crsx.run.Crsx allow-unnamed-rules 'grammar=(\"$HACSPARSERCLASS\";\"net.sf.crsx.text.Text\";)' 'rules=$HACSRULES' 'wrapper=\$$HACSMODE-$HACSACTION' 'sink=$HACSSINK' 'category=$HACSPREFIX$HACSSORT' $crsxcmd"

if $success; then
  eval "$crsxcmd"
else
  echo "Usage: $0 --sort=Sort [--action=Print] (InputFile | --term=Program)" >&2
fi
