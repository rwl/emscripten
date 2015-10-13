#include <stdlib.h>
#include <complex.h>

double complex * heap_complex_double(double re, double im) {
	double complex *c;
	c = (double complex *) malloc (sizeof(double complex));
	*c = re + im * I;
	return c;
}

double deref_complex_double_real(double complex *c) {
	return creal(*c);
}

double deref_complex_double_imag(double complex *c) {
	return cimag(*c);
}

double complex * heap_complex_doubles(double *vals, int n) {
	double complex *c;
	c = (double complex *) malloc (sizeof(double complex)*n);
	for (int i = 0; i < n; i++) {
		c[i] = vals[2*i] + vals[2*i+1] * I;
	}
	return c;
}

double * deref_complex_doubles(double complex *vals, int n) {
	double *d;
	d = (double *) malloc (sizeof(double) * n*2);
	for (int i = 0; i < n; i++) {
		d[2*i] = creal(vals[i]);
		d[2*i+1] = cimag(vals[i]);
	}
	return d;
}
