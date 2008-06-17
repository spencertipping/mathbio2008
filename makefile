CC		= gcc
CC_OPTS		= -O3 -mtune=native -std=c99 -fgnu89-inline -lm

SD		= sd
SD_OPTS		= --no-cpp --extension=h --literal-language=ccode --line-comment=//

VALGRIND	= valgrind
VALGRIND_OPTS	=

bin: model-runtime model-debug

model-runtime: ca-rng.h model.h model-runtime.c
	$(CC) $(CC_OPTS) -o $@ model-runtime.c

model-debug: ca-rng.h model.h model-runtime.c
	$(CC) $(CC_OPTS) -fno-inline -o $@ model-runtime.c

mem: model-debug
	$(VALGRIND) $(VALGRIND_OPTS) ./$< < profiles/mem

doc: model.pdf

model.pdf: model.tex
	latex $<
	pdflatex $<

model.h: model.tex
	$(SD) $(SD_OPTS) $<
