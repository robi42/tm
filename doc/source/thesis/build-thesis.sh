#!/bin/sh
# Copyright (C) 2014-2016 by Thomas Auzinger <thomas@auzinger.name>
# Modified by Robert Thurnher

SOURCE=thesis
SECONDS=0

# Clean build environment
rm -f $SOURCE.a* $SOURCE.b* $SOURCE.g* $SOURCE.i* $SOURCE.l* $SOURCE.out $SOURCE.synctex.gz $SOURCE.toc

# Build the thesis document
pdflatex $SOURCE
bibtex   $SOURCE
pdflatex $SOURCE
pdflatex $SOURCE
makeindex -t $SOURCE.glg -s $SOURCE.ist -o $SOURCE.gls $SOURCE.glo # Glossary
makeindex -t $SOURCE.alg -s $SOURCE.ist -o $SOURCE.acr $SOURCE.acn # Acronyms
makeindex -t $SOURCE.ilg -o $SOURCE.ind $SOURCE.idx # Index
pdflatex $SOURCE
pdflatex $SOURCE

echo
echo Thesis document compiled.
echo Took $SECONDS seconds.
echo
