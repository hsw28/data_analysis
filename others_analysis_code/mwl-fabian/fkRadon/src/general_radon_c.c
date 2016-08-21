#include "mex.h"
#include <math.h>

#define MAX(a, b) (a > b ? a : b)
#define MIN(a, b) (a < b ? a : b)

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  /* [R, [n]] = general_radon_c( theta, rho, M, dx, dy [, interpolation, method, constraint, valid, rho_x] ) */

  /* INPUTS: */
  /* theta: vector of angles */
  /* rho: vector of (local) rho values */
  /* M: data matrix */
  /* dx,dy: sample size in x (row) and y (column) dimension */
  /* interpolation: interpolation method (0=nearest or 1=linear) */
  /* method: 0=integral, 1=sum, 2=mean, 3=slice, 4=product, 5=logsum */
  /* constraint: 0=no constraint, 1=loop over rows only (i.e. only one element per row contributes to a line), 2=loop over columns only */
  /* valid: 0/1 (valid lines are those lines that span the whole width or height of the input matrix) */
  /* rho_x: 0/1 (if 1, indicates that rho is specified as the intercept with the horizontal center line,
     rather than the distance from the origin, this could be useful if you want rho to be in the same units as the x dimension.
     Notice however, that in this mode, rho will go to infinity if theta approaches +/- pi ) */

  /* OUTPUTS: */
  /* if method is one of integral, sum, mean, product
  /* R: radon transform matrix if method is one of integral, sum, mean, product */
  /* n: number of elements in original matrix contributing to each line*/ 
  /* if method is slice */
  /* R: cell array of projections along lines specified by theta and rho pairs */
  /* n: number of elements in original matrix contributing to each line*/ 

  /* variables */
  int T,R,M,N;
  int t,r,m,n;
  double *theta, *rho, *g;
  double delta_x, delta_y;
  mxArray *out, *tmp, *out2;
  double *pout;
  short *pout2;
  double alpha, beta, betap, costheta, sintheta, rhooffset;
  int mmin, mmax, nmin, nmax, amax;
  double xmin, ymin;
  int rstart, rend;
  double sum;
  int count, method, lininterp, valid, rho_x, constraint;
  double eps=1e-9;
  int indx;
  double nfloat, w;
  int dims[3];
  const char *mclass;
  mxArray *mcopy;

  /* check optional input parameters */
  if (nrhs>5 && mxGetScalar(prhs[5]) ) {
    lininterp=1;
  } else {
    lininterp=0; /* default interpolation is nearest */
  }
  if (nrhs>6 ) {
    method=mxGetScalar(prhs[6]);
  } else {
    method=0; /* default method is integral */
  }
  if (nrhs>7) {
    constraint = (int) mxGetScalar(prhs[7]);
    if (constraint!=1 && constraint!=2)
      constraint = 0;
  } else {
    constraint = 0; /* by default no constraint */
  }
  if (nrhs>8 && mxGetScalar(prhs[8]) ) {
    valid = 1;
  } else {
    valid = 0; /* by default compute all lines */
  }
  if (nrhs>9 && mxGetScalar(prhs[9]) ) {
    rho_x = 1;
  } else {
    rho_x = 0; /* by default rho specifies distance from origin */
  }


  mclass = mxGetClassName(prhs[2]);
  if (!mxIsDouble(prhs[2])) {
    if ( mexCallMATLAB(1, &mcopy, 1, (mxArray**)&prhs[2], "double") )
      mexErrMsgTxt("Could not convert matrix to double precision");
    
    g = mxGetPr( mcopy );
  } else {
    g = mxGetPr( prhs[2] );
  }

  /* get input arguments */
  T = mxGetNumberOfElements( prhs[0] ); /* length theta vector */
  R = mxGetNumberOfElements( prhs[1] ); /* length rho vector */
  M = mxGetM( prhs[2] ); /* number of rows matrix M */
  N = mxGetN( prhs[2] ); /* number of columns matrix M */

  theta = mxGetPr( prhs[0] ); /* pointer to theta vector */
  rho = mxGetPr( prhs[1] ); /* pointer to rho vector */

  delta_x = mxGetScalar( prhs[3] ); /* sample size in x (row) dimension */
  delta_y = mxGetScalar( prhs[4] ); /* sample size in y (column) dimension */

  xmin = -delta_x*(M-1)/2; /* x of lower left corner of matrix M (local coordinates) */
  ymin = -delta_y*(N-1)/2; /* y of lower left corner of matrix M (local coordinates) */


  /* create output matrices */
  if (method==3) {
    out = mxCreateCellMatrix(T,1);
  } else {
    out = mxCreateDoubleMatrix( T,R,mxREAL);
    pout = mxGetPr( out );
  }

  if (nlhs>1) {
    if (method==3) {
      out2 = mxCreateNumericMatrix(T,2,mxINT16_CLASS,mxREAL);
    } else {
      dims[0]=T;
      dims[1]=R;
      dims[2]=2;      
      out2 = mxCreateNumericArray(3,(const int*) &dims, mxINT16_CLASS,mxREAL);
    }
    pout2 = (short*) mxGetPr( out2 );
  }

  /* (minimal) error checking */
  if (method==3 && T!=R)
    mexErrMsgTxt("Theta and rho vectors have incompatible lengths");


  for (t=0;t<T;t++) { /* loop through all angles */

    costheta = cos( theta[t] );
    sintheta = sin( theta[t] );
      
    /* decide whether to loop over samples in x or y dimension */
    if (constraint==1 || (constraint==0 && ( fabs(sintheta)>(delta_x/sqrt(delta_x*delta_x+delta_y*delta_y)) ) ) ) { /* loop over rows */
	
      rhooffset = xmin*costheta + ymin*sintheta;
      alpha = -(delta_x/delta_y)*(costheta/sintheta); /* alpha parameter of line */
	
      /* initialize rho start and end */
      if (method==3) {
	rstart = t;
	rend = rstart+1;
      } else {
	rstart = 0;
	rend = R;
      }
	
      /* loop over all rho values */
      for (r=rstart;r<rend;r++ ) {
	  
	/* compute beta parameter of line */
	if (rho_x)
	  beta = (rho[r]*costheta-rhooffset)/(delta_y*sintheta);
	else
	  beta = (rho[r]-rhooffset)/(delta_y*sintheta);
	  
	/* compute rows to loop over */
	if (lininterp) { 
	  if (alpha>eps) {
	    mmin=(int)ceil(-(beta-eps)/alpha);
	    mmax=1+(int)floor((N-beta-1-eps)/alpha);
	  } else if (alpha<-eps) {
	    mmin=(int)ceil((N-beta-1-eps)/alpha);
	    mmax=1+(int)floor(-(beta-eps)/alpha);
	  } else if (((beta-eps)>0) && ((beta+eps)<(N-1))) {
	    mmin=0;
	    mmax=M;
	  } else {
	    mmin=0;
	    mmax=-1;
	  }
	} else {
	  betap=beta+0.5;
	  if (alpha>eps) {
	    mmin=(int)ceil(-(betap-eps)/alpha);
	    mmax=1+(int)floor((N-betap-eps)/alpha);
	  } else if (alpha<-eps) {
	    mmin=(int)ceil((N-betap-eps)/alpha);
	    mmax=1+(int)floor(-(betap-eps)/alpha);
	  } else if (((betap-eps)>0) && ((betap+eps)<N)) {
	    mmin=0;
	    mmax=M;
	  } else {
	    mmin=0;
	    mmax=-1;
	  }
	}
	if (mmin<0) mmin=0;
	if (mmax>M) mmax=M;
	count=MAX(0,mmax-mmin); /* number of rows to loop over */
	  
	/* check if line is valid */
	if ( ( (valid) && count<M && fabs(alpha*count)<(N-2) ) || (count<=0) ) {
	  if (method==3) {
	    if (nlhs>1) {
	      pout2[t] = 0;
	      pout2[t+T] = 0;
	    }
	  } else {
	    pout[ t+T*r] = mxGetNaN();
	    if (nlhs>1) {
	      pout2[ t+T*r ] = 0;
	      pout2[ t+T*r+T*R ] = 0;
	    }
	  }
	  continue;
	}
	  
	if (method==3) { /* process slice method */
	    
	  tmp = mxCreateDoubleMatrix(count, 1, mxREAL);
	  mxSetCell(out, t, tmp );
	    
/* 	  if (alpha<-eps) */
/* 	    pout = mxGetPr(tmp) + count - 1; */
/* 	  else */
	  pout = mxGetPr(tmp);
	    
	  if (lininterp) {

	    for (m=mmin; m<mmax; m++) {
		
	      nfloat = alpha*m+beta;
	      n = floor(nfloat);
	      w = nfloat-n;
		
	      if (fabs(w)<eps) {
		(*pout)=(g[m+M*n]);
	      } else {
		(*pout)=(g[m+M*n]*(1-w)+g[m+M*(n+1)]*w);
	      }
		
/* 	      if (alpha<-eps) */
/* 		pout--; */
/* 	      else */
	      pout++;
	      
	    }
	  } else {
	    for (m=mmin; m<mmax; m++) {
	      indx = round(alpha*m+beta); /* nearest neighbour */
	      (*pout)= g[m+M*indx];
/* 	      if (alpha<-eps) */
/* 		pout--; */
/* 	      else */
	      pout++;
	    }
	  }
	    
	} else if (method==4) { /* process product method */
	    
	  /* initialize sum to one */
	  sum=1;

	  if (lininterp) {	    

	    for (m=mmin; m<mmax; m++) {
		
	      nfloat = alpha*m+beta;
	      n = floor(nfloat);
	      w = nfloat-n;
		
	      if (fabs(w)<eps) {
		sum*=g[m+M*n];
	      } else {
		sum*=g[m+M*n]*(1-w)+g[m+M*(n+1)]*w;
	      }
		
	    } 

	  } else {

	    for (m=mmin; m<mmax; m++) {

	      indx = round(alpha*m+beta); /* nearest neighbour */
	      sum *= g[m+M*indx];

	    }

	  }
	    
	  pout[t+T*r] = sum;

	} else if (method==5) { /* process log sum method */
	    
	  /* initialize sum to one */
	  sum=0;

	  if (lininterp) {	    

	    for (m=mmin; m<mmax; m++) {
		
	      nfloat = alpha*m+beta;
	      n = floor(nfloat);
	      w = nfloat-n;
		
	      if (fabs(w)<eps) {
		sum+=log(g[m+M*n]);
	      } else {
		sum+=log(g[m+M*n]*(1-w)+g[m+M*(n+1)]*w);
	      }
		
	    } 

	  } else {

	    for (m=mmin; m<mmax; m++) {

	      indx = round(alpha*m+beta); /* nearest neighbour */
	      sum += log(g[m+M*indx]);

	    }

	  }
	    
	  pout[t+T*r] = sum;
	    
	} else { /* process integral, sum and mean methods */
	    
	  /* initialize sum to zero */
	  sum = 0;

	  if (lininterp) {
	    
	    for (m=mmin; m<mmax; m++) {
		
	      nfloat = alpha*m+beta;
	      n = floor(nfloat);
	      w = nfloat-n;
		
	      if (fabs(w)<eps) {
		sum+=g[m+M*n];
	      } else {
		sum+=g[m+M*n]*(1-w)+g[m+M*(n+1)]*w;
	      }
	      
	    }

	  } else {

	    for (m=mmin; m<mmax; m++) {

	      indx = round(alpha*m+beta); /* nearest neighbour */
	      sum += g[m+M*indx];

	    }

	  }
	    
	  if (method==0) /* integral */
	    pout[ t+T*r ] = delta_x*sum/fabs(sintheta);
	  else if (method==1) /* sum */
	    pout[ t+T*r ] = sum;
	  else if (method==2) /* mean */
	    pout[ t+T*r ] = sum/count;
	    
	} /* end conditional on method */
	  
	if (nlhs>1) {
	    
	  if (method==3) {
	    pout2[t] = mmin+1;
	    pout2[t+T] = mmax;
	  } else {
	    pout2[t+T*r] = mmin+1;
	    pout2[t+T*r+T*R] = mmax;
	  }
	    
	}	  
	  
      } /* end loop over rho values */	
	
    } else { /* loop over columns */
	
      alpha = -(delta_y/delta_x)*(sintheta/costheta);
      rhooffset = xmin*costheta + ymin*sintheta;
	
      /* initialize rho start and end */
      if (method==3) {
	rstart = t;
	rend = rstart+1;
      } else {
	rstart = 0;
	rend = R;
      }
	
      /* loop over all rho values */
      for ( r=rstart;r<rend;r++ ) {
	  
	if (rho_x)
	  beta = (rho[r]*costheta-rhooffset)/(delta_x*costheta);
	else
	  beta = (rho[r]-rhooffset)/(delta_x*costheta);
	  
	/* compute columns to loop over */
	if (lininterp) {
	  if (alpha>eps) {
	    nmin=(int)ceil(-(beta-eps)/alpha);
	    nmax=1+(int)floor((M-beta-1-eps)/alpha);
	  } else if (alpha<-eps) {
	    nmin=(int)ceil((M-beta-1-eps)/alpha);
	    nmax=1+(int)floor(-(beta-eps)/alpha);
	  } else if (((beta-eps)>0) && ((beta+eps)<(M-1))) {
	    nmin=0;
	    nmax=N;
	  } else {
	    nmin=0;
	    nmax=-1;
	  }
	} else {
	  betap=beta+0.5;
	  if (alpha>eps) {
	    nmin=(int)ceil(-(betap-eps)/alpha);
	    nmax=1+(int)floor((M-betap-eps)/alpha);
	  } else if (alpha<-eps) {
	    nmin=(int)ceil((M-betap-eps)/alpha);
	    nmax=1+(int)floor(-(betap-eps)/alpha);
	  } else if (((betap-eps)>0) && ((betap+eps)<M)) {
	    nmin=0;
	    nmax=N;
	  } else {
	    nmin=0;
	    nmax=-1;
	  }
	}
	if (nmin<0) nmin=0;
	if (nmax>N) nmax=N;
	count=MAX(0,nmax-nmin); /* number of columns to loop over */
	  
	/* check if line is valid */
	if ( ( (valid) && count<N && fabs(alpha*count)<(M-2) ) || (count<=0) ) {
	  if (method==3) {
	    if (nlhs>1) {
	      pout2[t] = 0;
	      pout2[t+T] = 0;
	    }
	  } else {
	    pout[ t+T*r] = mxGetNaN();
	    if (nlhs>1) {
	      pout2[ t+T*r ] = 0;
	      pout2[ t+T*r+T*R ] = 0;
	    }
	  }	    
	  continue;
	}
	  
	if (method==3) { /* process slice method */
	    
	  tmp = mxCreateDoubleMatrix(count, 1, mxREAL);
	  mxSetCell(out, t, tmp );
	    
	  pout = mxGetPr(tmp);

	  if (lininterp) {
	    
	    for (n=nmin;n<nmax;n++) {
		
	      nfloat = alpha*n+beta;
	      m = floor(nfloat);
	      w = nfloat-m;
		
	      if (fabs(w)<eps) {
		(*pout)=(g[m+M*n]);
	      } else {
		(*pout)=(g[m+M*n]*(1-w)+g[m+1+M*n]*w);
	      }

	      pout++;
		
	    }

	  } else {

	    for (n=nmin;n<nmax;n++) {
		
	      indx = round(alpha*n+beta); /* nearest neighbour */
	      *(pout)=g[n*M+indx];
	      pout++;
		
	    }
	      
	  }
	    
	} else if (method==4) { /* process product */
	    
	  /* initialize sum to one */
	  sum=1;

	  if (lininterp) {
	    
	    for (n=nmin; n<nmax; n++) {
		
	      nfloat = alpha*n+beta;
	      m = floor(nfloat);
	      w = nfloat-m;
		
	      if (fabs(w)<eps) {
		sum*=g[m+M*n];
	      } else {
		sum*=g[m+M*n]*(1-w)+g[m+M*(n+1)]*w;
	      }
		
	    } 

	  } else {

	    for (n=nmin; n<nmax; n++) {
	      indx = round(alpha*n+beta); /* nearest neighbour */
	      sum *= g[n*M+indx];
	    }

	  }
	    
	  pout[t+T*r] = sum;

	} else if (method==5) { /* process log sum */
	    
	  /* initialize sum to one */
	  sum=0;

	  if (lininterp) {
	    
	    for (n=nmin; n<nmax; n++) {
		
	      nfloat = alpha*n+beta;
	      m = floor(nfloat);
	      w = nfloat-m;
		
	      if (fabs(w)<eps) {
		sum+=log(g[m+M*n]);
	      } else {
		sum+=log(g[m+M*n]*(1-w)+g[m+M*(n+1)]*w);
	      }
		
	    } 

	  } else {

	    for (n=nmin; n<nmax; n++) {
	      indx = round(alpha*n+beta); /* nearest neighbour */
	      sum += log(g[n*M+indx]);
	    }

	  }
	    
	  pout[t+T*r] = sum;
	    
	} else { /* process integral, sum and mean methods */
	    
	  /* initialize sum to zero */
	  sum = 0;

	  if (lininterp) {
	    
	    for (n=nmin;n<nmax;n++) {
		
	      nfloat = alpha*n+beta;
	      m = floor(nfloat);
	      w = nfloat-m;
		
	      if (fabs(w)<eps) {
		sum+=g[m+M*n];
	      } else {
		sum+=g[m+M*n]*(1-w)+g[m+1+M*n]*w;
	      }
		
	    }

	  } else {
	      
	    for (n=nmin;n<nmax;n++) {
	      indx = round(alpha*n+beta); /* nearest neighbour */
	      sum+=g[n*M+indx];
	    }	      

	  }
	      
	  if (method==0) /* integral */
	    pout[ t+T*r ] = delta_y*sum/fabs(costheta);
	  else if (method==1) /* sum */
	    pout[ t+T*r ] = sum;
	  else if (method==2) /* mean */
	    pout[ t+T*r ] = sum/count;
	    
	} /* end conditional on method */

	if (nlhs>1) {
	    
	  if (method==3) {
	    pout2[t] = nmin+1;
	    pout2[t+T] = nmax;
	  } else {
	    pout2[t+T*r] = nmin+1;
	    pout2[t+T*r+T*R] = nmax;
	  }
	    
	}
	  
      } /* end loop over rho values */
	
    } /* end conditional rows/columns */

  } /* end loop over angles */

  /* set output arguments */
  plhs[0] = out;
  
  if (nlhs>1)
    plhs[1] = out2;


} /* end mexFunction */
