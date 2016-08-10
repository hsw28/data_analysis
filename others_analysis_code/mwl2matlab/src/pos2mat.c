/******************************************************************************
 
Filename: pos2mat.c

Function: mexFunction(int nlhs, mxArray *plhs[], int rhs, const mxArray *prhs[])

Input: 
  
 Filename     [string]       required
 Parameter Sting [string]    optional
 Index Vector                optional, but required if filtering ia applied
 
Output:

 Posdata [structure]
     nitems [vector]
     frame [vector]
     timestamp [vector]
     pos [structure]
          x [vector]
          y [vector]
     info [structure]
`
Description:
 
 This function reads in RAW camera pixel threshold crossings.

Author:

 David P. Nguyen <dpnguyen@mit.edu>, Fabian Kloosterman <fkloos@mit.edu>

$Id: pos2mat.c,v 1.17 2004/11/07 05:00:51 fabian Exp $

******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>
#include "mwlIOLib.h"
#include "mwlAPItypes.h"

/* macro to convert 2d indices to a single index */
#define M2D(r,c,R) (r + c*R)

#define FUNCNAME "pos2mat"

const char *usage1 = "USAGE: \nposdata = pos2mat(FileName, Parameter String, Indexing Information)\n";

const char *field_names[] = {"nitems", "frame", "timestamp", "pos", "info"};
enum FieldNumbers {NITEM_F = 0, FRAME_F, TIMESTAMP_F, POS_F, INFO_F, N_FIELDS};
const char *field_names2[] = {"source", "mwltype", "createdate", "createfunc", "units", "nchans", "samplingfreq"};
enum Field2Numbers {SOURCE_F=0, MWLTYPE_F, DATE_F, CREATEFUNC_F, UNITS_F, NCHANS_F, SAMPLEFREQ_F,  N_FIELDS2};
const char *field_names3[] = {"x", "y"};
enum Field3Number {X_F, Y_F, N_FIELDS3};
const char *field_names4[] = {"timestamp", "id", "info"};
enum Field4Numbers{TIMESTAMP_F4, ID_F4, INFO_F4, N_FIELDS4};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{


  /* General Variables */
  FILE *InFD = NULL;
  char TempBuffer[mwl_MAXSTRING];
  char *DateBuffer;
  mwl_FILEINFO fileinfo;
  mwl_RESULT result;
  mwl_ParamInfo ParamInfo, *paraminfo;
  time_t TSeconds;
  int row = 0;
  long i;

  /* process file variables */
  unsigned long EndOfFile, tempPos, bytecount;
  unsigned long nFrames = 0;
  unsigned long RecordCount = 0;
  unsigned long FrameCount = 0;
  unsigned long ReadDataCount = 0;  /* number of points to read in */
  unsigned long TimeStamp, StartTimeStamp, EndTimeStamp;
  double StartTime, EndTime;
  unsigned char nitems;
  unsigned char frame;


  /* Read-in Data Variables */
  int ndim, *dims, nfields;
  mxArray *outstruct, *tempArray, *infostruct, *posstruct;
  unsigned long iter, itercoord;
  unsigned short xcoord, *xptrS;
  unsigned char ycoord, *yptrC;
  double *xptr, *yptr;
  double *nitemsout, *frameout, *timestampout, *idout;
  unsigned char *nitemsoutC, *frameoutC;
  int nBlocks;
  unsigned long *OffsetArray = NULL;


  /* Filter Parameter Variables */
  unsigned long *FilterParams = NULL;
  unsigned long *ReadDataTable = NULL;


  /* create default empty matrices for each output variable */
  for (i=0; i<nlhs; i++) {
    plhs[i] = mxCreateDoubleMatrix(0,0,mxREAL);
  }

  dims = mxCalloc(3, sizeof(int));
  paraminfo = &ParamInfo;

  /* input arguments */
  if(nrhs < 1) {
    mwlPrintf(usage1, VBError, 0); 
    mwl_ParseFilterParamUsage();
    return;
  }
  
