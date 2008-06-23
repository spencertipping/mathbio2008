CC		= gcc
CC_OPTS		= -O3 -mtune=native -std=c99 -fgnu89-inline -lm -Wall -g
CC_RUN_OPTS	= $(CC_OPTS)
CC_DEBUG_OPTS	= $(CC_OPTS) -DDEBUG -pg

GPROF		= gprof
GPROF_OPTS	=
GPROF_SUM_OPTS	= -s

SD		= sd
SD_OPTS		= --no-cpp --extension=h --literal-language=ccode --line-comment=//

LATEX		= latex
PDFLATEX	= pdflatex
TEX_OPTS	=

VALGRIND	= valgrind
VALGRIND_OPTS	= --leak-check=full -v --show-reachable=yes
MEMCHECK_OPTS	= --tool=memcheck
CACHEGRIND_OPTS	= --tool=callgrind --simulate-cache=yes

PROFILES	= linked-profiles

.PHONY: all bin bench cache check clean doc mem mem1 mem2 mem3

all: bin doc

bin: model-runtime model-debug

bench: model-runtime
	time ./$< < $(PROFILES)/bench > /dev/null

cache: model-runtime
	$(VALGRIND) $(CACHEGRIND_OPTS) ./$< < $(PROFILES)/cache || echo

check: model-runtime
	./$< < $(PROFILES)/check > check.csv

clean:
	rm -f *.aux *.dvi *.h *.log *.out *.pdf *.toc model-runtime model-debug prof check.csv

doc: model.pdf

mem: mem1 mem2 mem3

mem1: model-debug
	$(VALGRIND) $(VALGRIND_OPTS) ./$< < $(PROFILES)/mem1 || echo

mem2: model-debug
	$(VALGRIND) $(VALGRIND_OPTS) ./$< < $(PROFILES)/mem2 | $(VALGRIND) $(VALGRIND_OPTS) ./$< || echo

mem3: model-debug
	$(VALGRIND) $(MEMCHECK_OPTS) ./$< < $(PROFILES)/mem1 || echo

prof: model-debug
	rm -f gmon.sum gmon.out
	./$< < $(PROFILES)/prof
	mv gmon.out gmon.sum
	for i in 1 2 3 4 5 6 7 8 9 10; do \
	  ./$< < $(PROFILES)/prof; \
	  $(GPROF) $(GPROF_SUM_OPTS) $< gmon.out gmon.sum; \
	done
	$(GPROF) $(GPROF_OPTS) $< > prof

model-runtime: ca-rng.h model.h model-runtime.c
	$(CC) $(CC_RUN_OPTS) -o $@ model-runtime.c

model-debug: ca-rng.h model.h model-runtime.c
	$(CC) $(CC_DEBUG_OPTS) -o $@ model-runtime.c

%.pdf: %.tex
	$(LATEX) $(TEX_OPTS) $< && $(PDFLATEX) $(TEX_OPTS) $<

%.h: %.tex
	$(SD) $(SD_OPTS) $<
