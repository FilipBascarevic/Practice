all: stencil

stencil: stencil_1D.cu
	nvcc -g -o stencil stencil_1D.cu
