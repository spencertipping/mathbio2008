model-runtime: ca-rng.h model.h model-runtime.c
	gcc -O3 -mtune=native model-runtime.c

model-debug: ca-rng.h model.h model-runtime.c
	gcc -O3 -fno-inline -mtune=native model-runtime.c

doc: model.pdf

model.pdf: model.tex
	pdflatex model.tex

model.h: model.tex
	sd --no-cpp --extension=h --literal-language=ccode model.tex