  /* check to see if first argument is a file name */
  if(mxGetClassID(prhs[0]) != mxCHAR_CLASS) {
    sprintf(TempBuffer, "%s: First Argument must be a string", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    return;
  }

  /* do the parameters */
  if(nrhs > 2) {
    if(mwl_ParseFilterParamADIO(prhs[1], prhs[2], paraminfo) < 0) {
      sprintf(TempBuffer,"%s: Encountered error, exiting", FUNCNAME);
      mwlPrintf(TempBuffer, VBError, 0);
      return;
    }
  }else if(nrhs > 1) {
    if(mwl_ParseFilterParamADIO(prhs[1], NULL, paraminfo) < 0) {
      sprintf(TempBuffer,"%s: Encountered error, exiting", FUNCNAME);
      mwlPrintf(TempBuffer, VBError, 0);
      return;
    }
  } else {
    if(mwl_ParseFilterParamADIO(NULL, NULL, paraminfo) < 0) {
      sprintf(TempBuffer,"%s: Encountered error, exiting", FUNCNAME);
      mwlPrintf(TempBuffer, VBError, 0);
      return;
    }
  }

  /* only support some filter types */
  switch(paraminfo->FilterType) {
  case FTNone:
  case FTTimeStamp:
  case FTSeconds:
  case FTRecordID:
    break;
  default:
    sprintf(TempBuffer,"%s: Unsupported Filter Type", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    return;
  }

  /* try to open the file */
  mxGetString(prhs[0], TempBuffer, mwl_MAXSTRING);
  if((InFD = fopen(TempBuffer, "r")) == NULL) {
    sprintf(TempBuffer, "%s: Cannot open input file", FUNCNAME); 
    mwlPrintf(TempBuffer, VBError, 0);
    return;
  }
    
  /* we have the file open, now make sure it is the right file */
  result = mwl_GetFileInfo(InFD, &fileinfo);
  if(result != mwl_OK) {
    sprintf(TempBuffer, "%s: Unable to retrieve file information", FUNCNAME); 
    mwlPrintf(TempBuffer, VBError,    0);
    return;
  }
  
  /* is it a .pos file? */
  if(fileinfo.dwFileType != mwl_FILETYPE_RAWPOS) {
    sprintf(TempBuffer, "%s: This is not a raw tracker file (extended dual diode position).", FUNCNAME);
    mwlPrintf(TempBuffer, VBError,    0);
    return;
  }

  /* is it a binary file? */
  if(fileinfo.dwIsBinary == 0) {
    sprintf(TempBuffer, "%s: This is not a binary file", FUNCNAME); 
    mwlPrintf(TempBuffer, VBError,    0);
    return;
  }
  
  /* get preliminary info about file */
  /* move to the start of the data */
  fseek(InFD, 0, SEEK_END);
  EndOfFile = ftell(InFD);
  nFrames = 0;

  fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
  bytecount = fileinfo.dwHeaderSize;
  
  clearerr(InFD);

  /* TRACKER D1933ATA
     Nitems, Frame, TimeStamp, Data[Nitems] */
  fread(&nitems, sizeof(char), 1, InFD);
  fread(&frame, sizeof(char), 1, InFD);
  fread(&StartTimeStamp, sizeof(long), 1, InFD);
  tempPos = ftell(InFD) + nitems*(sizeof(char)+sizeof(short));
  fseek(InFD, tempPos, SEEK_SET);

  bytecount += 6 + nitems*3;

  nFrames = 1;
  while(1) {
    if(fread(&nitems, sizeof(unsigned char), 1, InFD) < 0)
      break;
    if(fread(&frame, sizeof(unsigned char), 1, InFD) < 0)
      break;
    if(fread(&EndTimeStamp, sizeof(long), 1, InFD) < 0)
      break;
    
    tempPos += 6 + nitems*(sizeof(char)+sizeof(short));

    if(tempPos >  EndOfFile)
      break;

    bytecount += 2+4+nitems*3;
    nFrames++;    
    fseek(InFD, tempPos, SEEK_SET);
  }


  /* loop again to get all offsets */
  OffsetArray = mxCalloc(nFrames, sizeof(unsigned long));
  OffsetArray[0] = fileinfo.dwHeaderSize;

  for (i=1; i<nFrames; i++) {
    fseek(InFD, OffsetArray[i-1], 0);
    fread(&nitems, sizeof(unsigned char), 1, InFD);
    OffsetArray[i] += OffsetArray[i-1] + 6 + nitems*(sizeof(char)+sizeof(short));
  }


  StartTime = ((double)StartTimeStamp)/mwl_MASTERCLOCKFREQ;
  EndTime = ((double)EndTimeStamp)/mwl_MASTERCLOCKFREQ;

  sprintf(TempBuffer,"%s: Header Ends at %d\n", FUNCNAME, fileinfo.dwHeaderSize);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: Start Time = %.3lf sec, End Time = %.3lf sec\n", FUNCNAME, StartTime, EndTime);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: StartTimeStamp = %ld, EndTimeStamp = %ld\n", FUNCNAME, StartTimeStamp, EndTimeStamp);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: Number of Frames = %ld, Bytes Available = %ld/%ld\n", FUNCNAME, nFrames, bytecount, EndOfFile);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);


  if(bytecount != EndOfFile) {
    sprintf(TempBuffer, "%s: Skipping last erroneous frame\n", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
  }
  
  
  /***************************** PROCESS PARAMETERS ***************************/
  sprintf(TempBuffer,"%s: Processing parameters\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  nBlocks = 0;
  if(mwl_CheckFilterParamADIO(paraminfo, prhs[2], StartTimeStamp, EndTimeStamp, 0, 0, nFrames, &FilterParams, &nBlocks) < 0)
    return;

  
  /*********************************** allocate read data table *****************************/

  sprintf(TempBuffer,"%s: Determining what data to read in.\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  if(paraminfo->FilterType == FTNone) {

    ReadDataTable = mxCalloc(sizeof(long),(nFrames));
    ReadDataCount = 0;

    for(FrameCount = 0; FrameCount < nFrames; FrameCount++)
      ReadDataTable[FrameCount] = FrameCount;
    
    ReadDataCount = nFrames;
  } else {

  
    if(paraminfo->FilterParamType == FPTBlock) {

      ReadDataTable = mxCalloc(sizeof(long),(nFrames));
      RecordCount = 0;
      ReadDataCount = 0;

      if((paraminfo->FilterType == FTSeconds)||
	 (paraminfo->FilterType == FTTimeStamp)) {
	
	fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
	tempPos = fileinfo.dwHeaderSize;
	clearerr(InFD);
	FrameCount = 0;
	while(1) {
	  
	  fread(&nitems, sizeof(unsigned char), 1, InFD);
	  fread(&frame, sizeof(unsigned char), 1, InFD);
	  fread(&TimeStamp, sizeof(long), 1, InFD);
	  tempPos += 6 + nitems*(sizeof(char)+sizeof(short));
	  fseek(InFD, tempPos, SEEK_SET);
	  
	  for(row = 0; row < nBlocks; row++)
	    if((TimeStamp >= FilterParams[M2D(row,0,nBlocks)]) && 
	       (TimeStamp <= FilterParams[M2D(row,1,nBlocks)])) {
	      ReadDataTable[ReadDataCount] = FrameCount;
	      ReadDataCount++;
	    }
	  
	  FrameCount++;
	  if(FrameCount == nFrames)
	    break;
	}
      } else if(paraminfo->FilterType == FTRecordID) {
	
	for(FrameCount = 1; FrameCount <= nFrames; FrameCount++) {
	  for(row = 0; row < nBlocks; row++)
	    if((FrameCount >= FilterParams[M2D(row,0,nBlocks)]) && 
	       (FrameCount <= FilterParams[M2D(row,1,nBlocks)])) {
	      ReadDataTable[ReadDataCount] = FrameCount-1;
	      ReadDataCount++;
	    }
	}
      } 
    } else if(paraminfo->FilterParamType == FPTArray) {
      
      ReadDataTable = mxCalloc(sizeof(long),(nBlocks));
      ReadDataCount = 0;
      RecordCount = 0;

      for(i = 0; i < nBlocks; i++) {

	if((FilterParams[i] >= 1) && (FilterParams[i] <= nFrames)) {
	  ReadDataTable[ReadDataCount] = FilterParams[i]-1;
	  ReadDataCount ++;
	}
      }
    }
  }
      
  /*********************************************************************
   * Now that we know which samples to read in, read in the data
   */

  if(paraminfo->ReturnType == RETNoData) {

    FrameCount = 0;
    fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);

    ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS4;
    outstruct = mxCreateStructArray(ndim, dims, nfields, field_names4);  
    plhs[0] = outstruct;
    iter = 0;
  
    tempArray = mxCreateDoubleMatrix(ReadDataCount,1,mxREAL);
    mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F4, tempArray);
    timestampout = mxGetData(tempArray);

    tempArray = mxCreateDoubleMatrix(ReadDataCount,1,mxREAL);
    mxSetFieldByNumber(outstruct, 0, ID_F4, tempArray);
    idout = mxGetData(tempArray);
      
    for (i=0; i<ReadDataCount; i++) {
      
      fseek(InFD, OffsetArray[ReadDataTable[i]], 0);
      
      fread(&nitems, sizeof(unsigned char), 1, InFD);
      fread(&frame, sizeof(unsigned char), 1, InFD);	
      fread(&TimeStamp, sizeof(unsigned long), 1, InFD);
      timestampout[i] = (double) TimeStamp/mwl_MASTERCLOCKFREQ;
      idout[i] = (double)ReadDataTable[i];

    }

  } else {

    FrameCount = 0;
    fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);

    ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS;
    outstruct = mxCreateStructArray(ndim, dims, nfields, field_names);

    ndim = 2; dims[0] = ReadDataCount; dims[1] = 1; nfields = N_FIELDS3;
    posstruct = mxCreateStructArray(ndim, dims, nfields, field_names3);
    mxSetFieldByNumber(outstruct, 0, POS_F, posstruct);
  
    plhs[0] = outstruct;
    iter = 0;

    if(paraminfo->DataFormat == DFTMatlabFormat) {
    
      sprintf(TempBuffer,"%s: Allocating and Reading in Data (#Frames = %ld)\n", FUNCNAME, ReadDataCount);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);
  
      tempArray = mxCreateDoubleMatrix(ReadDataCount,1,mxREAL);
      mxSetFieldByNumber(outstruct, 0, NITEM_F, tempArray);
      nitemsout = mxGetData(tempArray);
    
      tempArray = mxCreateDoubleMatrix(ReadDataCount,1,mxREAL);
      mxSetFieldByNumber(outstruct, 0, FRAME_F, tempArray);
      frameout = mxGetData(tempArray);

      tempArray = mxCreateDoubleMatrix(ReadDataCount,1,mxREAL);
      mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F, tempArray);
      timestampout = mxGetData(tempArray);
    
