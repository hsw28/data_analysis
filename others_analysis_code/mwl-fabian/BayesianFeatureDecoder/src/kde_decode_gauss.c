#include "mex.h"
#include <math.h>

#define MAX(A,B) A>=B?A:B

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    
    /* description:
     * given a set of reference stimuli and responses (forming a joint distribution),
     * this function will compute the log kernel density estimate over a grid of stimuli
     * for a set of test responses. A gaussian kernel is used for all dimensions
     * and the data is assumed to be normalized by the desired kernel width.
     *
     * syntax:
     * out = kde_decode_gauss( stimulus, stimulus_grid, response, test_response[, offset[, distance[, timestamp, bins]]] );
     *
     * arguments:
     * stimulus = number of spikes x number of stimulus dimensions
     * stimulus_grid = number of grid elements x number of stimulus dimensions
     * response = number of spikes x number of response dimensions
     * test_response = number of test spikes x number of response dimensions
     * offset = number of grid elements
     * distance = optional matrix of distances. If this argument is present (and not empty), the stimulus and stimulus_grid arguments should be given as a zero-based index into the distance matrix.
     * timestamp = number of test spikes x 1
     * bins = number of bins x 2
     *
     * out = number of test spikes x number of stimulus grid elements (if no timestamps and bins arguments are provided)
     * out = number of bins x number of stimulus grid elements (if timestamps and bins arguments are provided)
     *
     */
    
    double cutoff = 4;      /* cut-off (in standard deviations) for gaussian kernel */
    
    static const double pi = 3.141592653589793238462643383279502884197;
    
    /* INPUTS */
    double *stimulus;              /* NxQ */
    double *stimulus_grid;         /* GxQ */
    double *response;              /* NxD or Nx0 or empty*/
    double *test_response;         /* MxD or Mx0 or empty*/
    double *timestamp;
    double *bins;
    double *offset;
    
    /* VARIABLES */
    int N, D, M, Q, G, B;
    int n, d, m, q, g, b;
    int sizeM, loopM;
    int next_idx, idx;
    double acc_a, *acc_g, *skip_g, *z;
    double tmp;
    double *pout, *pout2;
    mxArray *out, *out2;
    int idx1, idx2;
    
    mxArray *tmpmat;
    int *use_distance_lookup;
    int *NI;
    double **distance;
    
    double scaling_factor = 1;
    double c1, c2;
    
    /* CHECK NUMBER OF INPUTS */
    if (nrhs<2)
        mexErrMsgTxt("This function requires at least two input arguments");
    
    /* CHECK DIMENSIONS OF FIRST TWO ARGUMENTS */
    if ( mxGetNumberOfDimensions(prhs[0])!=2 || mxGetNumberOfDimensions(prhs[1])!=2)
        mexErrMsgTxt("stimulus and stimulus_grid input arguments need to be matrices");
    
    /* GET POINTERS TO FIRST TWO ARGUMENTS */
    stimulus = mxGetPr( prhs[0] );
    stimulus_grid = mxGetPr( prhs[1] );

    /* GET ARRAY SIZES */
    N = mxGetM( prhs[0] );  /* number of source (encoding) spikes */
    Q = mxGetN( prhs[0] );  /* number of stimulus dimensions */
    G = mxGetM( prhs[1] );  /* number of points in stimulus grid */

    /* CHECK NUMBER OF DIMENSIONS IN STIMULUS GRID */
    if (mxGetN(prhs[1])!=Q)
        mexErrMsgTxt("Incompatible size of stimulus_grid input arguments");
        
    /* CHECK OPTIONAL INPUTS */
    if (nrhs>2) {
        /* CHECK DIMENSIONALITY OF SPIKE RESPONSE (ENCODING)*/
        if ( mxGetNumberOfDimensions(prhs[2])!=2 )
            mexErrMsgTxt("Response input argument needs to be a matrix");
        response = mxGetPr( prhs[2] );
        D = mxGetN( prhs[2] );  /* number of response dimensions */
        /* CHECK NUMBER OF SPIKES IN RESPONSE */
        if ( (D>0 && mxGetM(prhs[2])!=N ) )
            mexErrMsgTxt("Incompatible size of response input argument");
    } else {
        D = 0;
    }
        
    if (nrhs>3) {
        /* CHECK DIMENSIONALITY OF TEST RESPONSE (DECODING)*/
        if ( mxGetNumberOfDimensions(prhs[3])!=2 )
            mexErrMsgTxt("Test_response input argument needs to be a matrix");
        test_response = mxGetPr( prhs[3] );
        M = mxGetM( prhs[3] );  /* number of test (decoding) spikes */
        /* CHECK NUMBER OF DIMENSIONS IN TEST RESPONSE */
        if ( mxGetN(prhs[3])!=D )
            mexErrMsgTxt("Incompatible size of test_response input argument");
    } else {
        M = 0; /* no test spikes specified */
    }
    
    if (D==0 && M==0 )
        M = 1;

    if (nrhs>4) {
        /* CHECK SIZE OF OFFSET VECTOR */
        if ( !mxIsDouble( prhs[4] ) || mxGetNumberOfElements( prhs[4] )!=G )
            mexErrMsgTxt("Incompatible size of offset vector");
        offset = mxGetPr( prhs[4] );
    } else {
        mexErrMsgTxt("Please provide offset vector");
    }
    
    /* ALLOCATE ARRAYS FOR DISTANCE LOOK-UP TABLES */
    use_distance_lookup = (int*) mxCalloc( Q, sizeof(int) );
    distance = (double**) mxCalloc( Q, sizeof(double*) );
    NI = (int*) mxCalloc( Q, sizeof(int) );
    /* INITIALIZE ARRAY */
    for (q=0;q<Q;q++)
        use_distance_lookup[q] = 0;
    
    if (nrhs>5) {
        /* CHECK CLASS AND SIZE OF DISTANCE LUTs */
        if ( !mxIsCell( prhs[5] ) || mxGetNumberOfElements( prhs[5] )!=Q )
            mexErrMsgTxt("Distance input argument needs to be a cell array with as many cells as stimulus dimensions");
        
        for ( q=0 ; q<Q ; q++ ) {
            tmpmat = mxGetCell( prhs[5], q );
            if (tmpmat==NULL || mxIsEmpty(tmpmat)) {
                use_distance_lookup[q] = 0;
            } else {
                /* CHECK SIZE OF DISTANCE LUT */
                if ( mxGetNumberOfDimensions(tmpmat)!=2 || mxGetM( tmpmat )!=mxGetN( tmpmat ) ) 
                    mexErrMsgTxt("Distance arrays need to be square matrices");
                distance[q] = (double*) mxGetPr( tmpmat );
                NI[q] = mxGetM( tmpmat );
                use_distance_lookup[q] = true;
                /* when using distance LUT, the corresponding stimulus and stimulus grid should be indices into the LUT */
                /* CHECK IF STIMULUS AND STIMULUS_GRID >=0 && <NI[q] */
                for ( n=0; n<N; n++ ) {
                    if ( stimulus[n+q*N]<0 || stimulus[n+q*N]>=NI[q] )
                        mexErrMsgTxt("Invalid index");
                }
                for ( g=0; g<G; g++ ) {
                    if ( stimulus_grid[g+q*G]<0 || stimulus_grid[g+q*G]>=NI[q] )
                        mexErrMsgTxt("Invalid index");
                }
            }
            
        }
    }

    B = 0;  /* number of time bins */
    
    if (nrhs>6) {
        /* CHECK DIMENSIONALITY OF TEST (DECODING) SPIKE TIMESTAMPS */
        if ( mxGetNumberOfDimensions(prhs[6])!=2 )
            mexErrMsgTxt("Timestamp input argument needs to be a matrix");
        timestamp = mxGetPr( prhs[6] );
        /* CHECK SIZE OF TEST (DECODING) SPIKE TIMESTAMPS */
        if ( mxGetM( prhs[6] )!=M || mxGetN( prhs[6] )!=1 )
            mexErrMsgTxt("Incompatible size of timestamp input argument");
    }
    
    if (nrhs>7) {
        /* CHECK DIMENSIONALITY AND SIZE OF TIME BINS ARGUMENT */
        if ( mxGetNumberOfDimensions(prhs[7])!=2 || mxGetN(prhs[7])!=2)
            mexErrMsgTxt("Bins input argument needs to be a Bx2 matrix");
        B = mxGetM( prhs[7] );  /* number of time bins */
        bins = mxGetPr( prhs[7] );
    }
    
    
    cutoff *= cutoff; /* transform gaussian kernel cut-off to variance*/
    
    /* COMPUTE SCALING FACTOR */
    
    scaling_factor *= pow(2*pi,-0.5*((double)(D+Q)));
    
    /* ALLOCATE TEMPORARY ARRAYS AND OUTPUT ARRAYS */
    acc_g  = (double*) mxCalloc( G, sizeof(double) );
    skip_g = (double*) mxCalloc( G, sizeof(double) );
    
    if (B==0) {
        out = mxCreateDoubleMatrix( M, G, mxREAL );
        z = mxGetPr( out );
    } else {
        if (D==0) {
            z = (double*) mxCalloc( G, sizeof(double) );
        } else {
            z = (double*) mxCalloc( M*G, sizeof(double) );
        }
        out = mxCreateDoubleMatrix( B, G, mxREAL );
        pout = mxGetPr( out );
        
        out2 = mxCreateDoubleMatrix( B, 1, mxREAL );
        pout2 = mxGetPr( out2 );
    }
    
    loopM = sizeM = M;
    if (D==0) {
        loopM = 1;
        if (B>0)
            sizeM = 1;
    }

    
    /* COMPUTE KDE */
    
    /* LOOP THROUGH SOURCE (ENCODING) SPIKES */
    for ( n=0; n<N; n++ ) {
        
        for ( g=0; g<G; g++ ) {
            
            /* INITIALIZE ACCUMULATORS */
            acc_g[g] = 0;
            skip_g[g] = 0;
            
            /* INITIALIZE INDICES */
            idx1 = g;
            idx2 = n;
            
            /* LOOP THROUGH STIMULUS DIMENSIONS */
            for ( q=0; q<Q; q++ ) {
                
                if (use_distance_lookup[q]) {
                    tmp = distance[q][ ((int) stimulus_grid[idx1])*NI[q] + (int)stimulus[idx2] ];
                } else {
                    tmp = (stimulus_grid[idx1]-stimulus[idx2]);
                }
                    
                tmp *= tmp;
                acc_g[g] += tmp;
                
                if (acc_g[g]>cutoff) {
                    skip_g[g] = 1;
                    break;
                }
                
                /* UPDATE INDICES */
                idx1 += G;
                idx2 += N;

            }
            
        }
        
        /* LOOP THROUGH TEST (DECODING) SPIKES */
        for ( m=0; m<loopM; m++ ) {
            
            /* INITIALIZE ACCUMULATORS */
            acc_a = 0;
            
            /* INTIALIZE INDICES */
            idx1 = m;
            idx2 = n;
            
            /* LOOP THROUGH RESPONSE DIMENSIONS */
            for ( d=0; d<D; d++ ) {
                
                tmp = (test_response[idx1]-response[idx2]);
                tmp *= tmp;
                acc_a += tmp;
                
                if (acc_a>cutoff) {
                    goto nextm;
                }
                
                /* UPDATE INDICES */
                idx1 += sizeM;
                idx2 += N;
                
            }
            
            
            for ( g=0; g<G; g++ ) {
                
                if (skip_g[g] || (acc_g[g]+acc_a)>cutoff )
                    continue;
                
                z[m+g*sizeM] += exp( -0.5*(acc_g[g]+acc_a) );
                
            }                
            
            nextm:
                ;
        
        }
        
    }
    
    mxFree(acc_g);
    mxFree(skip_g);
    
    /* compute log */
    c1 = log(scaling_factor) - log((double)N);
    if (B==0 && D==0) {
        for (g=0;g<G;g++)
            z[g*sizeM]= log( z[g*sizeM] + offset[g]*(double)N/scaling_factor) + c1;
    } else {
        for (g=0; g<G; g++) {
            idx = g*loopM;
            c2 = offset[g]*(double)N/scaling_factor;
            for (m=0; m<loopM ; m++ )
                z[m+idx] = log( z[m+idx] + c2) + c1;
        }
    }
    
    if (D==0 && B==0) { /* copy */
        for (g=0; g<G; g++) {
            idx = g*sizeM;
            for (m=1; m<sizeM ; m++ )
                z[m+idx] = z[idx];
        }
    }

    /* for each bin, compute sum of log(p) for all spikes in that bin */
    if (B>0) {
        
        next_idx = 0;
    
        for (b=0; b<B; b++) {
     
            while (next_idx<M && (timestamp[next_idx]<bins[b]))
                next_idx++;
        
            idx = next_idx;
            while (idx<M && (timestamp[idx]<bins[b+B])) {
            
                if (D>0) {
                    for (g=0; g<G; g++)
                        pout[b+g*B] += z[idx+g*M];
                }
            
                pout2[b]++; /* count number spikes in bin */
                
                idx++;
            }
        
            if (D==0) {
                for (g=0; g<G; g++) {
                    pout[b+g*B] = pout2[b] * z[g*sizeM];
                }
            }
                
        }
        
        mxFree(z);
        
    }
    
    plhs[0] = out;
    plhs[1] = out2;
    
}