/******************************************************************************
 
Filename: mwl_parseparams.c

Function: mxArray* mwl_parseparams(int nrhs, const mxArray *prhs[] )

Input:
       nrhs:  size of prhs array
       prhs:  array of mxArray data

Output:
       an mxArray, representing an array of structures of parameter name / parameter value pairs

Description:
                 

Author: David P. Nguyen (dpnguyen@mit.edu) and Fabian Kloosterman (fkloos@mit.edu)

$Id: mwlParseFilterParams.c,v 1.13 2003/12/12 03:04:28 dpnguyen Exp $
******************************************************************************/

#include <math.h>
#include <string.h>
#include <ctype.h>
#include <mex.h>
#include "mwlIOLib.h"
#include "mwlAPItypes.h"

#define FUNCNAME "parsefilterparams"
#define FUNCNAME2 "checkfilterparams"

#define M3D(r,c,w, R, C) (r + c*R + w*R*C)
#define M2D(r,c,R) (r + c*R)

const char *usage[] = {
  "Parameters may be entered by forming a single string that consists of the following characters:\n\n",
  "  s --> Filter Type Seconds\n", 
  "  t --> Filter Type Timestamps\n",
  "  r --> Filter Type Record ID\n",
  "  i --> Filter Type Spike ID\n",
  "  n --> No Filter, Get all data (default)\n",
  "\n",
  "  b --> Filter Parameter specifies block (default)\n"
  "  a --> Filter Parameter specifies array\n"
		       "\n",
  "  d --> Data read in as double (default)\n",
  "  p --> Preserve original data format\n",
  "\n",
  "  | --> filter parameters are relative to begining of file\n",
  "  > --> filter parameters are relative to the first filter parameter\n",
  "\n",
  "  0 --> error messages only\n",
  "  1 --> error and warning messages (default)\n",
  "  2 --> normal verbose level\n",
  "  3 --> detailed verbose level\n",
  "\n",
  "  + --> return data (default)\n",
  "  - --> return only timestamps and id of timestamps\n",
  "\0"};


char* strlwr(char *str)
{
  char *orig = str;
  
  while (*str) {
    *str = tolower(*str);
    str++;
  }

  return orig;
}

void mwl_ParseFilterParamUsage(void) {
  
  int i;
  
  for(i=0; *usage[i] != '\0'; i++)
    mexPrintf(usage[i]);
}


