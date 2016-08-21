#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  /* refassign( obj, field, value, idx ) */

  mxArray* field;
  char field_name[100];
  int idx=0;

  mxGetString(prhs[1], field_name, 100);

  if (!mxIsStruct( prhs[0] ))
    mexErrMsgTxt("Not a structure");

  if (nrhs>3) {
    idx = mxGetScalar( prhs[3] ) - 1;
  }

  field = mxGetField( prhs[0], idx, field_name );

  if (field != NULL )
    {
      /*      mxAddField( prhs[0], field_name );*/
      mxSetField( prhs[0], idx, field_name, mxDuplicateArray(prhs[2]) );
      mxDestroyArray( field );
    }
      

  /* plhs[0] = prhs[0]; */

}
