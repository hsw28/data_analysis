#include "mex.h"
#include <math.h>

double plus(double a, double b) {
  return a+b;
}
double minus(double a, double b) {
  return a-b;
}
double mult(double a, double b) {
  return a*b;
}
double divide(double a, double b) {
  return a/b;
}

void loop2( double (*op) (double, double), int current_dim, int* dC, int* dA, int *dB, int nC, int* sA, int *sB, double **pC, double *pA, double *pB, int *csA, int *csB ) {

  int j,k, iA, iB;

  if (current_dim==0) {
    for (k=0;k<dC[current_dim];k++) {

      iA = 0;
      iB = 0;

      for (j=0;j<nC;j++) {
	iA += csA[j]*sA[j];
	iB += csB[j]*sB[j];
      }

      **pC = op(pA[iA],pB[iB]);
      (*pC)++;

      /*up the index of current dimension*/
      if (dA[current_dim]!=1)
	(sA[current_dim])++;

      if (dB[current_dim]!=1)
	(sB[current_dim])++;
    }
  } else {

    for (k=0; k<dC[current_dim]; k++ ) {
      /* empty all lower dimension indices */
      for (j=0;j<current_dim; j++) {
	sA[j]=0;
	sB[j]=0;
      }
      
      /* recurse */
      loop2( op, current_dim-1, dC, dA, dB, nC, sA, sB, pC, pA, pB, csA, csB);

      /* up the index of current dimension */
      if (dA[current_dim]!=1)
	(sA[current_dim])++;

      if (dB[current_dim]!=1)
	(sB[current_dim])++;

    }

  }

}


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  int nA, nB, nC;
  const int *dA_orig, *dB_orig;
  int *dA, *dB, *dC, *sA, *sB, *csA, *csB;
  int k;
  mxArray *out;
  double *pA, *pB, *pC;
  
  double (*op) (double, double);

  char op_string[2];

  if (nrhs<2)
    mexErrMsgTxt("Need at least two arguments");

  nA = mxGetNumberOfDimensions( prhs[0] );
  nB = mxGetNumberOfDimensions( prhs[1] );

  dA_orig = mxGetDimensions( prhs[0] );
  dB_orig = mxGetDimensions( prhs[1] );

  if (nA>nB)
    nC = nA;
  else
    nC = nB;

  dC = (int*) mxMalloc( nC * sizeof(int) );
  dA = (int*) mxMalloc( nC * sizeof(int) );
  dB = (int*) mxMalloc( nC * sizeof(int) );
  sA = (int*) mxMalloc( nC * sizeof(int) );
  sB = (int*) mxMalloc( nC * sizeof(int) );
  csA = (int*) mxMalloc( nC * sizeof(int) );
  csB = (int*) mxMalloc( nC * sizeof(int) );

  csA[0] = 1;
  csB[0] = 1;

  for (k=0;k<nC;k++) {
    if (k>=nA)
      dA[k] = 1;
    else
      dA[k] = dA_orig[k];

    if (k>=nB)
      dB[k] = 1;
    else
      dB[k] = dB_orig[k];
    
    sA[k]=0;
    sB[k]=0;

  }

  for (k=1;k<nC;k++) {
    csA[k]=dA[k-1]*csA[k-1];
    csB[k]=dB[k-1]*csB[k-1];
  }

  for (k=0;k<nC;k++) {

    if (k>=nA)
      dC[k] = dB[k];
    else if (k>=nB)
      dC[k] = dA[k];
    else if (dA[k]==dB[k])
      dC[k] = dA[k];
    else if (dA[k]==1)
      dC[k] = dB[k];
    else if (dB[k]==1)
      dC[k] = dA[k];
    else
      mexErrMsgTxt( "Incompatible matrices." );
  }


  out = mxCreateNumericArray( nC, dC , mxDOUBLE_CLASS, mxREAL );
  pC = (double*) mxGetPr( out );
  pA = (double*) mxGetPr( prhs[0] );
  pB = (double*) mxGetPr( prhs[1] );


  if (nrhs<3) {
    op = plus;
  } else if (mxIsChar(prhs[2])) {
    
    mxGetString( prhs[2], op_string, 2);

    if (strcmp(op_string, "+")==0) {
      op = plus;
    } else if (strcmp(op_string, "-")==0) {
      op = minus;
    } else if (strcmp(op_string, "*")==0) {
      op = mult;
    } else if (strcmp(op_string, "/")==0) {
      op = divide;
    } else if (strcmp(op_string, "^")==0) {
      op = pow;
    } else {
      mexErrMsgTxt("Unsupported operation");
    }
  } else {
    mexErrMsgTxt("Unsupported operation");
  }
    

  loop2(op, nC-1, dC, dA, dB, nC, sA, sB, &pC, pA, pB, csA, csB);

  mxFree(dC);
  mxFree(dA);
  mxFree(dB);
  mxFree(sA);
  mxFree(sB);
  mxFree(csA);
  mxFree(csB);

  plhs[0] = out;

}

