#include "mex.h"
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  /* given two arrays of size p-by-c and c-by-t */
  /* this function will loop over p and t and then */
  /* loop over c to calculate the prod( p.^a ) */

  /* variables */
  long p,c,t;
  long i,j,k;
  mxArray *out;
  double *pout;
  double *pP, *pA;
  long idx1, idx2, idx3;
  int *pjc, *pir;
  int nelements;
  /* no error checking */

  /* get array sizes */
  p = mxGetM( prhs[0] );
  c = mxGetN( prhs[0] );
  t = mxGetN( prhs[1] );

  pP = mxGetPr( prhs[0] );
  pA = mxGetPr( prhs[1] );

  /* create output array */
  out = mxCreateDoubleMatrix( p, t , mxREAL );
  pout = mxGetPr( out );

/*   for(k=0; k<p; k++) { */

/*     for(j=0; j<t; j++) { */

/*       idx1 = j*p + k; */
/*       idx2 = j*c; */

/*       pout[idx1] = 1; */

/*       for(i=0; i<c; i++) { */

/* 	/\*	if (pA[idx2+i]!=0) {*\/ */
/* 	  pout[idx1] *= pow(pP[i*p+k], pA[idx2+i]); */
/* 	  /\*}*\/ */

/*       } */

/*     } */

/*   } */
  
  for (i=0;i<p*t;i++) {
    pout[i] = 1;
  }

  if (mxIsSparse( prhs[1] )) {

    idx2 = -1;
   
    pjc = mxGetJc( prhs[1] );
    pir = mxGetIr( prhs[1] );

    for (j=0;j<t;j++) {

      nelements = pjc[j+1]-pjc[j];
      idx1 = j*p;

      for (i=0;i<nelements;i++) {

	idx2++;
	idx3 = pir[idx2]*p;

	for (k=0;k<p;k++) {
	  
	  pout[idx1+k] *= pow( pP[idx3+k], pA[idx2] );

	}
      }
    }
  } else {
    
    for (i=0; i<c; i++) {
      
      idx3 = i*p;
      
      for(j=0;j<t;j++) {
	
	idx2 = j*c+i;
	if (pA[idx2]!=0) {

	  idx1 = j*p;
	  
	  for(k=0;k<p;k++) {
	    /*	    pout[idx1+k] *= pow( pP[idx3+k], pA[idx2] ); */
	    pout[idx1+k] += pA[idx2]*pP[idx3+k];
	      /**pout++ *= pow( pP[idx3+k], pA[idx2] );*/
	  }
	  
	}
	
      }
      
    }

  }

  plhs[0] = out;
	
}
