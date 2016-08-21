#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>

/* find value in sorted vector and return interpolated index */

double bsearchi( double *vector, int32_t nmemb, double key ) {
    
    int32_t left = 0;
    int32_t right = nmemb-1;
    int32_t mid;
    
    while (left <= right) {
        mid = floor( (left+right)/2 );
        
        if (vector[mid] == key)
            return (double) mid;
        
        if (vector[mid] > key)
            right = mid-1;
        else
            left  = mid+1;
    }
    
    if ( (left > (nmemb-1) ) || (right<0) ) {
        return -1;
    }
    else {
        return right + (key-vector[right]) / (vector[left]-vector[right]);
    }
    
}

/* main matab function */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
 
    /* b = fast_inseg( seg, t ) */
    
    /* current t in current seg? start while block until out of seg, then next seg
     * current t before seg start? binsearch for next t in seg, start while block, next seg
     * current t after seg end? go to next seg
     */
    
    double *seg, *t;
    mxLogical *pout;
    
    int s, current_t, idx;
    int nseg, nt;
    
    if (nrhs!=2)
        mexErrMsgIdAndTxt("fast_inseg:invalidArguments", "Expecting two arguments");
    
    if ( mxGetNumberOfDimensions(prhs[0])!=2 || mxGetN(prhs[0])!=2 )
        mexErrMsgIdAndTxt("fast_inseg:invalidArguments", "Invalid segments");
    
    seg = mxGetPr( prhs[0] );
    t = mxGetPr( prhs[1] );
    
    nseg = mxGetM( prhs[0] );
    nt = mxGetNumberOfElements(prhs[1]);
    
    plhs[0] = mxCreateLogicalMatrix( nt, 1 );
    
    if (nseg==0 || nt==0)
        return;
    
    pout = mxGetLogicals( plhs[0] );

    current_t = 0;
    
    for (s=0; s<nseg; s++) {
     
        if ( t[current_t]<seg[s] ) {
            /* binsearch for next t in seg */
             idx = (int) ceil( bsearchi( &(t[current_t]), nt-current_t, seg[s] ) );
             if (idx==-1)
                 break;
             current_t += idx;
        } else if ( t[current_t]>seg[s+nseg] ) {
            continue;
        }
        
        while ( t[current_t]<=seg[s+nseg] && current_t<nt ) {
            pout[current_t] = 1;
            current_t++;
        }
     
        if (current_t>=nt)
            break;
                
    }
    
}