#include "mex.h"
#include <math.h>

#define MAX(a, b) (a > b ? a : b)
#define MIN(a, b) (a < b ? a : b)

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  /* [R, [n]] = radon_transform_c(theta, rho, M, dx, dy, interp, method, valid, rho_x ) */

  /* required arguments: */
  /* theta: vector of angles */
  /* rho: vector of (local) rho values */
  /* M: data matrix */
  /* dx,dy: sample size in x (row) and y (column) dimensions */

  /* optional arguments: */
  /* interp: interpolation method (linear or nearest) */
  /* method: 0=integral, 1=sum, 2=mean, 3=slice */
  /* valid: 0/1 (valid lines are those lines that span the whole width/height of the input matrix) */
  /* rho_x: 0/1 (if 1, indicates that rho is specified as the intercept with the horizontal center line,
     rather than the distance from the origin */

  /* outputs: */
  /* R: radon transform */
  /* n: number of samples used to get each of the values in R (no output if method=3) */


  int T,R,M,N;
  int t,r,m,n;
  double *theta, *rho, *g;
  double delta_x, delta_y;
  mxArray *out, *tmp, *out2, *out3;
  double *pout, *pout2, *pout4;
  unsigned short *pout3;
  double alpha, beta, betap, costheta, sintheta, rhooffset;
  int mmin, mmax, nmin, nmax, amax;
  double xmin, ymin;

  int rstart, rend;

  double sum;
  int count, method, lininterp, valid, rho_x;

  double eps=1e-9;
  int indx;

  double nfloat, w;

  mxArray *sp;
  double *spr;
  int *sir, *sjc;
  int nsp;

  /* check optional input parameters */

  if (nrhs>5 && mxGetScalar(prhs[5]) ) {
    lininterp=1;
  } else {
    lininterp=0;
  }
  if (nrhs>6 ) {
    method=mxGetScalar(prhs[6]);
  } else {
    method=0;
  }
  if (nrhs>7 && mxGetScalar(prhs[7]) ) {
    valid = 1;
  } else {
    valid = 0;
  }
  if (nrhs>8 && mxGetScalar(prhs[8]) ) {
    rho_x = 1;
  } else {
    rho_x = 0;
  }

  /* get input arguments */
  T = mxGetNumberOfElements( prhs[0] );
  R = mxGetNumberOfElements( prhs[1] );
  M = mxGetM( prhs[2] );
  N = mxGetN( prhs[2] );

  theta = mxGetPr( prhs[0] );
  rho = mxGetPr( prhs[1] );
  g = mxGetPr( prhs[2] );
  delta_x = mxGetScalar( prhs[3] );
  delta_y = mxGetScalar( prhs[4] );

  xmin = -delta_x*(M-1)/2;
  ymin = -delta_y*(N-1)/2;

  /* create output matrices */
  if (method==3) {
    out = mxCreateCellMatrix(T,1);
  } else {
    out = mxCreateDoubleMatrix( T,R,mxREAL);
    pout = mxGetPr( out );
  }

  if (nlhs>1) {
    if (method==3)
      out2 = mxCreateDoubleMatrix(T,1,mxREAL);
    else
      out2 = mxCreateDoubleMatrix(T,R,mxREAL);
    pout2 = mxGetPr( out2 );
  }
  if (nlhs>2) {
    if (lininterp)
      out3 = mxCreateCellMatrix(2,1);
    else
      out3 = mxCreateCellMatrix(1,1);
    if (method==3) {
      /*out3 = mxCreateCellMatrix(T,1);*/
      mxSetCell( out3, 0, mxCreateNumericMatrix(T,M,mxUINT16_CLASS,mxREAL) );
      if (lininterp)
	mxSetCell( out3, 1, mxCreateDoubleMatrix(T,M,mxREAL) );
      /*       out3 = mxCreateDoubleMatrix(T, M, mxREAL); */
    } else {
      /*out3 = mxCreateCellMatrix(T,R);*/
      mxSetCell( out3, 0, mxCreateNumericMatrix(T*R,M,mxUINT16_CLASS,mxREAL) );
	/*mxSetCell( out3, 0, mxCreateDoubleMatrix(T*R,M,mxREAL) );*/
      if (lininterp)
	mxSetCell( out3, 1, mxCreateDoubleMatrix(T*R,M,mxREAL) );
      /* out3 = mxCreateDoubleMatrix(T*R,M,mxREAL); */
    }
    pout3 = (unsigned short*) mxGetPr( mxGetCell(out3,0) );
    if (lininterp)
      pout4 = mxGetPr( mxGetCell(out3,1) );
  }


  if (method==3 && T!=R)
    mexErrMsgTxt("Theta and rho vectors have incompatible lengths");
  
  /* linear interpolation */
  if (lininterp) {
    
    /* loop through all angles */
    for( t=0;t<T;t++ ) {
      costheta = cos( theta[t] );
      sintheta = sin( theta[t] );

      /* decide whether to loop over samples in x or y dimension */
      if ( fabs(sintheta)>(delta_x/sqrt(delta_x*delta_x+delta_y*delta_y)) ) { /* loop over rows */
	/*      if (fabs(sintheta)>(1/sqrt(2))) {*/

	rhooffset = xmin*costheta + ymin*sintheta;
	alpha = -(delta_x/delta_y)*(costheta/sintheta);

	if (method==3) {
	  rstart = t;
	  rend = rstart+1;
	} else {
	  rstart = 0;
	  rend = R;
	}

	/* loop over all rho values */
	for (r=rstart;r<rend;r++ ) {

	  if (rho_x)
	    beta = (rho[r]*costheta-rhooffset)/(delta_y*sintheta);
	  else
	    beta = (rho[r]-rhooffset)/(delta_y*sintheta);

	  sum = 0;
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
	  if (mmin<0) mmin=0;
	  if (mmax>M) mmax=M;
	  count=MAX(0,mmax-mmin);

	  /* check if line is valid */
 	  if ( (valid) && count<M && fabs(alpha*count)<(N-2) ) {
	    if (method==3) {
	      if (nlhs>1)
		pout2[t] = mxGetNaN();
	    } else {
	      pout[ t+T*r] = mxGetNaN();
	      if (nlhs>1)
		pout2[ t+T*r ] = mxGetNaN();
	    }
	      continue;
	  }

/* 	  if (nlhs>2) { /\* create new sparse matrix *\/ */
/* 	    sp = mxCreateDoubleMatrix(3, 2*count+1, mxREAL); */
/* 	    spr = mxGetPr( sp ); */
/* 	    nsp = 0; */
/* 	  } */

	  /* process slice method */
	  if (method==3) {
	    tmp = mxCreateDoubleMatrix(count, 1, mxREAL);
	    mxSetCell(out, t, tmp );
	    if (alpha<-eps)
	      pout = mxGetPr(tmp) + count - 1;
	    else
	      pout = mxGetPr(tmp);
	    
	    for (m=mmin; m<mmax; m++) {
	      nfloat = alpha*m+beta;
	      n = floor(nfloat);
	      w = nfloat-n;
	      if (fabs(w)<eps) {
		(*pout)=(g[m+M*n]);
		if (nlhs>2) {
		  pout3[t+T*r+m*T*R]++;
		  pout4[t+T*r+m*T*R]++;
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=1; */
/* 		  nsp++; */
		}
	      } else {
		(*pout)=(g[m+M*n]*(1-w)+g[m+M*(n+1)]*w);
		if (nlhs>2) {
		  pout3[t+T*r+m*T*R]+=2;
		  pout4[t+T*r+m*T*R]++;
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=1-w; */
/* 		  nsp++; */
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+2; */
/* 		  spr[2+3*nsp]=w; */
/* 		  nsp++; */
		}		
	      }
	      if (alpha<-eps)
		pout--;
	      else
		pout++;
	    }

	  } else { /* process integral, sum and mean methods */
	    for (m=mmin; m<mmax; m++) {
	      nfloat = alpha*m+beta;
	      n = floor(nfloat);
	      w = nfloat-n;
	      if (fabs(w)<eps) {
		sum+=g[m+M*n];
		if (nlhs>2) {
		  pout3[t+T*r+m*T*R]++;
		  pout4[t+T*r+m*T*R]++;
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=1; */
/* 		  nsp++; */
		}
	      } else {
		sum+=g[m+M*n]*(1-w)+g[m+M*(n+1)]*w;
		if (nlhs>2) {
		  pout3[t+T*r+m*T*R]+=2;
		  pout4[t+T*r+m*T*R]++;
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=1-w; */
/* 		  nsp++; */
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+2; */
/* 		  spr[2+3*nsp]=w; */
/* 		  nsp++; */
		}
	      }
	    }
	    if (method==0) { /* integral */
	      pout[ t+T*r ] = delta_x*sum/fabs(sintheta);
	    } else if (method==1) /* sum */
	      pout[ t+T*r ] = sum;
	    else if (method==2) /* mean */
	      pout[ t+T*r ] = sum/count;

	  }

	  if (nlhs>1) {
	    if (method==3)
	      pout2[t] = count;
	    else
	      pout2[ t+T*r ] = count;
	  }

/* 	  if (nlhs>2) { */
/* 	    mxSetN(sp, nsp); */
/* 	    if (method==3) */
/* 	      mxSetCell(out3, t, sp ); */
/* 	    else */
/* 	      mxSetCell(out3, t+T*r, sp); */
/* 	  } */
	}

      } else { /* loop over columns */

	alpha = -(delta_y/delta_x)*(sintheta/costheta);
	rhooffset = xmin*costheta + ymin*sintheta;

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

	  sum = 0;
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
	  if (nmin<0) nmin=0;
	  if (nmax>N) nmax=N;
	  count=MAX(0,nmax-nmin);

	  /* check if line is valid */
 	  if ( (valid) && count<N && fabs(alpha*count)<(M-2) ) {
	    if (method!=3) {
	      pout[ t+T*r] = mxGetNaN(); 
	      if (nlhs>1)
		pout2[ t+T*r] = mxGetNaN();
	    }
	    continue;
	  }

/* 	  if (nlhs>2) { /\* create new sparse matrix *\/ */
/* 	    sp = mxCreateDoubleMatrix(3, 2*count+1, mxREAL); */
/* 	    spr = mxGetPr( sp ); */
/* 	    nsp = 0; */
/* 	  } */


	  /* process slice method */
	  if (method==3) {
	    tmp = mxCreateDoubleMatrix(count, 1, mxREAL);
	    mxSetCell(out, t, tmp );
	    pout = mxGetPr(tmp);
	    for (n=nmin;n<nmax;n++) {
	      nfloat = alpha*n+beta;
	      m = floor(nfloat);
	      w = nfloat-m;

	      if (fabs(w)<eps) {
		(*pout)=(g[m+M*n]);
		if (nlhs>2) {
		  pout3[t+T*r+m*T*R]++;
		  pout4[t+T*r+m*T*R]++;
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=1; */
/* 		  nsp++; */
		}
	      } else {
		(*pout)=(g[m+M*n]*(1-w)+g[m+1+M*n]*w);
		if (nlhs>2) {
		  pout3[t+T*r+m*T*R]++;
		  pout3[t+T*r+(m+1)*T*R]++;
		  pout4[t+T*r+m*T*R]+=(1-w);
		  pout4[t+T*r+(m+1)*T*R]+=w;
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=1-w; */
/* 		  nsp++; */
/* 		  spr[3*nsp]=m+2; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=w; */
/* 		  nsp++; */
		}
	      }

	      pout++;
	    }
	  } else { /* process integral, sum and mean methods */
	    for (n=nmin;n<nmax;n++) {
	      nfloat = alpha*n+beta;
	      m = floor(nfloat);
	      w = nfloat-m;
	      if (fabs(w)<eps) {
		sum+=g[m+M*n];
		if (nlhs>2) {
		  pout3[t+T*r+m*T*R]++;
		  pout4[t+T*r+m*T*R]++;
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=1; */
/* 		  nsp++; */
		}
	      } else {
		sum+=g[m+M*n]*(1-w)+g[m+1+M*n]*w;
		if (nlhs>2) {
		  pout3[t+T*r+m*T*R]++;
		  pout3[t+T*r+(m+1)*T*R]++;
		  pout4[t+T*r+m*T*R]+=(1-w);
		  pout4[t+T*r+m*T*R]+=w;
/* 		  spr[3*nsp]=m+1; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=1-w; */
/* 		  nsp++; */
/* 		  spr[3*nsp]=m+2; */
/* 		  spr[1+3*nsp]=n+1; */
/* 		  spr[2+3*nsp]=w; */
/* 		  nsp++; */
		}
	      }
	    }
	    if (method==0) /* integral */
	      pout[ t+T*r ] = delta_y*sum/fabs(costheta);
	    else if (method==1) /* sum */
	      pout[ t+T*r ] = sum;
	    else if (method==2) /* mean */
	      pout[ t+T*r ] = sum/count;

	  }

	  if (nlhs>1) {
	    if (method==3)
	      pout2[t] = count;
	    else
	      pout2[ t+T*r ] = count;
	  }

/* 	  if (nlhs>2) { */
/* 	    mxSetN(sp, nsp); */
/* 	    if (method==3) */
/* 	      mxSetCell(out3, t, sp ); */
/* 	    else */
/* 	      mxSetCell(out3, t+T*r, sp); */
/* 	  } */
	    
	}
      }
    }

  } else { /* nearest neighbor interpolation */

    /* loop through all angles */
    for( t=0;t<T;t++ ) {
      costheta = cos( theta[t] );
      sintheta = sin( theta[t] );

      /* decide whether to loop over samples in x or y dimension */
      if ( fabs(sintheta)>(delta_x/sqrt(delta_x*delta_x+delta_y*delta_y)) ) {  /* loop over rows */

	rhooffset = xmin*costheta+ ymin*sintheta;
	alpha = -(delta_x/delta_y)*(costheta/sintheta);

	if (method==3) {
	  rstart = t;
	  rend = rstart+1;
	} else {
	  rstart = 0;
	  rend = R;
	}

	/* loop over all rho values */
	for (r=rstart;r<rend;r++ ) {

	  if (rho_x)
	    beta = (rho[r]*costheta-rhooffset)/(delta_y*sintheta);
	  else
	    beta = (rho[r]-rhooffset)/(delta_y*sintheta);

	  sum = 0;
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
	  if (mmin<0) mmin=0;
	  if (mmax>M) mmax=M;
	  count=MAX(0,mmax-mmin);

	  /* check if line is valid */
 	  if ( (valid) && count<M && fabs(alpha*count)<(N-2) ) {
	    if (method!=3) {
	      pout[ t+T*r] = mxGetNaN();
	      if (nlhs>1)
		pout2[ t+T*r ] = mxGetNaN();
	    }
	    continue;
	  }

/* 	  if (nlhs>2) { /\* create new sparse matrix *\/ */
/* 	    sp = mxCreateDoubleMatrix(3, count, mxREAL); */
/* 	    spr = mxGetPr( sp ); */
/* 	    nsp = 0; */
/* 	  } */

	  /* process slice method */
	  if (method==3) {
	    if (count==0) continue;
	    tmp = mxCreateDoubleMatrix(count, 1, mxREAL);
	    mxSetCell(out, t, tmp );
	    if (alpha<-eps)
	      pout = mxGetPr(tmp) + count - 1;
	    else
	      pout = mxGetPr(tmp);

	    for (m=mmin; m<mmax; m++) {
	      indx = round(alpha*m+beta); /* nearest neighbour */
	      (*pout)= g[m+M*indx];
	      if (nlhs>2) {
		pout3[t+T*r+m*T*R]++;
/* 		spr[3*nsp]=m+1; */
/* 		spr[1+3*nsp]=indx+1; */
/* 		spr[2+3*nsp]=1; */
/* 		nsp++; */
	      }
	      if (alpha<-eps)
		pout--;
	      else
		pout++;
	    }
	  } else { /* process integral, sum and mean methods */
	    for (m=mmin; m<mmax; m++) {
	      indx = round(alpha*m+beta); /* nearest neighbour */
	      sum += g[m+M*indx];
	      if (nlhs>2) {
		pout3[t+T*r+m*T*R]++;
/* 		spr[3*nsp]=m+1; */
/* 		spr[1+3*nsp]=indx+1; */
/* 		spr[2+3*nsp]=1; */
/* 		nsp++; */
	      }
	    }

	    if (method==0) /* integral */
	      pout[ t+T*r ] = delta_x*sum/fabs(sintheta);
	    else if (method==1) /* sum */
	      pout[ t+T*r ] = sum;
	    else if (method==2) /* mean */
	      pout[ t+T*r ] = sum/count;

	  }

	  if (nlhs>1) {
	    if (method==3)
	      pout2[t] = count;
	    else
	      pout2[ t+T*r ] = count;
	  }

/* 	  if (nlhs>2) { */
/* 	    if (method==3) */
/* 	      mxSetCell(out3, t, sp ); */
/* 	    else */
/* 	      mxSetCell(out3, t+T*r, sp); */
/* 	  } */

	}

      } else { /* loop over columns */

	alpha = -(delta_y/delta_x)*(sintheta/costheta);
	rhooffset = xmin*costheta+ymin*sintheta;
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

	  sum = 0;
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
	  if (nmin<0) nmin=0;
	  if (nmax>N) nmax=N;
	  count=MAX(0,nmax-nmin);

	  /* check if line is valid */
 	  if ( (valid) && count<N && fabs(alpha*count)<(M-2) ) {
	    if (method!=3) {
	      pout[ t+T*r] = mxGetNaN();
	      if (nlhs>1)
		pout2[ t+T*r] = mxGetNaN();
	    }
	    continue;
	  }

/* 	  if (nlhs>2) { /\* create new sparse matrix *\/ */
/* 	    sp = mxCreateDoubleMatrix(3, count, mxREAL); */
/* 	    spr = mxGetPr( sp ); */
/* 	    nsp = 0; */
/* 	  } */

	  /* process slice method */
	  if (method==3) {
	    tmp = mxCreateDoubleMatrix(count, 1, mxREAL);
	    pout = mxGetPr(tmp);
	    mxSetCell(out, t, tmp );
	    for (n=nmin;n<nmax;n++) {
	      indx = round(alpha*n+beta); /* nearest neighbour */
	      *(pout)=g[n*M+indx];
	      if (nlhs>2) {
		pout3[t+T*r+indx*T*R]++;
/* 		spr[3*nsp]=indx+1; */
/* 		spr[1+3*nsp]=n+1; */
/* 		spr[2+3*nsp]=1; */
/* 		nsp++; */
	      }
	      pout++;
	    }
	  } else { /* process integral, sum and mean methods */
	    for (n=nmin;n<nmax;n++) {
	      indx = round(alpha*n+beta); /* nearest neighbour */
	      sum+=g[n*M+indx];
	      if (nlhs>2) {
		pout3[t+T*r+indx*T*R]++;
/* 		spr[3*nsp]=indx+1; */
/* 		spr[1+3*nsp]=n+1; */
/* 		spr[2+3*nsp]=1; */
/* 		nsp++; */
	      }
	    }
	    if (method==0) /* integral */
	      pout[ t+T*r ] = delta_y*sum/fabs(costheta);
	    else if (method==1) /* sum */
	      pout[ t+T*r ] = sum;
	    else if (method==2) /* mean */
	      pout[ t+T*r ] = sum/count;

	  }

	  if (nlhs>1) {
	    if (method==3)
	      pout2[t] = count;
	    else
	      pout2[ t+T*r ] = count;
	  }

/* 	  if (nlhs>2) { */
/* 	    if (method==3) */
/* 	      mxSetCell(out3, t, sp ); */
/* 	    else */
/* 	      mxSetCell(out3, t+T*r, sp); */
/* 	  } */

	}
      }
    }
  }
  
  /* set output arguments */
  plhs[0] = out;
  
  if (nlhs>1)
    plhs[1] = out2;

  if (nlhs>2)
    plhs[2] = out3;

}
