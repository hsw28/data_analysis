#include <mat.h>
#include <matrix.h>
#include <mex.h>

/* main matab function */
void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{


  /* call as sortedhist( event, bins ) */

  /* event is a vector of sorted event times */
  /* bins is a nx2 matrix of bin edges */

  /* the function returns a vector with the event counts for each bin */

  /* variables */
  long nevents, nseg;
  double *pevent;
  double *pseg;
  mxArray *out;
  double *pout;
  long next_idx, k, idx, i;

  /* check input arguments */
  if (nrhs!=2)
    mexErrMsgTxt("Expecting two input arguments!");

  nevents = mxGetNumberOfElements( prhs[0] );
  nseg = mxGetM( prhs[1] );

  pevent = mxGetPr( prhs[0] );
  pseg = mxGetPr( prhs[1] );

  out = mxCreateDoubleMatrix( nseg, 1, mxREAL );
  pout = mxGetPr( out );

  next_idx = 0;
  
  /* for each segment ... */
  for (k=0; k<(nseg); k++)
    {

      while (next_idx<nevents && (pevent[next_idx]<pseg[k]))
	next_idx++;

      idx = next_idx;
      while (idx<nevents && (pevent[idx]<pseg[k+nseg]))
	{
	  pout[k]++;
	  idx++;
	}
    }
  
  if (nlhs>0)
    plhs[0] = out;

}
