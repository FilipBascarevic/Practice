CC=nvcc
CFLAGS=-g

all: stencil

stencil: stencil_1D.cu
	${CC} ${CFLAGS} -o $@ $^

.PHONY=clean
clean:
	rm -f stencill
