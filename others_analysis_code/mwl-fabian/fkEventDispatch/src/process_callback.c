/*
 * file : process_callback.c
 *
 *  process_callback( hObj, callbacks, eventdata )
 *
 *
 * Copyright (c) 2006 by Fabian Kloosterman
 * $Revision: 0.1 $
 * MEX-file function.
 */

#include "mat.h"
#include "mex.h"

void
mexFunction( int            nlhs,
             mxArray       *plhs[],
             int            nrhs,
             const mxArray *prhs[]
           )
{

  mxArray *hObj;
  int n,c,calls,ncalls,nvar,j,nfields;
  const mxArray *appdata;
  mxArray *callback;
  mxArray *callback_out[1], *call, **callback_in;
  char buf[25];
  int *counter;
  int total_count;
  int propagate=1;
  /* no error checking for now */

  if (nrhs>3) {
    propagate = (int) mxGetScalar(prhs[3]);
  }

  hObj = (mxArray*) prhs[0];
  n = mxGetNumberOfElements( prhs[1] );

  counter = (int*) mxCalloc( n, sizeof(int) );
  total_count = n;

  while (total_count>0 && mxGetScalar(hObj)!=0.0 && hObj!=NULL) 
  {
    appdata = mexGet( mxGetScalar(hObj), "ApplicationData" );

    if (appdata==NULL) {
      if (propagate) {
	hObj = (mxArray*) mexGet( mxGetScalar(hObj), "Parent" );
	continue;
      } else {
	break;
      }
    }

    /* loop through all requested callbacks */
    for (c=0;c<n;c++) {

      if (counter[c]!=0)
	continue;
      /* callback defined for hObj? */
      mxGetString( mxGetCell( prhs[1], c ), buf, 25 );
      callback = mxGetField( appdata, 0, buf );
      
      if (callback==NULL)
	/* this callback is not defined for current object */
	/* we'll leave this one for the parent */
	continue;
      
      /* loop through all callback functions for this callback */
      /* initial assumption: function callback will be processed */
      counter[c] = 0;
      ncalls = mxGetNumberOfElements( callback );
      for (calls=0;calls<ncalls;calls++) {
	
	/* construct input argument array */
	call = mxGetCell( callback, calls);
	nvar = mxGetNumberOfElements( call );
	callback_in = (mxArray**) mxCalloc( nvar+3, sizeof(mxArray*) );
	callback_in[0] = mxGetCell( call, 0 );
	callback_in[1] = hObj;
	callback_in[2] = (mxArray*) prhs[2];
	for (j=1;j<nvar;j++) {
	  callback_in[j+2] = mxGetCell( call, j );
	}
	
	/* call callback function */
	mexCallMATLAB( 1, callback_out, nvar+2, callback_in , "feval" );
	
	/* process the output */
	counter[c] |= (int) mxGetScalar(callback_out[0]);
	
	mxFree( callback_in );

	if (mexGet(mxGetScalar(hObj), "Type")==NULL) {
	  hObj = NULL;
	  break;
	}
      }
      
      if (counter[c]==1)
	total_count += -1;

      if (hObj==NULL || mexGet(mxGetScalar(hObj), "Type")==NULL) {
	hObj = NULL;
	break;
      }
    }

    if (hObj!=NULL) {
      if (propagate) {
	hObj = (mxArray*) mexGet( mxGetScalar(hObj), "Parent" );
      } else {
	break;
      }
    }

    /*    mexCallMATLAB(0,NULL,1,&hObj,"disp"); */
  }
}