      for (i=0; i<ReadDataCount; i++) {
      
	fseek(InFD, OffsetArray[ReadDataTable[i]], 0);
      
	fread(&nitems, sizeof(unsigned char), 1, InFD);
	nitemsout[i] = (double)nitems;

	fread(&frame, sizeof(unsigned char), 1, InFD);
	frameout[i] = (double)frame;
	
	fread(&TimeStamp, sizeof(unsigned long), 1, InFD);
	timestampout[i] = (double) TimeStamp/mwl_MASTERCLOCKFREQ;
      
	/* arrays for coords */
	tempArray = mxCreateDoubleMatrix(nitems,1,mxREAL);
	xptr = mxGetData(tempArray);
	mxSetFieldByNumber(posstruct, i, X_F, tempArray);
	
	tempArray = mxCreateDoubleMatrix(nitems,1,mxREAL);
	yptr = mxGetData(tempArray);
	mxSetFieldByNumber(posstruct, i, Y_F, tempArray);
	
	for(itercoord = 0; itercoord < nitems; itercoord++) {
	  fread(&xcoord, sizeof(unsigned short), 1, InFD);
	  fread(&ycoord, sizeof(unsigned char), 1, InFD);
	  xptr[itercoord] = (double)xcoord;
	  yptr[itercoord] = (double)ycoord;
	}
	
      }

    
    } else {
    
      sprintf(TempBuffer,"%s: Allocating and Reading in Data (#Frames = %ld)\n", FUNCNAME, ReadDataCount);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

      ndim = 2; dims[0] = ReadDataCount; dims[1] = 1; 
      tempArray = mxCreateNumericArray(ndim, dims, mxUINT8_CLASS, mxREAL);
      mxSetFieldByNumber(outstruct, 0, NITEM_F, tempArray);
      nitemsoutC = mxGetData(tempArray);

      tempArray = mxCreateNumericArray(ndim, dims, mxUINT8_CLASS, mxREAL);
      mxSetFieldByNumber(outstruct, 0, FRAME_F, tempArray);
      frameoutC = mxGetData(tempArray);

      tempArray = mxCreateDoubleMatrix(ReadDataCount,1,mxREAL);
      mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F, tempArray);
      timestampout = mxGetData(tempArray);


      for (i=0; i<ReadDataCount; i++) {
      
	fseek(InFD, OffsetArray[ReadDataTable[i]], 0);
	
	fread(&nitems, sizeof(unsigned char), 1, InFD);
	nitemsoutC[i] = nitems;

	fread(&frame, sizeof(unsigned char), 1, InFD);
	frameoutC[i] = frame;
	
	fread(&TimeStamp, sizeof(unsigned long), 1, InFD);
	timestampout[i] = (double) TimeStamp/mwl_MASTERCLOCKFREQ;

	/* arrays for coords */
	ndim = 2; dims[0] = nitems; dims[1] = 1; 
	tempArray = mxCreateNumericArray(ndim, dims, mxUINT16_CLASS, mxREAL);
	mxSetFieldByNumber(posstruct, i, X_F, tempArray);
	xptrS = mxGetData(tempArray);
      
	tempArray = mxCreateNumericArray(ndim, dims, mxUINT8_CLASS, mxREAL);
	mxSetFieldByNumber(posstruct, i, Y_F, tempArray);
	yptrC = mxGetData(tempArray);
	
	for(itercoord = 0; itercoord < nitems; itercoord++) {
	  fread(&xcoord, sizeof(unsigned short), 1, InFD);
	  fread(&ycoord, sizeof(unsigned char), 1, InFD);
	  xptrS[itercoord] = xcoord;
	  yptrC[itercoord] = ycoord;
	}
      
      }
       
    }
  }

  /************* CREATE INFO STRUCTURE AND SET IT **********/
  ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS2;
  infostruct = mxCreateStructArray(ndim, dims, nfields, field_names2);

  if(paraminfo->ReturnType == RETNoData)
    mxSetFieldByNumber(outstruct, 0, INFO_F4, infostruct);
  else
    mxSetFieldByNumber(outstruct, 0, INFO_F, infostruct);

  mxSetFieldByNumber(infostruct, 0, SOURCE_F,
		     mwl_FileSourceStructure(InFD, FUNCNAME, paraminfo));

  mxSetFieldByNumber(infostruct, 0, MWLTYPE_F, mxCreateString(MWLTS_DIODEPOSITION));

  time(&TSeconds);
  DateBuffer = ctime(&TSeconds); 
  mxSetFieldByNumber(infostruct, 0, DATE_F,
		     mxCreateString(DateBuffer));

  mxSetFieldByNumber(infostruct, 0, CREATEFUNC_F,
		     mxCreateString(FUNCNAME));

  mxSetFieldByNumber(infostruct, 0, UNITS_F, 
		     mxCreateString("pixels"));

  mxSetFieldByNumber(infostruct, 0, NCHANS_F, 
		     mxCreateDoubleScalar(2.0f));

  mxSetFieldByNumber(infostruct, 0, SAMPLEFREQ_F, 
		     mxCreateDoubleScalar((mwl_TRACKERCLOCKFREQ/2.0f)));

  /************* CLEAN UP ************************/
  sprintf(TempBuffer,"%s: Successful.\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);
  
  if(ReadDataTable != NULL)
    mxFree(ReadDataTable);
  if(FilterParams != NULL)
    mxFree(FilterParams);

  fclose(InFD);

  return;
}


