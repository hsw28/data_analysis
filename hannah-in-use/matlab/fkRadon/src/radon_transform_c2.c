#include "mex.h"
#include <math.h>

#define MAX(a, b) (a > b ? a : b)
#define MIN(a, b) (a < b ? a : b)

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  /* radon_transform_c(theta, rho, M, dx, dy, interp, method, valid ) */

  int T,R,M,N;
  int t,r,m,n;
  double *theta, *rho, *g;
  double delta_x, delta_y;
  mxArray *out, *tmp;
  double *pout;
  double alpha, beta, betap, costheta, sintheta, rhooffset;
  int mmin, mmax, nmin, nmax, amax;
  double xmin, ymin;

  int rstart, rend;

  double sum;
  int count, method, lininterp, valid;

  double eps=1e-9;
  int indx;

  double nfloat, w;

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

  if (method==3) {
    out = mxCreateCellMatrix(T,1);
  } else {
    out = mxCreateDoubleMatrix( T,R,mxREAL);
    pout = mxGetPr( out );
  }

  /*method: 0: integral, 1: sum, 2: mean, 3: slice*/
  if (method==3 && T!=R)
    mexErrMsgTxt("Theta and rho vectors have incompatible lengths");
  
  if (lininterp) {
    
    for( t=0;t<T;t++ ) {
      costheta = cos( theta[t] );
      sintheta = sin( theta[t] );
      if ( fabs(sintheta)>(delta_x/sqrt(delta_x*delta_x+delta_y*delta_y)) ) {
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
	for (r=rstart;r<rend;r++ ) {
	    /*beta = (rho[r]-rhooffset)/(delta_y*sintheta);*/
	  beta = (rho[r]*costheta-rhooffset)/(delta_y*sintheta);
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
 	  if ( (valid) && count<M && fabs(alpha*count)<(N-2) ) {
	    if (method!=3)
	      pout[ t+T*r] = mxGetNaN();
	    continue;
	  }
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
	      if (fabs(w)<eps)
		(*pout)=(g[m+M*n]);
	      else
		(*pout)=(g[m+M*n]*(1-w)+g[m+M*(n+1)]*w);

	      if (alpha<-eps)
		pout--;
	      else
		pout++;
	    }
	  } else {
	    for (m=mmin; m<mmax; m++) {
	      nfloat = alpha*m+beta;
	      n = floor(nfloat);
	      w = nfloat-n;
	      if (fabs(w)<eps)
		sum+=g[m+M*n];
	      else
		sum+=g[m+M*n]*(1-w)+g[m+M*(n+1)]*w;
	    }
	    if (method==0) /* integral */
	      pout[ t+T*r ] = delta_x*sum/fabs(sintheta);
	    else if (method==1) /* sum */
	      pout[ t+T*r ] = sum;
	    else if (method==2) /* mean */
	      pout[ t+T*r ] = sum/count;
	  }
	}
      } else {
	alpha = -(delta_y/delta_x)*(sintheta/costheta);
	rhooffset = xmin*costheta + ymin*sintheta;
	if (method==3) {
	  rstart = t;
	  rend = rstart+1;
	} else {
	  rstart = 0;
	  rend = R;
	}
	for ( r=rstart;r<rend;r++ ) {
	  /*	  beta = (rho[r]-rhooffset)/(delta_x*costheta);*/
	  beta = (rho[r]*costheta-rhooffset)/(delta_x*costheta);
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
 	  if ( (valid) && count<N && fabs(alpha*count)<(M-2) ) {
	    if (method!=3)
	      pout[ t+T*r] = mxGetNaN(); 
	    continue;
	  }
	  if (method==3) {
	    tmp = mxCreateDoubleMatrix(count, 1, mxREAL);
	    mxSetCell(out, t, tmp );
	    pout = mxGetPr(tmp);
	    for (n=nmin;n<nmax;n++) {
	      nfloat = alpha*n+beta;
	      m = floor(nfloat);
	      w = nfloat-m;

	      if (fabs(w)<eps)
		(*pout)=(g[m+M*n]);
	      else
		(*pout)=(g[m+M*n]*(1-w)+g[m+1+M*n]*w);

	      pout++;
	    }
	  } else {
	    for (n=nmin;n<nmax;n++) {
	      nfloat = alpha*n+beta;
	      m = floor(nfloat);
	      w = nfloat-m;
	      if (fabs(w)<eps)
		sum+=g[m+M*n];
	      else
		sum+=g[m+M*n]*(1-w)+g[m+1+M*n]*w;
	    }
	    if (method==0) /* integral */
	      pout[ t+T*r ] = delta_y*sum/fabs(costheta);
	    else if (method==1) /* sum */
	      pout[ t+T*r ] = sum;
	    else if (method==2) /* mean */
	      pout[ t+T*r ] = sum/count;
	  }
	}
      }
    }
  } else {
    for( t=0;t<T;t++ ) {
      costheta = cos( theta[t] );
      sintheta = sin( theta[t] );
      if ( fabs(sintheta)>(delta_x/sqrt(delta_x*delta_x+delta_y*delta_y)) ) {
	rhooffset = xmin*costheta+ ymin*sintheta;
	alpha = -(delta_x/delta_y)*(costheta/sintheta);
	if (method==3) {
	  rstart = t;
	  rend = rstart+1;
	} else {
	  rstart = 0;
	  rend = R;
	}
	for (r=rstart;r<rend;r++ ) {
	  /*beta = (rho[r]-rhooffset)/(delta_y*sintheta);*/
	  beta = (rho[r]*costheta-rhooffset)/(delta_y*sintheta);
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
 	  if ( (valid) && count<M && fabs(alpha*count)<(N-2) ) {
	    if (method!=3)
	      pout[ t+T*r] = mxGetNaN();
	    continue;
	  }
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

	      if (alpha<-eps)
		pout--;
	      else
		pout++;
	    }
	  } else {
	    for (m=mmin; m<mmax; m++) {
	      indx = round(alpha*m+beta); /* nearest neighbour */
	      sum += g[m+M*indx];
	    }
	    if (method==0) /* integral */
	      pout[ t+T*r ] = delta_x*sum/fabs(sintheta);
	    else if (method==1) /* sum */
	      pout[ t+T*r ] = sum;
	    else if (method==2) /* mean */
	      pout[ t+T*r ] = sum/count;
	  }
	}
      } else {
	alpha = -(delta_y/delta_x)*(sintheta/costheta);
	rhooffset = xmin*costheta+ymin*sintheta;
	if (method==3) {
	  rstart = t;
	  rend = rstart+1;
	} else {
	  rstart = 0;
	  rend = R;
	}
	for ( r=rstart;r<rend;r++ ) {
	  /*beta = (rho[r]-rhooffset)/(delta_x*costheta);*/
	  beta = (rho[r]*costheta-rhooffset)/(delta_x*costheta);
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
 	  if ( (valid) && count<N && fabs(alpha*count)<(M-2) ) {
	    if (method!=3)
	      pout[ t+T*r] = mxGetNaN();
	    continue;
	  }
	  if (method==3) {
	    tmp = mxCreateDoubleMatrix(count, 1, mxREAL);
	    pout = mxGetPr(tmp);
	    mxSetCell(out, t, tmp );
	    for (n=nmin;n<nmax;n++) {
	      indx = round(alpha*n+beta); /* nearest neighbour */
	      *(pout)=g[n*M+indx];
	      pout++;
	    }
	  } else {
	    for (n=nmin;n<nmax;n++) {
	      indx = round(alpha*n+beta); /* nearest neighbour */
	      sum+=g[n*M+indx];
	    }
	    if (method==0) /* integral */
	      pout[ t+T*r ] = delta_y*sum/fabs(costheta);
	    else if (method==1) /* sum */
	      pout[ t+T*r ] = sum;
	    else if (method==2) /* mean */
	      pout[ t+T*r ] = sum/count;
	  }
	}
      }
    }
  }
  

  plhs[0] = out;
  
}
