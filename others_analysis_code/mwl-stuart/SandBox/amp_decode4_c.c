#include "mex.h"
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
 
    static const double pi = 3.141592653589793238462643383279502884197;
    
    /* INPUTS */
    double *refamp; /* NxA */
    double *refpos; /* NxX */
    double *testamp; /* MxA */
    double *gridpos; /* GxX */
    double *atype; /* 1xA */
    double *xtype; /* 1xX */
    double *awidth; /* 1xA */
    double *xwidth; /* 1xX */
    
    /* VARIABLES */
    int N,A,X,M,G;
    int n,a,x,m,g;
    int i1,i2;
    
    double acc_a, *acc_g, *skip_g;
    double tmp;
    
    double *pout;
    mxArray *out;
    
    int computed_stim;
    
    /* GET POINTERS TO INPUTS */
    refamp = mxGetPr( prhs[0] );
    refpos = mxGetPr( prhs[1] );
    testamp = mxGetPr( prhs[2] );
    gridpos = mxGetPr( prhs[3] );
    atype = mxGetPr( prhs[4] );
    awidth = mxGetPr( prhs[5] );
    xtype = mxGetPr( prhs[6] );
    xwidth = mxGetPr( prhs[7] );
    
    /* GET ARRAY SIZES */
    N = mxGetM( prhs[0] );
    A = mxGetN( prhs[0] );
    X = mxGetN( prhs[1] );
    M = mxGetM( prhs[2] );
    G = mxGetM( prhs[3] );
    
    /* CREATE TEMP ARRAY */
    acc_g = (double*) mxCalloc( G, sizeof(double) );
    skip_g = (double*) mxCalloc( G, sizeof(double) );
    
    /* CREATE OUTPUT */
    
    out = mxCreateDoubleMatrix( M, G , mxREAL );
    pout = mxGetPr( out );
    
    
    for (n=0;n<N;n++) {
     
        computed_stim = 0;
        
        for (m=0;m<M;m++)  {
         
            acc_a = 0;
            i1=m;
            i2=n;
            for (a=0;a<A;a++) {
             
                /*tmp = (testamp[i1]-refamp[i2])/awidth[a];
                acc_a*= (exp(-0.5*tmp*tmp) / (sqrt(2*pi) * awidth[a]));*/

                /*if (acc_a<0.0001)
                    goto nextm;*/

                if (atype[a]==0) { /* gaussian */
                    tmp = (testamp[i1]-refamp[i2])/awidth[a];
                    tmp *= tmp;
                
                    if (tmp>16)
                        goto nextm;
                
                    tmp *= -0.5;
                } else if (atype[a]==1) { /* von Mises */
                } else { /* discrete */
                    if (fabs(testamp[i1]-refamp[i2])>awidth[a])
                        goto nextm;
                    tmp = 0;
                }
                    
                    
                acc_a += tmp;
                
                i1+=M;
                i2+=N;
                
            }
            
            if (!computed_stim) {
                /* compute stimulus */
                
                for (g=0; g<G;g++) {
                    acc_g[g]=0;
                    skip_g[g]=0;
                    i1=g;
                    i2=n;

                    for (x=0;x<X;x++) {
                        /*tmp = (gridpos[i1]-refpos[i2])/xwidth[x];
                        acc_g[g]*= ( exp(-0.5*tmp*tmp) / ( sqrt(2*pi) * xwidth[x] ) );
                        
                        if (acc_g[g]<0.0001) {
                            acc_g[g]=0;
                            break;
                        }*/
                        
                        if (xtype[x]==0) { /* gaussian */
                            tmp = (gridpos[i1]-refpos[i2])/xwidth[x];
                            tmp *= tmp;
                            if (tmp>16) {
                                skip_g[g]=1;
                                break;
                            }
                        
                            tmp *= -0.5;
                        } else if (xtype[x]==1) { /* von Mises */
                        } else { /* discrete */
                            if (fabs(gridpos[i1]-refpos[i2])>xwidth[x]) {
                                skip_g[g]=1;
                                break;
                            }
                            tmp = 0;
                        }
                        
                        acc_g[g] += tmp;
                        
                        i1+=G;
                        i2+=N;
                        
                    }
                }
                
                computed_stim = 1;
                
            }
            
            for (g=0;g<G;g++) {
             
                /*if (acc_g[g]>0)
                    pout[m+g*M]+=(acc_a*acc_g[g]);*/
                if (!skip_g[g])
                    pout[m+g*M]+=exp(acc_a+acc_g[g]);
                
            }
            
            nextm:
                ;
        }
        
    }
    mxFree(acc_g);
    mxFree(skip_g);

    plhs[0] = out;
}
