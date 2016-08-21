/*
 * file : delvarmat.c
 *
 *  delvarmat [MAT-file] variable [variable] ...
 *
 *
 * Copyright (c) 1984-98 by The MathWorks, Inc.
 * $Revision: 5.1 $
 * MEX-file function.
 */

#include <string.h>    /* for strstr(), strcpy() */
#include "mat.h"
#include "mex.h"

#define DEFAULT_MATFILE "matlab.mat"

/*
 * usage of MEX-file
 */
void
printUsage()
{
  mexPrintf("Usage: %s [MAT-file] variable [variable]\n", mexFunctionName());
}

void
mexFunction( int            nlhs,
             mxArray       *plhs[],
             int            nrhs,
             const mxArray *prhs[]
           )
{
  MATFile *mfp;
  char    *filename=NULL;
  char    *variable=NULL;
  char    *vname=NULL;
  int      buffersize;
  int      index;
  int      status;
  int      len;

  /* 
   * error checking for input arguments
   */
  if (nrhs==0) {
    printUsage();
    return;
  }

  /* 
   * the value returned by the left-hand side is the status.  return 1 if
   * there is a failure.  return 0 if there is success (variable was
   * removed from MAT-file.)  initialize to failure.
   */
  if (nlhs==1) {
    plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
    *mxGetPr(plhs[0]) = 1;
  }
  
  /*
   * get filename to open
   */
  buffersize=mxGetM(prhs[0])*mxGetN(prhs[0])+1;
  filename=mxCalloc(buffersize,sizeof(char));
  mxGetString(prhs[0],filename,buffersize);

  
  /*
   * open MAT-file
   */
  mfp=matOpen(filename,"u+");
  if (mfp==(MATFile *)NULL) {
    mexPrintf("Error: Failed to open file '%s'.\n",filename);
    mxFree(filename);
    return;
  }
  
    
  /* 
   * get variables to delete
   */

  for (index=1;index<nrhs;index++) {

    buffersize=mxGetM(prhs[index])*mxGetN(prhs[index])+1;
    variable=mxCalloc(buffersize,sizeof(char));
    mxGetString(prhs[index],variable,buffersize);
    
    /*
     * delete variable from MAT-file
     */
    status=matDeleteVariable(mfp,variable);
    if (status!=0) {
      mexPrintf("Warning: Failed to delete variable '%s'.\n",variable);
    }

    mxFree(variable);
  }
  /*
   * cleanup variable(s) and close the MAT-file
   */
  mxFree(filename);
  matClose(mfp);

  /*
   * set the change return status to success
   */
  if (nlhs==1) {
    *mxGetPr(plhs[0])=0;
  }
}