mwl_RESULT mwl_ParseFilterParamADIO(const mxArray *ps, const mxArray *param, mwl_ParamInfo *paraminfo) {
  
  /******************** variables ********************/
  int i;
  long j;
  int nrow, ncol, paramclass;
  
  char tempbuf[mwl_MAXSTRING];
  char warnbuf[mwl_MAXSTRING];
  char *ParamString = NULL;
  double *paramdata;

  /*******************check inputs **********************/
  if(paraminfo == NULL) {
    sprintf(warnbuf, "%s: Internal NULL Pointer", FUNCNAME);
    mwlPrintf(warnbuf, VBError, 0);
    return mwle_BADPARAM;
  }


  /* allocate parameter information structure */
  /* fill in the default parameters */
  paraminfo->FilterType = FTDefault;
  paraminfo->FilterParamType = FPTDefault;
  paraminfo->DataFormat = DFTDefault;
  paraminfo->RelativeFileStart = RTDefault;
  paraminfo->RelativeStartIndex = RTDefault;
  paraminfo->Verbose = VBWarning;
  paraminfo->ReturnType = RETDefault;

  /* if both options string and indexing vector are absent return */ 
  if((ps == NULL) && (param == NULL)) {
    return mwl_OK;
  }


  /* do we have an options string? */
  if(mxGetClassID(ps) != mxCHAR_CLASS) {
    sprintf(warnbuf, "%s: Expecting an options string", FUNCNAME);
    mwlPrintf(warnbuf, VBError, 0);
    return mwle_BADPARAM;
  }
   
  mxGetString(ps, tempbuf, mwl_MAXSTRING);
  ParamString = strlwr((char *)tempbuf);

  /* process parameter string */
  for(i=0; ParamString[i]; i++) {

    switch(ParamString[i]) {

    case 'n':
      paraminfo->FilterType = FTNone;
      break;
    case 't':
      paraminfo->FilterType = FTTimeStamp;
      break;
    case 's':
      paraminfo->FilterType = FTSeconds;
      break;
    case 'i':
      paraminfo->FilterType = FTSpikeID;
      break;
    case 'r':
      paraminfo->FilterType = FTRecordID;
      break;
    case 'b':
      paraminfo->FilterParamType = FPTBlock;
      break;
    case 'a':
      paraminfo->FilterParamType = FPTArray; 
      break;
    case 'd':
      paraminfo->DataFormat = DFTMatlabFormat;
      break;
    case 'p':
      paraminfo->DataFormat = DFTOrigFormat;
      break;
    case '|':
      paraminfo->RelativeFileStart = RTFileStart;
      break;
    case '>':
      paraminfo->RelativeStartIndex = RTStartIndex;
      break;
    case '2':
      paraminfo->Verbose = VBNormal;
      break;
    case '3':
      paraminfo->Verbose = VBDetail;
      break;
    case '1':
      paraminfo->Verbose = VBWarning;
      break;     
    case '0':
      paraminfo->Verbose = VBOff;
      break;
    case '-':
      paraminfo->ReturnType = RETNoData;
      break;
    case '+':
      paraminfo->ReturnType = RETData;
      break;
    default:
      break;
    }
  }


  /* checking for unsupported parameter combinations */
  if ( ( (paraminfo->FilterType == FTTimeStamp) || (paraminfo->FilterType == FTSeconds) ) && (paraminfo->FilterParamType == FPTArray) ) {
    sprintf(warnbuf, "%s: Array indexing not supported if filter type = seconds or timestamp", FUNCNAME);
    mwlPrintf(warnbuf, VBError, 0);
    return mwle_BADPARAM;
  }


  /* if we have an indexing vector check it */
  if(param != NULL) {

    paramclass = mxGetClassID(param);
    nrow = mxGetM(param);
    ncol = mxGetN(param);
    
    /* dimension of indexing vector should be 2-D */
    if(mxGetNumberOfDimensions(param) > 2) {
      sprintf(warnbuf, "%s: Expecting a 2-D parameter ", FUNCNAME);
      mwlPrintf(warnbuf, VBError, 0);
      return mwle_BADPARAM;
    }  
    
    /* want a non-empty input if filtering is applied*/
    if ( ((nrow*ncol) == 0) && (paraminfo->FilterType!=FTNone) ) {
	sprintf(warnbuf, "%s: Empty indexing vector", FUNCNAME);
	mwlPrintf(warnbuf, VBError, 0);
	return mwle_BADPARAM;
    }
    
    /* if parameter is not class double, we have a problem */
    if(paraminfo->FilterType != FTNone)
      if(paramclass != mxDOUBLE_CLASS) {
	sprintf(warnbuf, "%s: Expecting a class double parameter", FUNCNAME);
	mwlPrintf(warnbuf, VBError, 0);
	return mwle_BADPARAM;
      }
    
    /* if block, the parameter must have a certain dimension */
    if(paraminfo->FilterParamType == FPTBlock)
      if((ncol ) != 2) {
	sprintf(warnbuf, "%s: Expecting a 2 column matrix [start end] for block", FUNCNAME);
	mwlPrintf(warnbuf, VBError, 0);
	return mwle_BADPARAM;
      }
    
    /* if vector, none of the arguments can be negative */
    paramdata = mxGetData(param);
    for(j=0; j < nrow*ncol; j++)
      if(paramdata[j] < 0) {
	sprintf(warnbuf, "%s: Indices need to be non-negative", FUNCNAME);
	mwlPrintf(warnbuf, VBError, 0);
	return mwle_BADPARAM;
      }
    
  } else   /* if filtering, we need an indexing vector  */
    if(paraminfo->FilterType != FTNone) {
      sprintf(warnbuf, "%s: Expecting an indexing vector", FUNCNAME);    
      mwlPrintf(warnbuf, VBError, 0);
      return mwle_BADPARAM;
    } 

  if(paraminfo->FilterType == FTNone) {
    paraminfo->FilterParamType = FPTNone;
    sprintf(warnbuf, "%s: Defaulting to FilterParamType = None", FUNCNAME);    
    mwlPrintf(warnbuf, VBDetail, paraminfo->Verbose);
  }
  

  /* PRINT OUT INFORMATION */
  switch(paraminfo->FilterType) {
  case FTNone:
    sprintf(warnbuf, "%s: FilterType = %s", FUNCNAME, FSNone);
    break;
  case FTTimeStamp:
    sprintf(warnbuf, "%s: FilterType = %s", FUNCNAME, FSTimeStamp);
    break;
  case FTSeconds:
    sprintf(warnbuf, "%s: FilterType = %s", FUNCNAME, FSSeconds);	
    break;
  case FTSpikeID:
    sprintf(warnbuf, "%s: FilterType = %s", FUNCNAME, FSSpikeID);
    break;
  case FTRecordID:
    sprintf(warnbuf, "%s: FilterType = %s", FUNCNAME, FSRecordID);
    break;
  default:
    sprintf(warnbuf, "%s: FilterType = Unknown", FUNCNAME);    
    break;
  }
  mwlPrintf(warnbuf, VBDetail, paraminfo->Verbose);

  switch(paraminfo->FilterParamType) {
  case FPTBlock:
    sprintf(warnbuf, "%s: FilterParamType = %s", FUNCNAME, FPSBlock);
    break;
  case FPTArray:
    sprintf(warnbuf, "%s: FilterParamType = %s", FUNCNAME, FPSArray);
    break;
  default:
    sprintf(warnbuf, "%s: FilterParamType = %s", FUNCNAME, FPSNone);    
    break;
  }
  mwlPrintf(warnbuf, VBDetail,  paraminfo->Verbose);

  switch(paraminfo->RelativeStartIndex) {
  case RTStartIndex:
    sprintf(warnbuf, "%s: Indexing relative to previous index param = on", FUNCNAME);
    break;
  default:
    sprintf(warnbuf, "%s: Indexing relative to previous index param = off", FUNCNAME);
    break;
  }
  mwlPrintf(warnbuf, VBDetail,  paraminfo->Verbose);

  switch(paraminfo->RelativeFileStart) {
  case RTFileStart:
    sprintf(warnbuf, "%s: Indexing relative to start of file = on", FUNCNAME);
    break;
  default:
    sprintf(warnbuf, "%s: Indexing relative to start of file = off", FUNCNAME);
    break;
  }
  mwlPrintf(warnbuf, VBDetail, paraminfo->Verbose);

  switch(paraminfo->DataFormat) {
  case DFTMatlabFormat:
    sprintf(warnbuf, "%s: Converting data to matlab default (double)", FUNCNAME);
    break;
  default:
    sprintf(warnbuf, "%s: Not Converting data, data precision will remain the same", FUNCNAME);
    break;
  }
  mwlPrintf(warnbuf, VBDetail, paraminfo->Verbose);

  switch(paraminfo->ReturnType) {
  case RETData:
    sprintf(warnbuf, "%s: Verbose level = %s", FUNCNAME, RESData);
    break;
  case RETNoData:
    sprintf(warnbuf, "%s: Verbose level = %s", FUNCNAME, RESNoData);
    break;
  default:
    sprintf(warnbuf, "%s: Specified Return Type is unknown", FUNCNAME);
    break;
  }

  switch(paraminfo->Verbose) {
  case VBWarning:
    sprintf(warnbuf, "%s: Verbose level = %s", FUNCNAME, VSWarning);
    break;
  case VBNormal:
    sprintf(warnbuf, "%s: Verbose level = %s", FUNCNAME, VSNormal);
    break;
  case VBDetail:
    sprintf(warnbuf, "%s: Verbose level = %s", FUNCNAME, VSDetail);
    break;
  default:
    sprintf(warnbuf, "%s: Verbose level = Unknown", FUNCNAME);
    break;
  }
  mwlPrintf(warnbuf, VBDetail, paraminfo->Verbose);
  

  return mwl_OK;

}

