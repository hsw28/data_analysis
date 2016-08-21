#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>

/* find value in sorted vector and return interpolated index */

double bsearchi( double *vector, long nmemb, double key )
{

long left = 0;
long right = nmemb-1;
long mid;

while (left <= right)
{
    mid = floor( (left+right)/2 );
    
    if (vector[mid] == key)
        return (double) mid;
    
    if (vector[mid] > key)
      right = mid-1;
    else
      left  = mid+1;
}

if ( (left > (nmemb-1) ) || (right<0) )
{
  return -1;
}
else
{
  return right + (key-vector[right]) / (vector[left]-vector[right]);
}

}

/* main matab function */
void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{

  double lag_min;
  double lag_max;
  double *pref;
  double *pevent;
  double *pseg;
  long nref, nevent, nseg;
  long est_n_events;
  mxArray *out1, *out2;
  double *pout1, *pout2, *p;;
  long n, event_i;
  long k,l, i;
  long i1, i2;
  char event_i_set = 0;
  int return_indices, biased;
  double nan;
  int isseg=0;

  /* call as eventcorr( reference_event, event, lag_min, lag_max, segments, return_indices ) */

  /* reference_event is a vector of event times */
  /* event is a vector of event times (if [], then event=reference_event) */
  /* lag_min, lag_max are the minimum and maximum lag ( -Inf < lag < Inf ) */
  /* segments is a nx2 array of segment start and end times (by default [-Inf Inf]) */
  /* return_indices: 0/1 (default = 0) */

  /* the function returns a vector of the relative times of all spikes in event surrounding the reference events */
  /* or, if return_indices=1, the indices of all the spikes surrounding the reference events are returned */
  /* optionally, the function returns a vector containing the number of relative times for each reference event */

  /* check input arguments */
  if (nrhs<4 || nrhs>7)
    mexErrMsgIdAndTxt("eventcorr:invalidArguments", "Expecting at leat 4 and at most 7 arguments.");
  else
    {
      if ( (mxGetNumberOfElements( prhs[2] ) !=1) || (mxGetNumberOfElements( prhs[3] ) !=1 ) )
	{ 
	  mexErrMsgIdAndTxt("eventcorr:invalidArguments", "Invalid minimal and maximal lag values.");
	}
      else
	{
	  /* get minimum and maximum lags */
	  lag_min = mxGetScalar( prhs[2] );
	  lag_max = mxGetScalar( prhs[3] );
	}

      /* get pointer to reference events  */
      pref = mxGetPr( prhs[0] );
      /* get number of reference events */
      nref = mxGetNumberOfElements( prhs[0] );

      if (mxIsEmpty( prhs[1] ))
	{
	  /* use reference events as target events*/
	  pevent = pref;
	  nevent = nref;
	  isseg = 0;
	}
      else
	{
	  /* get pointer to target events/segments */
	  pevent = mxGetPr( prhs[1] );
	  /* get number of target events/segments */
	  nevent = mxGetM( prhs[1] );
	  /*events or segments? */
	  if (mxGetN( prhs[1] )>1)
	    isseg = 1;
	}

      /* mexPrintf("nevent: %d, isseg: %d\n",nevent,isseg); */

      if (nrhs<5 || mxIsEmpty( prhs[4]) )
	{
	  nseg = 1;
	  pseg = (double*) mxCalloc( 2, sizeof(double) );
	  pseg[0] = -mxGetInf();
	  pseg[1] = mxGetInf();
	}
      else if ( (mxGetN( prhs[4] )!=2) || (mxGetM( prhs[4] )==0) )
	{
	  mexErrMsgIdAndTxt("eventcorr:invalidArguments", "Invalid segment matrix.");
	}
      else
	{
	  nseg = mxGetM( prhs[4] );
	  pseg = mxGetPr( prhs[4] );
	}

      if (nrhs<6 || mxIsEmpty( prhs[5] ) )
	return_indices = 0;
      else
	return_indices = (int) mxGetScalar( prhs[5] );

      if (nrhs<7 || mxIsEmpty( prhs[6] ) )
	biased = 0;
      else
	biased = (int) mxGetScalar( prhs[6] );

    }

  /* mexPrintf("nseg: %d\n", nseg); */

  /* estimate final output size */
  est_n_events = nref * (lag_max-lag_min) * nevent / (pevent[nevent-1]-pevent[0]) + 100;
  /*  mexPrintf("est_n_events: %ld\n", est_n_events);*/

  /* create arrays */
  if (return_indices==1 || isseg==0)
    pout1 = (double*) mxCalloc( est_n_events , sizeof(double) );
  else
    pout1 = (double*) mxCalloc( est_n_events*2 , sizeof(double) );
    
  /* create output matrix for number of events surrounding each trigger */
  out2 = mxCreateDoubleMatrix( nref, 1, mxREAL );
  pout2 = mxGetPr( out2 );

  /* populate out2 with NaNs */
  nan = mxGetNaN();
  for( l=0; l<nref; l++ ) {
    pout2[l] = nan;
  }

  n = 0;
  event_i = 0;

  /* for each segment ... */
  for (k=0; k<nseg; k++ )
    {

      /* mexPrintf( "k: %d, seg: %f %f\n", k, pseg[k], pseg[k+nseg] ); */

      /* check whether segment and reference event overlap  */
      if ( ( pseg[k] > pref[nref-1] ) || ( pseg[k+nseg] < pref[0] ) )
	continue;

      /* check segment edges  */
      if ( mxIsInf( pseg[k] ) || ( pseg[k] < pref[0] ) )
	pseg[k] = pref[0];

      if ( mxIsInf( pseg[k+nseg] ) || ( pseg[k+nseg] > pref[nref-1] ) )
	pseg[k+1] = pref[nref-1];

      /* find first and last ref index inside segment */
      /* unbiased */
      if (biased==1) {
	i1 = (long) ceil( bsearchi( pref, nref, pseg[k] ) );
	i2 = (long) floor( bsearchi( pref, nref, pseg[k+nseg] ) );
      } else {	
	i1 = (long) ceil( bsearchi( pref, nref, pseg[k]-lag_min ) );
	i2 = (long) floor( bsearchi( pref, nref, pseg[k+nseg]-lag_max ) );
      }

      /* mexPrintf( "i1: %ld, i2: %ld, biased: %d\n", i1, i2, biased ); */

      if (isseg==0) {
	/* for each reference spike in this segment ... */
	for ( l=i1; l<=i2; l++ )
	  {
	    pout2[l]=0;
	    /* find all events lag_min<=(spike - ref)<=lag_max */
	    i = event_i;
	    event_i_set = 0;
	    while ( (i<nevent) && (pevent[i] <= pref[l]+lag_max) )
	      {
		
		if ( pevent[i]>=pref[l]+lag_min )
		  {
		    pout2[l]++;
		    
		    if (return_indices)
		      pout1[n] = (double) i+1;
		    else
		      pout1[n] = (double) (pevent[i]-pref[l]);
		    
		    n++;
		    
		    if (event_i_set==0)
		      {
			event_i_set = 1;
			event_i = i;
		      }
		    
		    
		    if (n>=est_n_events)
		      {
			/* reallocate array */
			est_n_events=est_n_events+1000;
			pout1 = mxRealloc( pout1, sizeof(double) * est_n_events );
			if (pout1==NULL)
			  mexErrMsgIdAndTxt("eventcorr:internalError", "Internal reallocation error");
			
		      }
		    
		  }
		
		i++;
		
	      }
	    
	  }
      } else {
	
	/* for each reference spike in this segment ... */
	for ( l=i1; l<=i2; l++ )
	  {
	    pout2[l]=0;

	    /* find all segments for which one of the following conditions is true:
	       lag_min<=(segment start - ref)<=lag_max
	       lag_min<=(segment end - ref)<=lag_max
	       segment start < ref && segment_end > ref
	    */
	    i = event_i;
	    event_i_set = 0;

	    /* mexPrintf("l=%d, i=%d\n",l,i); */

	    while (i<nevent) 
	      {
		
		if ( !( pevent[i] > pref[l]+lag_max || pevent[i+nevent] < pref[l]+lag_min ) )
		  {
		    pout2[l]++;
		    
		    if (return_indices) {
		      pout1[n] = (double) i+1;
		    } else {
		      pout1[n*2] = (double) (pevent[i]-pref[l]);
		      pout1[n*2+1] = (double) (pevent[i+nevent]-pref[l]);
		    }
		    
		    n++;
		    
		    if (event_i_set==0)
		      {
			event_i_set = 1;
			event_i = i;
		      }
		    
		    
		    if (n>=est_n_events)
		      {
			/* reallocate array */
			est_n_events=est_n_events+1000;
			if (return_indices==1 || isseg==0)
			  pout1 = mxRealloc( pout1, sizeof(double) * est_n_events );
			else
			  pout1 = mxRealloc( pout1, sizeof(double) * est_n_events * 2 );

			if (pout1==NULL)
			  mexErrMsgIdAndTxt("eventcorr:internalError", "Internal reallocation error");
			
		      }
		    
		  }
		
		i++;
		
	      }
	    
	  }
      }

    }

  if (nlhs>0)
    {
      /* reallocate */
      if (return_indices==1 || isseg==0) {
	out1 = mxCreateDoubleMatrix(n,1,mxREAL);
	pout1 = mxRealloc( pout1, sizeof(double) * n );
      } else {
	out1 = mxCreateDoubleMatrix(2,n,mxREAL);
	pout1 = mxRealloc( pout1, sizeof(double) * n * 2 );
      }


      if ( (pout1==NULL) && (n>0) )
	mexErrMsgIdAndTxt("eventcorr:internalError", "Internal reallocation error");
      mxSetPr(out1, pout1);
      plhs[0] = out1;
    }
  if (nlhs>1)
    plhs[1] = out2;

}