/**********************************************************************
 *
 * $Log: pos2mat.c,v $
 * Revision 1.17  2004/11/07 05:00:51  fabian
 * replaced ctime_r call with ctime call (Windows compatibility reasons)
 *
 * Revision 1.16  2004/01/14 01:35:27  dpnguyen
 * updated output structures to include mwltype under each info field
 *
 * Revision 1.15  2003/12/12 03:24:12  dpnguyen
 * added the (+) and (-) options
 *
 * Revision 1.14  2003/12/09 21:41:39  dpnguyen
 * Fixed bug in pos2mat.c (RecordCount --> FrameCount)
 * Fixed time to timestamp in hte output structure
 *
 * Revision 1.13  2003/12/01 23:45:07  fabian
 * removed redundant code
 *
 * Revision 1.12  2003/12/01 21:08:07  fabian
 * updated to work with new mwl_CheckFilterParams
 * timestamps now always returned in seconds
 * array filtering improved: it returns the records in the order requested, not sorted
 *
 * Revision 1.11  2003/11/26 02:57:01  dpnguyen
 * implemented multi-block parameter types
 *
 * Revision 1.10  2003/11/26 02:36:58  dpnguyen
 * made updates for incorporating FTSpikeID
 * Checking to see if FTSpikeID is suppported
 *
 * Revision 1.9  2003/11/26 01:51:38  fabian
 * added record index as a filter type, changed #define FTSampleID to FTSpikeID, and updated p2mat, pos2mat, tt2mat
 *
 * Revision 1.8  2003/11/25 00:53:42  dpnguyen
 * brought code up to date with mwl_FileSourceStructure
 *
 * Revision 1.7  2003/11/23 17:25:56  dpnguyen
 * added support for preserving data precision
 * added support for information structure
 *
 * Revision 1.6  2003/11/21 18:55:07  dpnguyen
 * found a bug or two from the pos2mat.c to p2mat.c copy over
 *
 * Revision 1.5  2003/11/21 18:16:28  dpnguyen
 * copied code from pos2mat.c to p2mat.c, both work fairly well
 * pos2mat.c and p2mat.c differ in behavior when filter param is array type,
 * pos2mat will not produce duplicate entries
 *
 * Revision 1.4  2003/11/21 06:48:58  dpnguyen
 * rewrote a good portion of pos2mat.c, the logic is much better, the
 * print statments conform to mwlPrintf standards, relative indexing
 * if fully implemented.
 *
 * Revision 1.3  2003/11/21 04:17:18  dpnguyen
 * fixed up more filter parameter settings
 * and the mwlPrintf function
 * pos2mat.c is know verified to be working correctly
 *
 * Revision 1.2  2003/11/18 06:32:37  dpnguyen
 * I added a byte counter to make sure all teh data in the file was being
 * read correctly, turns out it is.  I'm not sure where the missing frames
 * are going, maybay they aren't  there are maybe matt's code compensates
 * for it somehow.
 *
 * Revision 1.1  2003/11/11 06:03:06  dpnguyen
 * restarting the repository once again
 * boy, what a bunch of amateurs
 *
 *
 */