mwl_RESULT mwl_CheckFilterParamADIO(mwl_ParamInfo *paraminfo, 
				    const mxArray *InputFilterParams,
				    unsigned long StartTimeStamp,
				    unsigned long EndTimeStamp,
				    unsigned long StartSpikeIndex,
				    unsigned long EndSpikeIndex,
				    unsigned long nRecords,
				    unsigned long **FilterParamsOut,
				    int *nBlocks) {

  /* variables */
  char TempBuffer[mwl_MAXSTRING];
  unsigned long mrow, mcol, i, j;
  double *ParamPointer;
  unsigned long *FilterParams, *FilterParamsNew;

  char *validblocks=NULL;
  int sb2inb1=0, sb1inb2=0, eb2inb1=0, eb1inb2=0;
  int nValidBlocks, BlockCount;

  /* check inputs */
  if((paraminfo == NULL)||(InputFilterParams == NULL)||(FilterParamsOut == NULL)) {
    sprintf(TempBuffer,"%s: NULL Input\n", FUNCNAME2);
    mwlPrintf(TempBuffer, VBError, 0);
    return mwle_BADPARAM;
  }

  nValidBlocks = 0;
  *nBlocks = 0;

  /* copy, convert to unsigned long, and check filter parameters if filter type != FTNone */
  if (paraminfo->FilterType != FTNone) {

    mrow = mxGetM(InputFilterParams);
    mcol = mxGetN(InputFilterParams);

    *nBlocks = mrow*mcol;

    *FilterParamsOut = mxCalloc(mrow*mcol, sizeof(long));
    FilterParams = *FilterParamsOut;
    ParamPointer = mxGetData(InputFilterParams);


    /* convert parameters to long */
    for(i=0; i < mrow; i++)
      for(j=0; j < mcol; j++)
	switch(paraminfo->FilterType) {
	case FTSeconds:
	  FilterParams[M2D(i,j,mrow)] = (long)(ParamPointer[M2D(i,j,mrow)]*mwl_MASTERCLOCKFREQ);
	  break;
	case FTTimeStamp:
	case FTSpikeID:
	case FTRecordID:
	  FilterParams[M2D(i,j,mrow)] = (long)(ParamPointer[M2D(i,j,mrow)]);
	  break;
	}

    /* do the relative to previous index thing */
    if (paraminfo->RelativeStartIndex == RTStartIndex) {
      if (paraminfo->FilterParamType == FPTArray) {
	for (i=1; i<(mrow*mcol); i++) {
	  FilterParams[i] += FilterParams[i-1] - 1;
	}
      } else if (paraminfo->FilterParamType == FPTBlock) {
	if ( (paraminfo->FilterType == FTTimeStamp) || (paraminfo->FilterType == FTSeconds) ) {
	  for (i=0; i<mrow; i++) {
	    FilterParams[M2D(i,1,mrow)] += FilterParams[M2D(i,0,mrow)];
	  }
	} else if ( (paraminfo->FilterType == FTSpikeID) || (paraminfo->FilterType == FTRecordID) ) {
	  for (i=0; i<mrow; i++) {
	    FilterParams[M2D(i,1,mrow)] += FilterParams[M2D(i,0,mrow)] - 1;
	  }
	}
      }
    }

    /* do the relative to file start thing, but only if filter type = seconds or timestamp */
    if (paraminfo->RelativeFileStart == RTFileStart) {
      if ( (paraminfo->FilterType == FTTimeStamp) || (paraminfo->FilterType == FTSeconds) ) {
	for (i=0; i<mrow; i++) {
	  FilterParams[M2D(i,0,mrow)] += StartTimeStamp;
	  FilterParams[M2D(i,1,mrow)] += StartTimeStamp;
	}
      }
    }


    /* if block, check to see if parameters are in right order */
    if (paraminfo->FilterParamType == FPTBlock) {
      for (i=0; i<mrow; i++) {
	if (FilterParams[M2D(i,0,mrow)] > FilterParams[M2D(i,1,mrow)]) {
	  sprintf(TempBuffer, "%s: invalid argument, lower and upper bound should be switched\n", FUNCNAME2); 
	  mwlPrintf(TempBuffer, VBError, paraminfo->Verbose);
	  return mwle_BADPARAM;
	}
      }
    }

    /* make union of blocks */
    if (paraminfo->FilterParamType == FPTBlock) {
      validblocks = mxCalloc(mrow, sizeof(char));
      for (i=0; i<mrow; i++)
	validblocks[i]=1;

      for (i=0; i<mrow; i++) {
	for(j=0; j<mrow; j++) {
	  if (validblocks[j]==1 && validblocks[i]==1 && j!=i) {
	    sb2inb1 = (FilterParams[M2D(j,0,mrow)]<=FilterParams[M2D(i,1,mrow)] && FilterParams[M2D(i, 0, mrow)]<=FilterParams[M2D(j,0,mrow)]);
	    sb1inb2 = (FilterParams[M2D(i,0,mrow)]<=FilterParams[M2D(j,1,mrow)] && FilterParams[M2D(j, 0, mrow)]<=FilterParams[M2D(i,0,mrow)]);
	    eb2inb1 = (FilterParams[M2D(j,1,mrow)]<=FilterParams[M2D(i,1,mrow)] && FilterParams[M2D(i, 0, mrow)]<=FilterParams[M2D(j,1,mrow)]);
	    eb1inb2 = (FilterParams[M2D(i,1,mrow)]<=FilterParams[M2D(j,1,mrow)] && FilterParams[M2D(j, 0, mrow)]<=FilterParams[M2D(i,1,mrow)]);

	    if (sb2inb1 && eb1inb2) {
	      FilterParams[M2D(i,1,mrow)] = FilterParams[M2D(j, 1, mrow)];
	      validblocks[j]=0;
	    } else if (sb2inb1 && eb2inb1) {
	      validblocks[j]=0;
	    } else if (sb1inb2 && eb2inb1) {
	      FilterParams[M2D(i,0,mrow)] = FilterParams[M2D(j,0,mrow)];
	      validblocks[j] = 0;
	    } else if (sb1inb2 && eb1inb2) {
	      validblocks[i]=0;
	    }
	  }
	}
      }


      /* now check if blocks are in file and correct boundaries if necessary*/
      switch (paraminfo->FilterType) {
      case FTTimeStamp:
      case FTSeconds:
	for (i=0; i<mrow; i++) {
	  if (validblocks[i]==1) {
	    if ( (FilterParams[M2D(i,0,mrow)]<StartTimeStamp && FilterParams[M2D(i,1,mrow)]<StartTimeStamp) ||  (FilterParams[M2D(i,0,mrow)]>EndTimeStamp && FilterParams[M2D(i,1,mrow)]>EndTimeStamp) ) {
	      sprintf(TempBuffer, "%s: Block out of bounds", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      validblocks[i] = 0;
	    } else if (FilterParams[M2D(i,0,mrow)] < StartTimeStamp) {
	      sprintf(TempBuffer, "%s: Start of block out of bounds. Corrected", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      FilterParams[M2D(i,0,mrow)] = StartTimeStamp;
	    } else if (FilterParams[M2D(i,1,mrow)]>EndTimeStamp) {
	      sprintf(TempBuffer, "%s: End of block out of bounds. Corrected", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      FilterParams[M2D(i,1,mrow)] = EndTimeStamp;
	    }
	  }
	}
	break;
      case FTSpikeID:
	for (i=0; i<mrow; i++) {
	  if (validblocks[i]==1) {
	    if ( (FilterParams[M2D(i,0,mrow)]<StartSpikeIndex && FilterParams[M2D(i,1,mrow)]<StartSpikeIndex) ||  (FilterParams[M2D(i,0,mrow)]>EndSpikeIndex && FilterParams[M2D(i,1,mrow)]>EndSpikeIndex) ) {
	      sprintf(TempBuffer, "%s: Block out of bounds", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      validblocks[i] = 0;
	    } else if (FilterParams[M2D(i,0,mrow)] < StartSpikeIndex) {
	      sprintf(TempBuffer, "%s: Start of block out of bounds. Corrected", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      FilterParams[M2D(i,0,mrow)] = StartSpikeIndex;
	    } else if (FilterParams[M2D(i,1,mrow)]>EndSpikeIndex) {
	      sprintf(TempBuffer, "%s: End of block out of bounds. Corrected", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      FilterParams[M2D(i,1,mrow)] = EndSpikeIndex;
	    }
	  }
	}
	break;
      case FTRecordID:
	for (i=0; i<mrow; i++) {
	  if (validblocks[i]==1) {
	    if ( (FilterParams[M2D(i,0,mrow)]<1 && FilterParams[M2D(i,1,mrow)]<1) ||  (FilterParams[M2D(i,0,mrow)]>nRecords && FilterParams[M2D(i,1,mrow)]>nRecords) ) {
	      sprintf(TempBuffer, "%s: Block out of bounds", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      validblocks[i] = 0;
	    } else if (FilterParams[M2D(i,0,mrow)] < 1) {
	      sprintf(TempBuffer, "%s: Start of block out of bounds. Corrected", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      FilterParams[M2D(i,0,mrow)] = 1;
	    } else if (FilterParams[M2D(i,1,mrow)]>nRecords) {
	      sprintf(TempBuffer, "%s: End of block out of bounds. Corrected", FUNCNAME2);
	      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	      FilterParams[M2D(i,1,mrow)] = nRecords;
	    }
	  }
	}
	break;
      }


      /* copy valid blocks */
      nValidBlocks=0;
      for (i=0; i<mrow; i++)
	if (validblocks[i] == 1)
	  nValidBlocks++;
      

      if (nValidBlocks==0) {
	sprintf(TempBuffer, "%s: No valid blocks", FUNCNAME2);
	mwlPrintf(TempBuffer, VBError, 0);
	return mwle_BADPARAM;
      } else {
	FilterParamsNew = mxCalloc(nValidBlocks*mcol, sizeof(long));
	
	BlockCount = 0;
	for (i=0; i<mrow; i++) {
	  if (validblocks[i] == 1) {
	    FilterParamsNew[M2D(BlockCount, 0, nValidBlocks)] = FilterParams[M2D(i, 0, mrow)];
	    FilterParamsNew[M2D(BlockCount, 1, nValidBlocks)] = FilterParams[M2D(i, 1, mrow)];
	    BlockCount++;
	  }
	}

	/*mxFree(FilterParams);*/
	*FilterParamsOut = FilterParamsNew;
	FilterParams = *FilterParamsOut;

	*nBlocks = nValidBlocks;
      }


    }


    /* check indices if filter parameter type = array */
    if (paraminfo->FilterParamType == FPTArray) {

      switch (paraminfo->FilterType) {
      case FTSpikeID:
	for (i=0; i<mrow*mcol; i++) {
	  if (FilterParams[i]<StartSpikeIndex || FilterParams[i]>EndSpikeIndex) {
	    sprintf(TempBuffer, "%s: Index out of bound", FUNCNAME2);
	    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	  }
	}
	break;
      case FTRecordID:
	for (i=0; i<mrow*mcol; i++) {
	  if (FilterParams[i]<1 || FilterParams[i]>nRecords) {
	    sprintf(TempBuffer, "%s: Index out of bound", FUNCNAME2);
	    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
	  }
	}
	break;
      }
    }

  }

  return mwl_OK;

}

