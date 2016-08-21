#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  /* refassign_cell( obj, idx, value ) */

  mxArray* cell;
  int idx=0;

  if (!mxIsCell( prhs[0] ))
    mexErrMsgTxt("Not a cell");

  idx = mxGetScalar( prhs[1] ) - 1;

  cell = mxGetCell( prhs[0], idx );

  if (cell != NULL )
    {
      /*      mxAddField( prhs[0], field_name );*/
      mxSetCell( prhs[0], idx, mxDuplicateArray(prhs[2]) );
      mxDestroyArray( cell );
    }
      

  /* plhs[0] = prhs[0]; */

}
