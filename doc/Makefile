# Makefile for HACS documentation.

.PHONY: all clean realclean install gitclean
all:: hacs.pdf
install::
clean::
	rm -f *.tmp *~ ./#* *.log *~ *.aux *.bbl *.blg *.toc *.out *.idx *.ind
realclean:: clean
	rm -fr auto *.pdf
gitclean:: realclean

%.pdf : %.tex
	pdflatex $*
	grep -vq bibcite $*.aux || bibtex $*
	pdflatex $*
	pdflatex $*

hacs.pdf : hacs.tex
