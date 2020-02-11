#include "mex.h"
#include <math.h>

#define MAX(A,B) A>=B?A:B

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    
    /* description:
     * given a set of reference stimuli and responses (forming a joint distribution),
     * this function will compute the log kernel density estimate over a grid of stimuli
     * for a set of test responses. Within kernel types a radial-symmetric kernel is used. Different kernels are combined multiplicatively.
     *
     * syntax:
     * out = kde_decode_general( stimulus, stimulus_grid, stimulus_kernel, stimulus_bandwidth, response, response_kernel, response_bandwidth, test_response[, offset[, distance[, timestamp, bins]]] );
     *
     * arguments:
     * stimulus = number of spikes x number of stimulus dimensions
     * stimulus_grid = number of grid elements x number of stimulus dimensions
     * stimulus_kernel = 1 x number of stimulus dimensions
     * stimulus_bandwidth = 1 x number of stimulus dimensions
     * response = number of spikes x number of response dimensions
     * response_kernel = 1 x number of response_dimensions
     * response_bandwidth = 1 x number of response dimensions
     * test_response = number of test spikes x number of response dimensions
     * offset = number of grid elements
     * distance = optional matrix of distances. If this argument is present (and not empty), the stimulus and stimulus_grid arguments should be given as a zero-based index into the distance matrix.
     * timestamp = number of test spikes x 1
     * bins = number of bins x 2
     *
     * out = number of test spikes x number of stimulus grid elements (if no timestamps and bins arguments are provided)
     * out = number of bins x number of stimulus grid elements (if timestamps and bins arguments are provided)
     *
     * kernels:
     * 0 = gaussian
     * 1 = epanechnikov
     * 2 = von mises
     * 3 = kronecker
     *
     */
    
    double cutoff = 2;             /* cut-off (in standard deviations) for gaussian kernel */
    double vm_cutoff = 0.1;        /* cut-off (probability) for von mises kernel */
    
    static const double pi = 3.141592653589793238462643383279502884197;
    
    /* INPUTS */
    double *stimulus;              /* NxQ */
    double *stimulus_grid;         /* GxQ */
    double *stimulus_kernel;       /* 1xQ */
    double *stimulus_bandwidth;    /* 1xQ */    
    double *response;              /* NxD or Nx0 or empty*/
    double *response_kernel;       /* 1xD */
    double *response_bandwidth;    /* 1xD */
    double *test_response;         /* MxD or Mx0 or empty*/
    double *timestamp;
    double *bins;
    double *stimulus_vonmises;
    double *response_vonmises;
    double *offset;
    
    /* VARIABLES */
    int N, D, M, Q, G, B;
    int n, d, m, q, g, b;
    int sizeM, loopM;
    int next_idx, idx;
    double *skip_g, *z;
    double acc_a_gauss, acc_a_epa, acc_a_delta, acc_a_vm;
    double *acc_g_gauss, *acc_g_epa, *acc_g_delta, *acc_g_vm;
    double tmp;
    double *pout, *pout2;
    mxArray *out, *out2;
    int idx1, idx2;
    
    mxArray *tmpmat;
    int *use_distance_lookup;
    int *NI;
    double **distance;

    int ngauss = 0;
    int nepa = 0;
    int nmises = 0;
    int nkron = 0;
    
    double scaling_factor = 1;
    double v;
    double c1, c2;
    
    mxArray *argout=NULL, *argin[2];
    double *pargin1;
    double *pargin2;

    
    /* CHECK NUMBER OF INPUTS */
    if (nrhs<4)
        mexErrMsgTxt("This function requires at least four input arguments");
    
    /* CHECK DIMENSIONS OF FIRST TWO ARGUMENTS */
    if ( mxGetNumberOfDimensions(prhs[0])!=2 || mxGetNumberOfDimensions(prhs[1])!=2)
        mexErrMsgTxt("stimulus and stimulus_grid input arguments need to be matrices");
    
    /* GET POINTERS TO FIRST FOUR ARGUMENTS */
    stimulus = mxGetPr( prhs[0] );
    stimulus_grid = mxGetPr( prhs[1] );
    stimulus_kernel = mxGetPr( prhs[2] );
    stimulus_bandwidth = mxGetPr( prhs[3] );

    /* GET ARRAY SIZES */
    N = mxGetM( prhs[0] );  /* number of source (encoding) spikes */
    Q = mxGetN( prhs[0] );  /* number of stimulus dimensions */
    G = mxGetM( prhs[1] );  /* number of points in stimulus grid */

    /* CHECK NUMBER OF DIMENSIONS IN STIMULUS GRID */
    if (mxGetN(prhs[1])!=Q)
        mexErrMsgTxt("Incompatible size of stimulus_grid input arguments");

    /* CHECK NUMBER OF STIMULUS KERNELS AND BANDWIDTHS */
    if (mxGetNumberOfElements(prhs[2])!=Q || mxGetNumberOfElements(prhs[3])!=Q)
        mexErrMsgTxt("Incompatible size of stimulus kernel and/or bandwidth arguments");
    
    
    /* CHECK OPTIONAL INPUTS */
    /* CHECK IF EITHER NO RESPONSE, OR RESPONSE + KERNEL + BANDWIDTH IS SPECIFIED */
    if (nrhs>5 && nrhs<7)
        mexErrMsgTxt("Specify response, response kernel and bandwidth arguments");
    
    if (nrhs>6) {
        /* CHECK DIMENSIONALITY OF SPIKE RESPONSE (ENCODING)*/
        if ( mxGetNumberOfDimensions(prhs[4])!=2 )
            mexErrMsgTxt("Response input argument needs to be a matrix");
        response = mxGetPr( prhs[4] );
        D = mxGetN( prhs[4] );  /* number of response dimensions */
        /* CHECK NUMBER OF SPIKES IN RESPONSE */
        if ( (D>0 && mxGetM(prhs[4])!=N ) )
            mexErrMsgTxt("Incompatible size of response input argument");
        response_kernel = mxGetPr( prhs[5] );
        response_bandwidth = mxGetPr( prhs[6] );
        /* CHECK NUMBER OF RESPONSE KERNELS AND BANDWIDTHS */
        if (mxGetNumberOfElements(prhs[5])!=D || mxGetNumberOfElements(prhs[6])!=D)
            mexErrMsgTxt("Incompatible size of response kernel and/or bandwidth arguments");
        
    } else {
        D = 0;  /* no response specified */
    }
        
    if (nrhs>7) {
        /* CHECK DIMENSIONALITY OF TEST RESPONSE (DECODING)*/
        if ( mxGetNumberOfDimensions(prhs[7])!=2 )
            mexErrMsgTxt("Test_response input argument needs to be a matrix");
        test_response = mxGetPr( prhs[7] );
        M = mxGetM( prhs[7] );  /* number of test (decoding) spikes */
        /* CHECK NUMBER OF DIMENSIONS IN TEST RESPONSE */
        if ( mxGetN(prhs[7])!=D )
            mexErrMsgTxt("Incompatible size of test_response input argument");
    } else {
        M = 0; /* no test spikes specified */
    }
    
    if ( D==0 && M==0 )
        M = 1;

    if (nrhs>8) {
        /* CHECK SIZE OF OFFSET VECTOR */
         if ( !mxIsDouble( prhs[8] ) || mxGetNumberOfElements( prhs[8] )!=G )
             mexErrMsgTxt("Incompatible size of offset vector");
        offset = mxGetPr( prhs[8] );
    } else {
        mexErrMsgTxt("Please provide offset vector");
    }    
    
    /* ALLOCATE ARRAYS FOR DISTANCE LOOK-UP TABLES */
    use_distance_lookup = (int*) mxCalloc( Q, sizeof(int) );
    distance = (double**) mxCalloc( Q, sizeof(double*) );
    NI = (int*) mxCalloc( Q, sizeof(int) ); /* size of distance LUTs */
    /* INITIALIZE ARRAY */
    for (q=0;q<Q;q++)
        use_distance_lookup[q] = 0;
    
    if (nrhs>9) {
        /* CHECK CLASS AND SIZE OF DISTANCE LUTs */
        if ( !mxIsCell( prhs[9] ) || mxGetNumberOfElements( prhs[9] )!=Q )
            mexErrMsgTxt("Distance input argument needs to be a cell array with as many cells as stimulus dimensions");
        
        for ( q=0 ; q<Q ; q++ ) {
            tmpmat = mxGetCell( prhs[9], q );
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
    
    B = 0; /* number of time bins */
    
    if (nrhs>10) {
        /* CHECK DIMENSIONALITY OF TEST (DECODING) SPIKE TIMESTAMPS */
        if ( mxGetNumberOfDimensions(prhs[10])!=2 )
            mexErrMsgTxt("Timestamp input argument needs to be a matrix");
        timestamp = mxGetPr( prhs[10] );
        /* CHECK SIZE OF TEST (DECODING) SPIKE TIMESTAMPS */        
        if ( mxGetM( prhs[10] )!=M || mxGetN( prhs[10] )!=1 )
            mexErrMsgTxt("Incompatible size of timestamp input argument");
    }
    
    if (nrhs>11) {
        /* CHECK DIMENSIONALITY AND SIZE OF TIME BINS ARGUMENT */
        if ( mxGetNumberOfDimensions(prhs[11])!=2 || mxGetN(prhs[11])!=2)
            mexErrMsgTxt("Bins input argument needs to be a Bx2 matrix");
        B = mxGetM( prhs[11] ); /* number of time bins */
        bins = mxGetPr( prhs[11] );
    }
    
    cutoff *= cutoff; /* transform gaussian kernel cut-off to variance*/
    
    /* COMPUTE CUT-OFFS FOR VON MISES KERNELS */
    /* AND COUNT NUMBER OF DIMENSIONS WITH GAUSSIAN/EPANECHNIKOV/KRONECKER/VONMISES KERNELS */
    stimulus_vonmises = (double*) mxCalloc( Q, sizeof(double) );
    response_vonmises = (double*) mxCalloc( D, sizeof(double) );
    
    
    argin[0] = mxCreateDoubleScalar(0);
    argin[1] = mxCreateDoubleScalar(0);
    pargin1 = mxGetPr(argin[0]);
    pargin2 = mxGetPr(argin[1]);

    for (q=0; q<Q; q++) {
        if (stimulus_kernel[q]==0) {
            ngauss++;
        } else if (stimulus_kernel[q]==1) {
            nepa++;
        } else if (stimulus_kernel[q]==2) {
            nmises++;
            pargin2[0] = stimulus_bandwidth[q];
            mexCallMATLAB(1, &argout, 2, argin, "besseli");
            stimulus_vonmises[q] = acos( log( vm_cutoff * 2*pi * mxGetScalar(argout) ) / stimulus_bandwidth[q] );
            scaling_factor /= mxGetScalar(argout); 
        } else {
            nkron++;
        }
    }
    for (d=0; d<D; d++) {
        if (response_kernel[d]==0) {
            ngauss++;
        } else if (response_kernel[d]==1) {
            nepa++;
        } else if (response_kernel[d]==2) {
            nmises++;
            pargin2[0] = response_bandwidth[d];
            mexCallMATLAB(1, &argout, 2, argin, "besseli");
            response_vonmises[d] = acos( log( vm_cutoff * 2*pi * mxGetScalar(argout) ) / response_bandwidth[d] );
            scaling_factor /= mxGetScalar(argout);
        } else {
            nkron++;
        }
    }
          
    /* COMPUTE SCALING FACTOR */
              
    if (ngauss>0)
        scaling_factor *= pow(2*pi,-((double)ngauss)/2);
    if (nepa>0) {
        /* compute volume of hypersphere */
        pargin1[0] = ((double)nepa)/2 + 1; 
        mexCallMATLAB(1, &argout, 1, argin, "gamma" );
        v = pow(pi,0.5*(double)(nepa))/mxGetScalar(argout);
        scaling_factor *= 0.5*(double)(nepa+2)/v;
    }
    if (nmises>0) {
        scaling_factor /= pow(2*pi,(double)nmises);
    }
    if (nkron>0) {
        /* compute volume of hypersphere */
        pargin1[0] = ((double)nkron)/2 + 1; 
        mexCallMATLAB(1, &argout, 1, argin, "gamma" );
        v = pow(pi,((double)nkron)/2)/mxGetScalar(argout);
        scaling_factor /= v; 
    }
      
    /* ALLOCATE TEMPORARY ARRAYS AND OUTPUT ARRAYS */
    acc_g_gauss  = (double*) mxCalloc( G, sizeof(double) );
    acc_g_epa  = (double*) mxCalloc( G, sizeof(double) );
    acc_g_delta  = (double*) mxCalloc( G, sizeof(double) );
    acc_g_vm  = (double*) mxCalloc( G, sizeof(double) );
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
        
        /* LOOP THROUGH STIMULUS GRID */
        for ( g=0; g<G; g++ ) {
            
            /* INITIALIZE ACCUMULATORS */
            acc_g_gauss[g] = 0;
            acc_g_epa[g] = 0;
            acc_g_delta[g] = 0;
            acc_g_vm[g] = 0;
            skip_g[g] = 0;
            
            /* INITIALIZE INDICES */
            idx1 = g;
            idx2 = n;
            
            /* LOOP THROUGH STIMULUS DIMENSIONS */
            for ( q=0; q<Q; q++ ) {
                
                /* GAUSSIAN KERNEL */
                if (stimulus_kernel[q]==0) {
                    if (use_distance_lookup[q]) {
                        tmp = distance[q][ ((int) stimulus_grid[idx1])*NI[q] + (int)stimulus[idx2] ];
                    } else {
                        tmp = (stimulus_grid[idx1]-stimulus[idx2]);
                    }

                    acc_g_gauss[g] += tmp*tmp;
                    
                    if (acc_g_gauss[g]>cutoff) {
                        skip_g[g] = 1;
                        break;
                    }
                /* EPANECHNIKOV KERNEL */    
                } else if (stimulus_kernel[q]==1) {
                    if (use_distance_lookup[q]) {
                        tmp = distance[q][ ((int) stimulus_grid[idx1])*NI[q] + (int)stimulus[idx2] ];
                    } else {
                        tmp = (stimulus_grid[idx1]-stimulus[idx2]);
                    }

                    acc_g_epa[g]+=tmp*tmp;

                    if (acc_g_epa[g]>1) {
                        skip_g[g] = 1;
                        break;
                    }
                /* VON MISES KERNEL */    
                } else if (stimulus_kernel[q]==2) {
                    if (use_distance_lookup[q]) {
                        tmp = distance[q][ ((int) stimulus_grid[idx1])*NI[q] + (int)stimulus[idx2] ];
                    } else {
                        tmp = fabs(stimulus_grid[idx1]-stimulus[idx2]);
                    }

                    if ( tmp<stimulus_vonmises[q] || tmp>(2*pi-stimulus_vonmises[q]) ) {
                        
                        acc_g_vm[g] += stimulus_bandwidth[q] * cos(tmp);

                    } else {
                        skip_g[g] = 1;
                        break;
                    }
                        
                /* KRONECKER KERNEL */
                } else {
                    if (use_distance_lookup[q]) {
                        tmp = distance[q][ ((int) stimulus_grid[idx1])*NI[q] + (int)stimulus[idx2] ];
                    } else {
                        tmp = (stimulus_grid[idx1]-stimulus[idx2]);
                    }

                    acc_g_delta[g] += tmp*tmp;

                    if (acc_g_delta[g]>1) {
                        skip_g[g] = 1;
                        break;
                    }
                }
                
                /* UPDATE INDICES */
                idx1 += G;
                idx2 += N;

            }
            
        }
        
        /* LOOP THROUGH TEST (DECODING) SPIKES */
        for ( m=0; m<loopM; m++ ) {
            
            /* INITIALIZE ACCUMULATORS */
            acc_a_gauss = 0;
            acc_a_epa   = 0;
            acc_a_delta = 0;
            acc_a_vm    = 0;
            
            /* INTIALIZE INDICES */
            idx1 = m;
            idx2 = n;
            
            /* LOOP THROUGH RESPONSE DIMENSIONS */
            for ( d=0; d<D; d++ ) {
                
                /* GAUSSIAN KERNEL */
                if (response_kernel[d]==0) {

                    tmp = (test_response[idx1]-response[idx2]);
                    acc_a_gauss += tmp*tmp;
                    
                    if (acc_a_gauss>cutoff) {
                        goto nextm;
                    }
                /* EPANECHNIKOV KERNEL */    
                } else if (response_kernel[d]==1) {

                    tmp = (test_response[idx1]-response[idx2]);
                    acc_a_epa += tmp*tmp;

                    if (acc_a_epa>1) {
                        goto nextm;
                    }
                /* VON MISES KERNEL */    
                } else if (response_kernel[d]==2) {

                    tmp = fabs(test_response[idx1]-response[idx2]);

                    if ( tmp<response_vonmises[d] || tmp>(2*pi-response_vonmises[d]) ) {
                        acc_a_vm += response_bandwidth[d] * cos(tmp);
                    } else {
                        goto nextm;
                    }
                /* KRONECKER KERNEL */
                } else {

                    tmp = (test_response[idx1]-response[idx2]);
                    acc_a_delta += tmp*tmp;

                    if (acc_a_delta>1) {
                        goto nextm;
                    }
                }
                
                /* UPDATE INDICES */
                idx1 += sizeM;
                idx2 += N;
                
            }
            
            /* LOOP THROUGH STIMULUS GRID */
            for ( g=0; g<G; g++ ) {
                
                if (skip_g[g] || acc_g_gauss[g]+acc_a_gauss>cutoff || acc_g_epa[g]+acc_a_epa>1 || acc_g_delta[g]+acc_a_delta>1)
                    continue;
                
                z[m+g*sizeM] += exp( -0.5*(acc_g_gauss[g]+acc_a_gauss) + acc_g_vm[g] + acc_a_vm ) * (1-acc_g_epa[g]-acc_a_epa);
                
            }
            
            nextm:
                ;
        
        }
        
    }
    
    mxFree(acc_g_gauss);
    mxFree(acc_g_epa);
    mxFree(acc_g_delta);
    mxFree(acc_g_vm);
    mxFree(skip_g);
    mxFree(stimulus_vonmises);
    mxFree(response_vonmises);
    

    if (argout!=NULL)
        mxDestroyArray(argout);
    
    mxDestroyArray(argin[0]);
    mxDestroyArray(argin[1]);
    
    
    /* compute log */
    c1 = log(scaling_factor) - log((double)N);
    if (B==0 && D==0) {
        for (g=0;g<G;g++)
            z[g*sizeM]=log( z[g*sizeM] + offset[g]*(double)N/scaling_factor ) + c1;
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
            
                pout2[b]++;
                
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