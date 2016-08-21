/*
 * file : process_event_callbacks.c
 *
 *  process_event_callbacks( hObj, callbacks, eventdata, propagate )
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
  int call, ncalls;
  mxArray *callback;
  mxArray *callback_info[3];
  int field_id;
  int propagate=1;
  int failure;
  int callback_processed=0;
  double handle;
  int hascallback = 0;

  char cb_string[50];

  /* no error checking for now */

  if (nrhs>3) {
    propagate = (int) mxGetScalar(prhs[3]);
  }

  /* first argument is a graphics handle */
  hObj = (mxArray*) prhs[0];
  handle = mxGetScalar(hObj);

  /* propagate only for axes descendents */
  callback_info[0] = hObj;
  callback_info[1] = mxCreateString("axes");
  failure = mexCallMATLAB( 1, &callback, 2, callback_info, "ancestor" );

  propagate &= !mxIsEmpty( callback );

  /* we will always propagate for MyKeyPress and MyKeyRelease */
  mxGetString(prhs[1], cb_string, 50);
  propagate |= !strncmp( cb_string, "MyKey", 5);

  /* while loop continues until we can't propagate the hierarchy any further */
  while (!callback_processed && handle!=0.0 && hObj!=NULL) 
  {

    mexSetTrapFlag(1);

    /* event callback defined for hObj? */
    callback_info[0] = hObj;
    callback_info[1] = (mxArray*) prhs[1];

/*     failure = mexCallMATLAB( 1, &callback, 2, callback_info, "isprop" ); */
    
/*     if (failure || mxGetScalar( callback )==0.0 ) { */
/*       /\* no event callback defined, continue to parent *\/ */
/*       if (propagate) { */
/* 	hObj = (mxArray*) mexGet( handle, "Parent" ); */
/* 	handle = mxGetScalar(hObj); */
/* 	continue; */
/*       } else { */
/* 	break; */
/*       } */
/*     } */

    /* get event callback */
    failure  = mexCallMATLAB(1, &callback, 2, callback_info, "isprop");

    hascallback = mxGetScalar(callback);

    /*mexPrintf("has callback prop: %d\n", hascallback); */

    if (hascallback)
      failure = mexCallMATLAB( 1, &callback, 2, callback_info, "get" ); 

    if (failure || hascallback==0 || mxIsEmpty(callback)) {
      /* this event callback is not defined for current object */
      /* we'll leave this one for the parent */
      /* mexPrintf("no callback found\n"); */
      if (propagate) {
	hObj = (mxArray*) mexGet( handle, "Parent" );
	handle = mxGetScalar(hObj);
	continue;
      } else {
	break;
      }
    }

    mexSetTrapFlag(0);
      
    /* loop through the callback functions for this event */
    /* initial assumption: function callback is not processed */

    if (!mxIsStruct( callback )) {

      callback_processed = make_call( callback, hObj, prhs[2] );

    } else {

      field_id = mxGetFieldNumber( callback, "callback" );
      
      if (field_id != -1) {
      
	ncalls = mxGetNumberOfElements( callback );

	for (call=0;call<ncalls;call++) {
	  
	  callback_processed &= make_call( mxGetFieldByNumber( callback, call, field_id ), hObj, prhs[2] );

	  /* if a callback delete hObj, then stop */
	  if (mexGet(handle, "Type")==NULL) {
	    break;
	  }
	  
	}

      }
    }

    /* if a callback delete hObj, then stop */
    if (mexGet(handle, "Type")==NULL) {
      break;
    }

    /* propagate? */
    if (!callback_processed && propagate) {
      hObj = (mxArray*) mexGet( handle, "Parent" );
      handle = mxGetScalar(hObj);
    } else {
      break;
    }
    
    
  } /* end while loop */

  
  /* assign outputs */
  if (nlhs>0) {
    if (callback_processed)
      plhs[0] = mxDuplicateArray(hObj);
    else
      plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
  }
  
}


int make_call( mxArray* call, mxArray* hObj, mxArray* eventdata )
{
     
  mxArray *callback_out[1];
  mxArray *callback_info[3];
  mxArray **callback_in=NULL;
  mxArray *tmpcall;
  mxClassID classid;
  int failure;
  int nargs, j;
  double retval;
  int nargout=0;

  /* helper function to feval a single callback */

  if ( mxIsEmpty( call ) )
    return 0;

  classid = mxGetClassID( call );

  if (classid == mxCHAR_CLASS) {
    /* callback function is a string, evaluate in base workspace */
    /* gcbo won't work, so temporarily assign the current callback object to the variable gcbo */

    callback_info[0] = mxCreateString("base");
    callback_info[1] = mxCreateString("gcbo");
    callback_info[2] = hObj;
    mexCallMATLAB( 0, (mxArray **) NULL, 3, callback_info, "assignin" );

    /* evaluate string */
    callback_info[1] = call;
    failure = mexCallMATLAB( 0, (mxArray **) NULL, 2, callback_info , "evalin" );

    /* errors will be trapped by matlab */
    
    /* clear gcbo variable */
    callback_info[1] = mxCreateString("clear gcbo");
    failure = mexCallMATLAB( 0, (mxArray **) NULL, 2, callback_info , "evalin" );


  } else if (classid == mxFUNCTION_CLASS) {

    /* get number of output arguments */
    failure = mexCallMATLAB( 1, callback_out, 1, &call, "nargout" );

    nargout = (int) mxGetScalar(callback_out[0]);

    callback_in = (mxArray**) mxCalloc( 3, sizeof(mxArray*) );
    callback_in[0] = call;
    callback_in[1] = hObj;
    callback_in[2] = eventdata;

    if ( nargout<=0 ) {
      /* callback function has NO or a VARIABLE number of outputs */
      failure = mexCallMATLAB(0, (mxArray**) NULL, 3, callback_in, "feval");
    } else {
      /* callback function has at least one output */
      failure = mexCallMATLAB(1, callback_out, 3, callback_in,  "feval");
    }

  } else if (classid == mxCELL_CLASS) {
  
    classid = mxGetClassID( mxGetCell( call, 0 ) );

    if (classid == mxFUNCTION_CLASS || classid == mxCHAR_CLASS) {

      /* get number of output arguments */
      tmpcall = mxGetCell(call, 0 );
      failure = mexCallMATLAB( 1, callback_out, 1, &tmpcall , "nargout" );

      nargout = (int) mxGetScalar( callback_out[0] );

      nargs = mxGetNumberOfElements( call ) - 1;

      callback_in = (mxArray**) mxCalloc( nargs+3, sizeof(mxArray*) );
      callback_in[0] = tmpcall;
      callback_in[1] = hObj;
      callback_in[2] = eventdata;

      for (j=0;j<nargs;j++) {
	callback_in[3+j] = mxGetCell(call,j+1);
      }


      if ( nargout<=0 ) {
	/* callback function has NO or a VARIABLE number of outputs */
	failure = mexCallMATLAB(0, (mxArray**) NULL, nargs+3, callback_in, "feval");
      } else {
	/* callback function has at least one output */
	failure = mexCallMATLAB(1, callback_out, nargs+3, callback_in,  "feval");
      }

    }
  }


  if (nargout!=0 && !mxIsEmpty(callback_out[0]))
    retval = mxGetScalar( callback_out[0] );
  else
    retval = 1;

  if (callback_in!=NULL)
    mxFree(callback_in);

  return retval;

}
