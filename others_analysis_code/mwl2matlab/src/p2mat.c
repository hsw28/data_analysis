/******************************************************************************
 
Filename: p2mat.c

Function: mexFunction(int nlhs, mxArray *plhs[], int rhs, const mxArray *prhs[])

Input: 

 Filename [string]                           required
 ParameterString [string]                    optional
 Index Vector                                optional, but required if filtering is applied
 
Output:

 PData [structure]
     frame [vector]
     timestamp [vector]
     x [vector]
     y [vector]
     frame0 [string]
     frame1 [string]
     info

Description:
 
The function reads in p-files - the output of Matt's posextract function

Author:

 David P. Nguyen <dpnguyen@mit.edu>, Fabian Kloosterman <fkloos@mit.edu>

$Id: p2mat.c,v 1.13 2004/12/07 01:47:46 fabian Exp $

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

#define FUNCNAME "p2mat"

const char *usage1 = "USAGE: \npdata = p2mat(P-FileName, Parameter String, Indexing Information)\n";

const char *field_names[] = {"frame", "timestamp", "x", "y", "frame0", "frame1", "info"};
enum FieldNumbers {FRAME_F=0, TIMESTAMP_F, X_F, Y_F, FRAME0_F, FRAME1_F, INFO_F,  N_FIELDS};
const char *field_names2[] = {"source", "mwltype", "createdate", "createfunc", "units", "nchans", "samplingfreq"};
enum Field2Numbers {SOURCE_F=0, MWLTYPE_F, DATE_F, CREATEFUNC_F, UNITS_F, NCHANS_F, SAMPLEFREQ_F,  N_FIELDS2};
const char *field_names3[] = {"timestamp", "id", "info"};
enum Field3Numbers {TIMESTAMP_F3, ID_F3, INFO_F3, N_FIELDS3};

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
  int row;
  long i;

  /* Read-in Data Variables */
  unsigned long EndOfFile, tempPos, bytecount;
  unsigned long nFrames = 0;
  unsigned long FrameCount = 0;
  unsigned long RecordLength = 0;
  unsigned long ReadDataCount = 0;  /* number of points to read in */
  unsigned long StartOfData, TimeStamp, StartTimeStamp, EndTimeStamp;
  double StartTime, EndTime;
  unsigned short TempShort;
  int nBlocks = 0;

  /* output structure parameters */
  int ndim, *dims, nfields;
  mxArray *outstruct, *tempArray, *infostruct;
  long iter;
  double *Timestamp0, *IDArray;
  double *Frame0X, *Frame0Y, *Frameout;
  unsigned char *FrameoutC;
  unsigned short *Frame0XS, *Frame0YS;

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
  
  /* is it a .p file? */
  if(fileinfo.dwFileType != mwl_FILETYPE_DIODE) {
    sprintf(TempBuffer, "%s: This is not a dual diode data file (output of posextract).", FUNCNAME);
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

  fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
  bytecount = fileinfo.dwHeaderSize;
  
  clearerr(InFD);

  /* get preliminary info about file */
  /* move to the start of the data */
  RecordLength = sizeof(long) + sizeof(short)*4;
  fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
  StartOfData = ftell(InFD);
  fseek(InFD, 0, SEEK_END);
  EndOfFile = ftell(InFD);

  fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);

  nFrames = (EndOfFile - StartOfData)/RecordLength;
  bytecount = RecordLength*nFrames + fileinfo.dwHeaderSize;

  
  /* timestamp (long), xfront(short), yfront(short), xback(short), yback(short) */
  fread(&StartTimeStamp, sizeof(long), 1, InFD);
  fseek(InFD, -RecordLength, SEEK_END);
  fread(&EndTimeStamp, sizeof(long), 1, InFD);
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


  /***************************** PROCESS PARAMETERS ***************************/
  sprintf(TempBuffer,"%s: Processing parameters\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);
  
  nBlocks = 0;
  if(mwl_CheckFilterParamADIO(paraminfo, prhs[2], StartTimeStamp, EndTimeStamp,0,0, nFrames, &FilterParams,&nBlocks) < 0)
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
      ReadDataCount = 0;

      if((paraminfo->FilterType == FTSeconds)||
	 (paraminfo->FilterType == FTTimeStamp)) {
	
	fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
	tempPos = fileinfo.dwHeaderSize;
	clearerr(InFD);
	FrameCount = 0;
	while(1) {
	  
	  fread(&TimeStamp, sizeof(long), 1, InFD);
	  fseek(InFD, 4*sizeof(short), SEEK_CUR);
	  
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

      for(i = 0; i < nBlocks; i++) {
	if((FilterParams[i] >= 1) && (FilterParams[i] <= nFrames)) {
	  ReadDataTable[ReadDataCount] = FilterParams[i]-1;
	  ReadDataCount++;
	}       
      }
    }
  }
  

  /*********************************************************************
   * Now that we know which samples to read in, read in the data
   */

  /*** return timestamps only or timestamps with data ***/
  if(paraminfo->ReturnType == RETNoData) {

    ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS3;
    outstruct = mxCreateStructArray(ndim, dims, nfields, field_names3);
    plhs[0] = outstruct;

    tempArray = mxCreateDoubleMatrix(ReadDataCount, 1, mxREAL);
    Timestamp0 = mxGetPr(tempArray);
    mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F3, tempArray);

    tempArray = mxCreateDoubleMatrix(ReadDataCount, 1, mxREAL);
    IDArray = mxGetPr(tempArray);
    mxSetFieldByNumber(outstruct, 0, ID_F3, tempArray);

    for(i = 0; i < ReadDataCount; i++) {
      iter = ReadDataTable[i];

      fseek(InFD, fileinfo.dwHeaderSize + iter*RecordLength, SEEK_SET);      
      fread(&TimeStamp, sizeof(long), 1, InFD);
      Timestamp0[i] = (double)TimeStamp/mwl_MASTERCLOCKFREQ;
      IDArray[i] = (double)iter;
    }

  } else {


    if(paraminfo->DataFormat == DFTMatlabFormat) {
 
      sprintf(TempBuffer,"%s: Allocating memory for %ld cycles.\n", FUNCNAME, ReadDataCount);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);
  
      ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS;
      outstruct = mxCreateStructArray(ndim, dims, nfields, field_names);
      plhs[0] = outstruct;

      mxSetFieldByNumber(outstruct, 0, FRAME0_F, mxCreateString("front"));
      mxSetFieldByNumber(outstruct, 0, FRAME1_F, mxCreateString("back"));

      tempArray = mxCreateDoubleMatrix(ReadDataCount*2, 1, mxREAL);
      Frameout = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, FRAME_F, tempArray);

      tempArray = mxCreateDoubleMatrix(ReadDataCount*2, 1, mxREAL);
      Timestamp0 = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F, tempArray);

      tempArray = mxCreateDoubleMatrix(ReadDataCount*2, 1, mxREAL);
      Frame0X = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, X_F, tempArray);

      tempArray = mxCreateDoubleMatrix(ReadDataCount*2, 1, mxREAL);
      Frame0Y = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, Y_F, tempArray);

      sprintf(TempBuffer,"%s: Reading in data.\n", FUNCNAME);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

      for(i = 0; i < ReadDataCount; i++) {

	iter = ReadDataTable[i];

	fseek(InFD, fileinfo.dwHeaderSize + iter*RecordLength, SEEK_SET);
      
	Frameout[i*2] = 0;
	Frameout[i*2 + 1] = 1;

	fread(&TimeStamp, sizeof(long), 1, InFD);
	Timestamp0[i*2] = (double)TimeStamp/mwl_MASTERCLOCKFREQ;
	Timestamp0[i*2+1] = (double)TimeStamp/mwl_MASTERCLOCKFREQ;
      
	fread(&TempShort, sizeof(short), 1, InFD);
	Frame0X[i*2] = (double)TempShort;
	fread(&TempShort, sizeof(short), 1, InFD);
	Frame0Y[i*2] = (double)TempShort;
	fread(&TempShort, sizeof(short), 1, InFD);
	Frame0X[i*2+1] = (double)TempShort;
	fread(&TempShort, sizeof(short), 1, InFD);
	Frame0Y[i*2+1] = (double)TempShort;

      }

    } else {

      sprintf(TempBuffer,"%s: Allocating memory for %ld cycles.\n", FUNCNAME, ReadDataCount);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);
  
      ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS;
      outstruct = mxCreateStructArray(ndim, dims, nfields, field_names);
      plhs[0] = outstruct;

      mxSetFieldByNumber(outstruct, 0, FRAME0_F, mxCreateString("front"));
      mxSetFieldByNumber(outstruct, 0, FRAME1_F, mxCreateString("back"));

      ndim = 2; dims[0] = ReadDataCount*2; dims[1] = 1; 
      tempArray = mxCreateNumericArray(ndim, dims, mxUINT8_CLASS, mxREAL);
      mxSetFieldByNumber(outstruct, 0, FRAME_F, tempArray);
      FrameoutC = mxGetData(tempArray);

      tempArray = mxCreateDoubleMatrix(ReadDataCount*2, 1, mxREAL);
      Timestamp0 = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F, tempArray);

      tempArray = mxCreateNumericArray(ndim, dims, mxUINT16_CLASS, mxREAL);
      mxSetFieldByNumber(outstruct, 0, X_F, tempArray);
      Frame0XS = mxGetData(tempArray);

      tempArray = mxCreateNumericArray(ndim, dims, mxUINT16_CLASS, mxREAL);
      mxSetFieldByNumber(outstruct, 0, Y_F, tempArray);
      Frame0YS = mxGetData(tempArray);

      sprintf(TempBuffer,"%s: Reading in data.\n", FUNCNAME);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

      for(i = 0; i < ReadDataCount; i++) {

	iter = ReadDataTable[i];

	fseek(InFD, fileinfo.dwHeaderSize + iter*RecordLength, SEEK_SET);
      
	FrameoutC[i*2] = 0;
	FrameoutC[i*2 + 1] = 1;

	fread(&TimeStamp, sizeof(long), 1, InFD);
	Timestamp0[i*2] = (double) TimeStamp/mwl_MASTERCLOCKFREQ;
	Timestamp0[i*2+1] = (double) TimeStamp/mwl_MASTERCLOCKFREQ;
      
	fread(&TempShort, sizeof(short), 1, InFD);
	Frame0XS[i*2] = TempShort;
	fread(&TempShort, sizeof(short), 1, InFD);
	Frame0YS[i*2] = TempShort;
	fread(&TempShort, sizeof(short), 1, InFD);
	Frame0XS[i*2+1] = TempShort;
	fread(&TempShort, sizeof(short), 1, InFD);
	Frame0YS[i*2+1] = TempShort;

      }

    }
  }

  /************* CREATE INFO STRUCTURE AND SET IT **********/
  ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS2;
  infostruct = mxCreateStructArray(ndim, dims, nfields, field_names2);

  if(paraminfo->ReturnType == RETNoData)
    mxSetFieldByNumber(outstruct, 0, INFO_F3, infostruct);
  else
    mxSetFieldByNumber(outstruct, 0, INFO_F, infostruct);

  mxSetFieldByNumber(infostruct, 0, SOURCE_F,
		     mwl_FileSourceStructure(InFD, FUNCNAME, paraminfo));

  mxSetFieldByNumber(infostruct, 0, MWLTYPE_F, mxCreateString(MWLTS_TRACKER));

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
 * $Log: p2mat.c,v $
 * Revision 1.13  2004/12/07 01:47:46  fabian
 * FIX: getting end timestamp didn't work: fseek command failed silently because seeking with pos offset from end of file
 *
 * Revision 1.12  2004/11/07 04:59:57  fabian
 * replaced ctime_r call by ctime call (Windows compatibility reasons)
 *
 * Revision 1.11  2004/01/14 01:35:27  dpnguyen
 * updated output structures to include mwltype under each info field
 *
 * Revision 1.10  2003/12/12 04:55:51  dpnguyen
 * added functionality for (+) and (-) options
 *
 * Revision 1.9  2003/12/01 23:45:22  fabian
 * removed redundant code
 *
 * Revision 1.8  2003/12/01 21:06:04  fabian
 * updated to work with new mwl_CheckFilterParams function
 * timestamps now always returned in seconds
 *
 * Revision 1.7  2003/11/26 02:57:01  dpnguyen
 * implemented multi-block parameter types
 *
 * Revision 1.6  2003/11/26 02:36:58  dpnguyen
 * made updates for incorporating FTSpikeID
 * Checking to see if FTSpikeID is suppported
 *
 * Revision 1.5  2003/11/26 01:51:38  fabian
 * added record index as a filter type, changed #define FTSampleID to FTSpikeID, and updated p2mat, pos2mat, tt2mat
 *
 * Revision 1.4  2003/11/25 00:53:42  dpnguyen
 * brought code up to date with mwl_FileSourceStructure
 *
 * Revision 1.3  2003/11/21 18:55:07  dpnguyen
 * found a bug or two from the pos2mat.c to p2mat.c copy over
 *
 * Revision 1.2  2003/11/21 18:16:28  dpnguyen
 * copied code from pos2mat.c to p2mat.c, both work fairly well
 * pos2mat.c and p2mat.c differ in behavior when filter param is array type,
 * pos2mat will not produce duplicate entries
 *
 * Revision 1.1  2003/11/11 20:26:48  dpnguyen
 * updated a bunch of position related files
 * and added p2mat for reading in matt's posextract output
 * 
 *
 *
 */
