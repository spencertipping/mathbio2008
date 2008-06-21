CC		= gcc
CC_OPTS		= -O3 -mtune=native -std=c99 -fgnu89-inline -lm -Wall -g

SD		= sd
SD_OPTS		= --no-cpp --extension=h --literal-language=ccode --line-comment=//

LATEX		= latex
PDFLATEX	= pdflatex
TEX_OPTS	=

VALGRIND	= valgrind
VALGRIND_OPTS	= --leak-check=full -v --show-reachable=yes
MEMCHECK_OPTS	= --tool=memcheck
CACHEGRIND_OPTS	= --tool=cachegrind

.PHONY: bin cache clean doc mem

bin: model-runtime model-debug

cache: model-debug
	$(VALGRIND) $(CACHEGRIND_OPTS) ./$< < profiles/cache || echo

clean:
	rm -f *.aux *.dvi *.h *.log *.out *.pdf *.toc model-runtime model-debug

doc: model.pdf

mem: model-debug
	$(VALGRIND) $(VALGRIND_OPTS) ./$< < profiles/mem1 || echo
	$(VALGRIND) $(VALGRIND_OPTS) ./$< < profiles/mem2 | $(VALGRIND) $(VALGRIND_OPTS) ./$< || echo
	$(VALGRIND) $(MEMCHECK_OPTS) ./$< < profiles/mem1 || echo

prof: model-debug
	$< < profiles/prof && $(GPROF) $(GPROF_OPTS) $< > prof

model-runtime: ca-rng.h model.h model-runtime.c
	$(CC) $(CC_OPTS) -o $@ model-runtime.c

model-debug: ca-rng.h model.h model-runtime.c
	$(CC) $(CC_OPTS) -fno-inline -pg -o $@ model-runtime.c

%.pdf: %.tex
	$(LATEX) $(TEX_OPTS) $< && $(PDFLATEX) $(TEX_OPTS) $<

%.h: %.tex
	$(SD) $(SD_OPTS) $<
