#include <stdio.h>

#define RADIUS 2
#define BLOCK_SIZE 10
#define BLOCK_COUNT 2

__global__ void stencil_1d(int *in, int *out) {

	// shared memory
	__shared__ int temp[BLOCK_SIZE + 2*RADIUS];
	
	// element in array
	int gindex = threadIdx.x + blockIdx.x * blockDim.x;
	// element in shared memory
	int lindex = threadIdx.x + RADIUS;
	
	// Read input elements into shared memory
	temp[lindex] = in[gindex];
	
	if (threadIdx.x < RADIUS) {
		temp[lindex-RADIUS] = in[gindex-RADIUS];
		temp[lindex+BLOCK_SIZE] = in[gindex+BLOCK_SIZE];
	}
	
	// Synchronize (ensure all the data is available)
	__syncthreads();
	
	// Apply the stencil
	int result = 0;
	for(int offset = -RADIUS; offset <= RADIUS; offset++) {
		result += temp[lindex+offset];
	}
	
	// Store the result
	out[gindex] = result;
	
}

int main (void) {

	int *input;
	int *output;
	
	int *d_input;
	int *d_output;
	
	// input array
	input = (int *)malloc((BLOCK_SIZE*BLOCK_COUNT + 2*RADIUS)*sizeof(int));
	for (int index = 0; index < BLOCK_SIZE*BLOCK_COUNT + 2*RADIUS; index++) {
		input[index] = index;
	}
	// output array
	output = (int *)malloc((BLOCK_SIZE*BLOCK_COUNT)*sizeof(int));
	
	// create array in device
	cudaMalloc((void **)&d_input, (BLOCK_SIZE*BLOCK_COUNT + 2*RADIUS)*sizeof(int));
	cudaMalloc((void **)&d_output, (BLOCK_SIZE*BLOCK_COUNT)*sizeof(int));
	
	// copy data from host to device
	cudaMemcpy(d_input, input, (BLOCK_SIZE*BLOCK_COUNT + 2*RADIUS)*sizeof(int), cudaMemcpyHostToDevice);
	
	// Run kernel
	stencil_1d<<<BLOCK_COUNT,BLOCK_SIZE>>>(d_input+RADIUS, d_output);
	
	// copy data from device to host
	cudaMemcpy(output, d_output, (BLOCK_SIZE*BLOCK_COUNT)*sizeof(int), cudaMemcpyDeviceToHost);
	
	cudaFree(d_input);
	cudaFree(d_output);
	
	// Display result
	printf("Result of 1D stencil is : \n");
	for (int index = 0; index < BLOCK_SIZE*BLOCK_COUNT; index++) {
		printf("%d ", output[index]);
	}
	printf("\n");
	
	
	
	free(input);
	free(output);
	
}
