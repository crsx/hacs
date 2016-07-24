#

# Setup.
FLEX = flex

# Dependencies.
simple.hx : simple.lhx lhx2hx
realclean ::; rm -f simple.hx lhx2hx

# Rules.
%.c : %.l
	$(FLEX) -s -o $*.c $*.l

%.hx : %.lhx
	./lhx2hx < $*.lhx > $*.lhx.tmp
	mv $*.lhx.tmp  $*.hx

# Generic.
clean ::
	rm -fr auto *~ *.aux *.bbl *.blg *.log *.toc *.out *.nav *.snm *.vrb *.o *.tmp

realclean :: clean
