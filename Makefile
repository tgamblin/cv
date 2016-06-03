
# Grep the multibib citation names out of the preamble.
multibib_names=$(shell grep newcites preamble.tex |\
	perl -pe 's/[^{]*{([^}]*)}.*/\1/g;s/,/\n/g')


all: todd-cv.pdf

%.pdf: %.tex Sections/*.tex
	pdflatex $*
	for name in $(multibib_names); do \
		bibtex $${name}; \
	done
	pdflatex $*
	pdflatex $*

clean:
	rm -f *.pdf
	rm -f *.aux *.bbl *.blg *.log *.out *synctex.gz*
