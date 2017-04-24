#
# Makefile for projects using multibib
#
latex=pdflatex

# Function to grep the multibib citation names out
# of a file and quote them
multibib_names = $(shell \
	grep -o '\\bibliography[^{}]*{' $(1) \
	| grep -v style \
	| sort \
	| uniq \
	| sed 's/\\bibliography/"/;s/{/"/')

web_repo=/Users/gamblin2/Sites/tgamblin.github.io

# Any PDF is a valid target, but this is the default one.
all: todd-cv.pdf

%.pdf: %.tex Sections/*.tex
	$(latex) $*
	for qname in $(call multibib_names,$<); do \
		if [ -z $${qname} ]; then \
			bibtex $*; \
		else \
			bibtex $${qname}; \
		fi; \
	done; \
	$(latex) $*
	$(latex) $*

upload:
	cp todd-cv.pdf $(web_repo)/cv/todd-cv.pdf
	cd $(web_repo) && \
		git add cv/todd-cv.pdf && \
		git commit -m "CV udpate" && \
		git push

clean:
	rm -f *.pdf
	rm -f *.aux *.bbl *.blg *.log *.out *.top *.tui
	rm -f *-mpgraph.mp *synctex.gz*
