/******************************************************************************
 
Filename: eeg2mat.c

Function: mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )

Input:

 Filename [string]                           required
 Channels [vector]                           optional, default = {'all'}
 ParameterString [string]                    optional
 Index Vector                                optional, but required if filtering is applied

Output:
 Eegdata [structure]
     time [vector]
     data [matrix]
     info [structure]

Description:

 This function reads 'continuous' data from a MWL .eeg file
          
Author:
 
 David P. Nguyen (dpnguyen@mit.edu) and Fabian Kloosterman (fkloos@mit.edu)

$Id: eeg2mat.c,v 1.11 2004/11/07 03:03:29 fabian Exp $

******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
#include <mat.h>
#include <matrix.h>
#include <mex.h>
#include "mwlIOLib.h"
#include "mwlAPItypes.h"

/* macros to convert 2d or 3d indices to a single index */
#define M3D(r,c,w, R, C) (r + c*R + w*R*C)
#define M2D(r,c,R) (r + c*R)

#define FUNCNAME "eeg2mat"
#define mwl_MAXLOADMB 200

const char *usage1 = " USAGE: \neegdata = eeg2mat(FileName, [Channels], [Parameter String], [Indexing Vector])\n";

const char *field_names1[]= {"timestamp", "data", "info"};
enum Field1Numbers {TIME_F=0, DATA_F, INFO_F, N_FIELDS1};
const char *field_names2[] = {"source", "filename", "cwd", "mwltype", "samplefreq", "units", "channels", "sampleoffset", "gain", "filter", "filespan", "ADCrange", "inputrange"};
enum Field2Numbers {SOURCE_F=0, FNAME_F, CWD_F, MWLTYPE_F, SAMPLEFREQ_F, UNITS_F, CHANNELS_F, SAMPLEOFFSET_F, GAIN_F, FILTER_F, FILESPAN_F, ADCRANGE_F, INPUTRANGE_F, N_FIELDS2};
const char *field_names3[] = {"timestamp", "id", "info"};
enum Field3Numbers{TIME_F3 = 0, ID_F3, INFO_F3, N_FIELDS3};


int doublecompare(d1, d2)
     double  *d1, *d2;
{
  if (d1>d2)
    return 1;
  else if (d2>d1)
    return -1;
  else
    return 0;
}



void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{


  /**********************************variables************************/

  /* general variables */
  long i,j,r;
  char TempBuffer[mwl_MAXSTRING];
  char TempBuffer2[mwl_MAXSTRING];
  unsigned long SampleCount, BufferCount;
  int beginloop, endloop;
  int ChannelCount, BlockCount;

  /* input checking variables */
  BOOL ChannelsSpecified = FALSE;
  int NextParameter;
  mwl_ParamInfo ParamInfo, *paraminfo;

  /* file variables */
  char strFileName[mwl_MAXSTRING];
  FILE *Fin = NULL;
  char **HeaderContents = NULL;
  int HeaderSize;
  mwl_FILEINFO FileInfo;
  char *HeaderField = NULL;

  /* file info variables */
  int nChan, BufferSize, RecordSize;
  double SamplingFreq, SamplePeriod;
  unsigned long FileSize, nRecords, nSamples;
  unsigned long StartTimeStamp, EndTimeStamp;
  double StartTime, EndTime;

  /* channel variables */
  char *ChannelMask = NULL;
  unsigned long ChanVectorLength;
  double *pChannelVector;
  int nLoadChannels;

  /* filtering variables */
  int nBlocks;
  unsigned long *FilterParams = NULL;
  mwl_EegBlock *LoadBlocks = NULL;
  unsigned long TimeStamp, PreviousTimeStamp;
  unsigned long nLoadRecords, nLoadBytes;

  /* output variables */
  mxArray *OutStruct, *TempArray, *InfoStruct;
  int ndim, *dims, nfields;
  short *BufferData = NULL;
  double *TimeArray = NULL, *EEGArrayD = NULL, *pArray = NULL, *IDArray = NULL;
  short *EEGArrayS = NULL;
  int FilterSetting;


  /*****************************input argument check******************/

  dims = mxCalloc(3, sizeof(int));
  paraminfo = &ParamInfo;

  /* create empty outputs */
  for (i=0; i<nlhs; i++) {  
    plhs[i] = mxCreateDoubleMatrix(0,0,mxREAL);
  }

  /*if number of inputs < 1, no file name is specified, thus return*/
  if (nrhs<1) {
    mwlPrintf(usage1, VBError, 0);
    mwl_ParseFilterParamUsage();
    return;
  }
  
  /* First input should be a string*/
  if (!mxIsChar(prhs[0])) {
    sprintf(TempBuffer, "%s: First argument must be a string", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    return;
  }

  /* is there a second input specifying the channels to retrieve?*/
  ChannelsSpecified = FALSE;
  NextParameter = 1;
  if (nrhs>1){
    if (mxIsDouble(prhs[1]) && !mxIsEmpty(prhs[1])) {
      ChannelsSpecified = TRUE;
      NextParameter = 2;
    }
  }
  
  /* do the parameters */
  if(nrhs > (NextParameter+1)) {
    if(mwl_ParseFilterParamADIO(prhs[NextParameter], prhs[NextParameter+1], paraminfo) < 0) {
      sprintf(TempBuffer,"%s: Encountered error, exiting", FUNCNAME);
      mwlPrintf(TempBuffer, VBError, 0);
      return;
    }
  }else if(nrhs > NextParameter) {
    if(mwl_ParseFilterParamADIO(prhs[NextParameter], NULL, paraminfo) < 0) {
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

  /* we don't support array indexing for this function */
  if (paraminfo->FilterParamType == FPTArray) {
    sprintf(TempBuffer, "%s: Array indexing not supported", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    return;
  }

  /* VERBOSE */
  sprintf(TempBuffer, "%s: Input Argument check done. No errors.", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  /******************************open file and get properties******************/


  /* get file name and open file */
  mxGetString(prhs[0], strFileName, mwl_MAXSTRING);
  if((Fin = fopen(strFileName, "r")) == NULL) {
    sprintf(TempBuffer, "%s: Cannot open input file", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    return;
  }
  
  /* read header */
  HeaderContents = (char **) ReadHeader(Fin, &HeaderSize);
  if (HeaderContents == NULL || HeaderSize==0) {
    sprintf(TempBuffer, "%s: Unable to retrieve file header", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    fclose(Fin);
    return;
  }

  /* getheaderinfo */
  if (mwl_GetInfoFromHeader(HeaderContents,HeaderSize, &FileInfo) != mwl_OK) {
    sprintf(TempBuffer, "%s: Unable to retrieve file information", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    fclose(Fin);
    return;
  }
    
  /* is it a .eeg file? */
  if (FileInfo.dwFileType != mwl_FILETYPE_EEG) {
    sprintf(TempBuffer, "%s: This is not an eeg file", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    fclose(Fin);
    return;
  }
  
  /* is it a binary file? */
  if (FileInfo.dwIsBinary == 0) {
    sprintf(TempBuffer, "%s: This is not a binary file", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    fclose(Fin);
    return;
  }

  /* VERBOSE */
  sprintf(TempBuffer, "%s: File %s opened successfully.", FUNCNAME, strFileName);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  /******************************read header fields******************/

  /* get number of channels in file*/
  if ((HeaderField = GetHeaderParameter(HeaderContents, "nchannels:")) !=NULL) {
    nChan = atoi(HeaderField);
  } else {
    sprintf(TempBuffer, "%s: No -nchannels- field in header, assume 8 channels", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    nChan = 8;
  }
  
  /* get buffer size*/
  if ((HeaderField = GetHeaderParameter(HeaderContents, "dma_bufsize:")) !=NULL) {
    BufferSize = atoi(HeaderField);
  } else {
    sprintf(TempBuffer, "%s: No -dma_bufsize- field in header, corrupted file??", FUNCNAME);
     mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    fclose(Fin);
    return;
  }

  /* get sampling frequency*/
  if ((HeaderField = GetHeaderParameter(HeaderContents, "rate:")) !=NULL) {
    SamplingFreq = atof(HeaderField);
  } else {
    sprintf(TempBuffer, "%s: No -rate- field in header; corrupted file??", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    fclose(Fin);
    return;
  }


  /* VERBOSE */
  sprintf(TempBuffer, "%s: # Channels in file: %d", FUNCNAME, nChan);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  sprintf(TempBuffer, "%s: Sampling frequency: %f", FUNCNAME, SamplingFreq);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  sprintf(TempBuffer, "%s: Buffer size: %d", FUNCNAME, BufferSize);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  

  /* determine record size */
  RecordSize = 0;
  for (i=0; i<FileInfo.dwFieldCount; i++) {
    RecordSize = RecordSize + (FileInfo.pFieldInfo[i].dwElementSize * FileInfo.pFieldInfo[i].dwLength);
  }

  /* determine file size */
  fseek(Fin, 0, SEEK_END);
  FileSize = ftell(Fin);

  /* determine number of records, samples in buffer and sample period */
  nRecords = (FileSize-HeaderSize) / RecordSize;
  nSamples = BufferSize / nChan;
  SamplePeriod = mwl_MASTERCLOCKFREQ/SamplingFreq; /* in timestamp units */

  /* retrieve first and last timestamp in file     */
  fseek(Fin, HeaderSize,SEEK_SET);
  fread(&StartTimeStamp, sizeof(unsigned long),1,Fin);

  fseek(Fin, HeaderSize + (nRecords-1)*RecordSize,SEEK_SET);
  fread(&EndTimeStamp, sizeof(unsigned long),1,Fin);

  StartTime = StartTimeStamp / mwl_MASTERCLOCKFREQ;
  EndTime = EndTimeStamp / mwl_MASTERCLOCKFREQ + (BufferSize-1)/SamplingFreq;

  /* VERBOSE */
  sprintf(TempBuffer, "%s: File size: %ld bytes, Header size %d bytes", FUNCNAME, FileSize, HeaderSize);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  sprintf(TempBuffer, "%s: Record size: %d bytes, # Records: %ld", FUNCNAME, RecordSize, nRecords);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  sprintf(TempBuffer, "%s: Start timestamp: %ld, end time stamp: %ld", FUNCNAME, StartTimeStamp, EndTimeStamp);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  sprintf(TempBuffer, "%s: Start time: %f, end time: %f", FUNCNAME, StartTime, EndTime);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  /******************************Create channel mask*******************************/

 /* create channel mask and initialize to zero */
  ChannelMask = mxCalloc(nChan, sizeof(char));
  for (i=0; i<nChan; i++) {
    ChannelMask[i] = 0;
  }

  /* if the caller specified channels, use these */
  if (ChannelsSpecified) {
    ChanVectorLength = mxGetM(prhs[1]) * mxGetN(prhs[1]);
    pChannelVector = mxGetPr(prhs[1]);
    for (i=0; i<ChanVectorLength; i++) {
      if (round(pChannelVector[i])>=1 && round(pChannelVector[i])<=nChan) {
	ChannelMask[(int)round(pChannelVector[i])-1] = 1;
      }
    }
    /* if not, use all channels */
  } else {
    for(i=0; i<nChan; i++)
      ChannelMask[i] = 1;
  }

  /* check the number of channels to load */
  nLoadChannels = 0;
  for (i=0; i<nChan; i++) {
    if (ChannelMask[i] == 1)
      nLoadChannels++;
  }

  if (nLoadChannels==0) {
    sprintf(TempBuffer, "%s: No valid channels specified", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    if (Fin!=NULL)
      fclose(Fin);
    return;
  }

  /* VERBOSE */
  sprintf(TempBuffer,"%s: Channel mask created.", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: Channel mask: ", FUNCNAME);
  for (i=0; i<nChan; i++) {
    sprintf(TempBuffer2,"%d",ChannelMask[i]);
    strcat(TempBuffer,TempBuffer2);
  }
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  sprintf(TempBuffer, "     -> %d channels selected for importing.", nLoadChannels);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);


  /***************************** PROCESS PARAMETERS ***************************/

  sprintf(TempBuffer,"%s: Processing parameters\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  nBlocks = 0;
  if(mwl_CheckFilterParamADIO(paraminfo, prhs[NextParameter+1], StartTimeStamp, EndTimeStamp, 0, 0, nRecords, &FilterParams, &nBlocks) < 0)
    return;



  /**************************** PROCESS FILTER ****************************/

  sprintf(TempBuffer,"%s: Determining what data to read in.\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  switch (paraminfo->FilterType) {
  case FTNone:
    nBlocks = 1;
    LoadBlocks = (mwl_EegBlock*) mxCalloc(nBlocks, sizeof(mwl_EegBlock));
    LoadBlocks[0].FirstBuffer = 0;
    LoadBlocks[0].LastBuffer = nRecords-1;
    LoadBlocks[0].FirstBufferOffset = 0;
    LoadBlocks[0].LastBufferOffset = nSamples-1;
    LoadBlocks[0].ValidBlock = 2;
    break;
  case FTTimeStamp:
  case FTSeconds:
    LoadBlocks = (mwl_EegBlock*) mxCalloc(nBlocks, sizeof(mwl_EegBlock));

    PreviousTimeStamp = 0;

    /* loop through all records */
    for (r=0; r<nRecords; r++) {

      /* get the timestamp for each record */
      fseek(Fin, HeaderSize + r*RecordSize, 0);
      fread(&TimeStamp, sizeof(unsigned long), 1, Fin);

      /* loop through all blocks to be loaded */
      for (i=0; i<nBlocks; i++) {

	if (LoadBlocks[i].ValidBlock == 0 && FilterParams[M2D(i, 0, nBlocks)]< (TimeStamp + (BufferSize)*SamplePeriod) ) {
	  LoadBlocks[i].FirstBuffer = r;
	  if (FilterParams[M2D(i, 0, nBlocks)] >= TimeStamp) {
	    LoadBlocks[i].FirstBufferOffset = ceil((FilterParams[M2D(i, 0, nBlocks)] - TimeStamp) / (nChan * SamplePeriod));
	  }
	  else {
	    LoadBlocks[i].FirstBufferOffset = 0;
	  }
	  LoadBlocks[i].ValidBlock = 1; /* first buffer found! */
	}

	if (LoadBlocks[i].ValidBlock == 1 && FilterParams[M2D(i,1,nBlocks)]<TimeStamp) {
	  LoadBlocks[i].LastBuffer = r-1;
	  if (FilterParams[M2D(i,1,nBlocks)] >= PreviousTimeStamp) {
	    LoadBlocks[i].LastBufferOffset = floor((FilterParams[M2D(i,1,nBlocks)] - PreviousTimeStamp) / (nChan * SamplePeriod));
	  }
	  else {
	    LoadBlocks[i].LastBufferOffset = 0;
	  }

	  if (LoadBlocks[i].LastBufferOffset > nSamples-1)
	    LoadBlocks[i].LastBufferOffset = nSamples-1;
	  LoadBlocks[i].ValidBlock = 2; /* first and last buffer found! */
	}
      }
	PreviousTimeStamp = TimeStamp;

    }

    /* post processing */
    for (i=0; i<nBlocks; i++) {
      if (LoadBlocks[i].ValidBlock == 1) {  /* i.e. only first buffer found */
	LoadBlocks[i].LastBuffer = nRecords-1;
	if (FilterParams[M2D(i,1,nBlocks)] >= PreviousTimeStamp) {
	  LoadBlocks[i].LastBufferOffset = floor((FilterParams[M2D(i,1,nBlocks)] - PreviousTimeStamp) / (nChan * SamplePeriod));
	}
	else {
	  LoadBlocks[i].LastBufferOffset = 0;
	}
	
	if (LoadBlocks[i].LastBufferOffset > nSamples-1)
	  LoadBlocks[i].LastBufferOffset = nSamples-1;
	LoadBlocks[i].ValidBlock = 2; /* first and last buffer found! */
      }

      if (LoadBlocks[i].LastBuffer < LoadBlocks[i].FirstBuffer) {
	LoadBlocks[i].ValidBlock = 0;
      }

    }
    break;
  case FTRecordID:

    LoadBlocks = (mwl_EegBlock*) mxCalloc(nBlocks, sizeof(mwl_EegBlock));

    for (i=0; i<nBlocks; i++) {
      LoadBlocks[i].FirstBuffer = floor((FilterParams[M2D(i, 0, nBlocks)]-1)/nSamples);
      LoadBlocks[i].LastBuffer = floor((FilterParams[M2D(i, 1, nBlocks)]-1)/nSamples);
      LoadBlocks[i].FirstBufferOffset = (FilterParams[M2D(i,0,nBlocks)]-1)%nSamples;
      LoadBlocks[i].LastBufferOffset = (FilterParams[M2D(i,1,nBlocks)]-1)%nSamples;
      LoadBlocks[i].ValidBlock = 2;
    }
    break;
  }

  for (i=0; i<nBlocks; i++) 
    LoadBlocks[i].RecordCount = ( LoadBlocks[i].LastBuffer - LoadBlocks[i].FirstBuffer ) * nSamples - LoadBlocks[i].FirstBufferOffset + LoadBlocks[i].LastBufferOffset + 1;

  /****************************** LOAD DATA *********************************/

  /* determine number of records to load */
  nLoadRecords = 0;
  for (i=0; i<nBlocks; i++)
    if (LoadBlocks[i].ValidBlock == 2)
      nLoadRecords += ( LoadBlocks[i].LastBuffer - LoadBlocks[i].FirstBuffer ) * nSamples - LoadBlocks[i].FirstBufferOffset + LoadBlocks[i].LastBufferOffset + 1;

  if (nLoadRecords<1) {
    sprintf(TempBuffer, "%s: No data matches filter", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    if (Fin!=NULL)
      fclose(Fin);
    return;
  }


  /* determine number of bytes to load */
  switch (paraminfo->DataFormat) {
  case DFTMatlabFormat:
    nLoadBytes = nLoadRecords*(nLoadChannels*sizeof(double)) / 1048576;
    break;
  case DFTOrigFormat:
    nLoadBytes = nLoadRecords*(nLoadChannels*sizeof(short)) / 1048576;
    break;
  }


  /*** Load only timestamps or load timestamps with data ****/
  if(paraminfo->ReturnType == RETNoData) {

    ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS3;
    OutStruct = mxCreateStructArray(ndim, dims, nfields, field_names3);
    plhs[0] = OutStruct;
      
    for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {
      
      TempArray = mxCreateDoubleMatrix(LoadBlocks[BlockCount].RecordCount, 1, mxREAL);
      TimeArray = mxGetPr(TempArray);
      mxSetFieldByNumber(OutStruct, BlockCount, TIME_F3, TempArray);
      
      TempArray = mxCreateDoubleMatrix(LoadBlocks[BlockCount].RecordCount, 1, mxREAL);
      IDArray = mxGetPr(TempArray);
      mxSetFieldByNumber(OutStruct, BlockCount, ID_F3, TempArray);

      SampleCount = 0;
      
      for (BufferCount=LoadBlocks[BlockCount].FirstBuffer; BufferCount<=LoadBlocks[BlockCount].LastBuffer; BufferCount++) {

	if (LoadBlocks[BlockCount].FirstBuffer == LoadBlocks[BlockCount].LastBuffer) {
	  beginloop = LoadBlocks[BlockCount].FirstBufferOffset;
	  endloop = LoadBlocks[BlockCount].LastBufferOffset;
	} else if (BufferCount == LoadBlocks[BlockCount].FirstBuffer) {
	  beginloop = LoadBlocks[BlockCount].FirstBufferOffset;
	  endloop = nSamples-1;
	} else if (BufferCount == LoadBlocks[BlockCount].LastBuffer) {
	  beginloop = 0;
	  endloop = LoadBlocks[BlockCount].LastBufferOffset;
	} else {
	  beginloop = 0;
	  endloop = nSamples-1;
	}

	fseek(Fin, HeaderSize + BufferCount*RecordSize, 0);
	
	fread(&TimeStamp, sizeof(unsigned long), 1, Fin);
	for (i=beginloop; i<=endloop; i++) {
	  TimeArray[SampleCount] = (double) (TimeStamp / mwl_MASTERCLOCKFREQ + i*nChan / SamplingFreq);
	  IDArray[SampleCount] = (double) (BufferCount*nSamples + i);
	  SampleCount++;
	}
      }
      
    }
    
  } else {

    if (nLoadBytes>mwl_MAXLOADMB) {
      sprintf(TempBuffer, "%s: Attempted to import %ld Mb of data, limit is %d Mb. Aborted", FUNCNAME, nLoadBytes, mwl_MAXLOADMB);
      mwlPrintf(TempBuffer, VBError, 0);
      if (HeaderContents!=NULL)
	free(HeaderContents);
      if (Fin!=NULL)
	fclose(Fin);
      return;
    }

    /* CREATE OUTPUT STRUCTURE */

    ndim = 2; dims[0] = nBlocks; dims[1] = 1; nfields = N_FIELDS1;
    OutStruct = mxCreateStructArray(ndim, dims, nfields, field_names1);
    plhs[0] = OutStruct;

    BufferData = mxCalloc(BufferSize, sizeof(short));

    switch (paraminfo->DataFormat) {
    case DFTMatlabFormat:

      for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {

	TempArray = mxCreateDoubleMatrix(LoadBlocks[BlockCount].RecordCount, 1, mxREAL);
	TimeArray = mxGetPr(TempArray);
	mxSetFieldByNumber(OutStruct, BlockCount, TIME_F, TempArray);
	
	TempArray = mxCreateDoubleMatrix(LoadBlocks[BlockCount].RecordCount, nLoadChannels, mxREAL);
	EEGArrayD = mxGetPr(TempArray);
	mxSetFieldByNumber(OutStruct, BlockCount, DATA_F, TempArray);
	
	SampleCount = 0;

	for (BufferCount=LoadBlocks[BlockCount].FirstBuffer; BufferCount<=LoadBlocks[BlockCount].LastBuffer; BufferCount++) {

	  if (LoadBlocks[BlockCount].FirstBuffer == LoadBlocks[BlockCount].LastBuffer) {
	    beginloop = LoadBlocks[BlockCount].FirstBufferOffset;
	    endloop = LoadBlocks[BlockCount].LastBufferOffset;
	  } else if (BufferCount == LoadBlocks[BlockCount].FirstBuffer) {
	    beginloop = LoadBlocks[BlockCount].FirstBufferOffset;
	    endloop = nSamples-1;
	  } else if (BufferCount == LoadBlocks[BlockCount].LastBuffer) {
	    beginloop = 0;
	    endloop = LoadBlocks[BlockCount].LastBufferOffset;
	  } else {
	    beginloop = 0;
	    endloop = nSamples-1;
	  }

	  fseek(Fin, HeaderSize + BufferCount*RecordSize, 0);

	  fread(&TimeStamp, sizeof(unsigned long), 1, Fin);
	  fread(BufferData, sizeof(short), BufferSize, Fin);

	  for (i=beginloop; i<=endloop; i++) {

	    ChannelCount = 0;

	    for (j=0; j<nChan; j++) {

	      if (ChannelMask[j]) {
		EEGArrayD[ChannelCount*LoadBlocks[BlockCount].RecordCount + SampleCount] = (double) BufferData[i*nChan + j];
		ChannelCount++;
	      }

	    }

	    TimeArray[SampleCount] = (double) (TimeStamp / mwl_MASTERCLOCKFREQ + i*nChan / SamplingFreq);
	    SampleCount++;

	  }
	}

      }

      break;
    case DFTOrigFormat:

      for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {

	TempArray = mxCreateDoubleMatrix(LoadBlocks[BlockCount].RecordCount, 1, mxREAL);
	TimeArray = mxGetPr(TempArray);
	mxSetFieldByNumber(OutStruct, BlockCount, TIME_F, TempArray);
	
	ndim = 2; dims[0] = LoadBlocks[BlockCount].RecordCount; dims[1] = nLoadChannels;
	TempArray = mxCreateNumericArray(ndim, dims, mxINT16_CLASS,  mxREAL);
	EEGArrayS = (short*) mxGetPr(TempArray);
	mxSetFieldByNumber(OutStruct, BlockCount, DATA_F, TempArray);

	SampleCount = 0;

	for (BufferCount=LoadBlocks[BlockCount].FirstBuffer; BufferCount<=LoadBlocks[BlockCount].LastBuffer; BufferCount++) {

	  if (LoadBlocks[BlockCount].FirstBuffer == LoadBlocks[BlockCount].LastBuffer) {
	    beginloop = LoadBlocks[BlockCount].FirstBufferOffset;
	    endloop = LoadBlocks[BlockCount].LastBufferOffset;
	  } else if (BufferCount == LoadBlocks[BlockCount].FirstBuffer) {
	    beginloop = LoadBlocks[BlockCount].FirstBufferOffset;
	    endloop = nSamples-1;
	  } else if (BufferCount == LoadBlocks[BlockCount].LastBuffer) {
	    beginloop = 0;
	    endloop = LoadBlocks[BlockCount].LastBufferOffset;
	  } else {
	    beginloop = 0;
	    endloop = nSamples-1;
	  }

	  fseek(Fin, HeaderSize + BufferCount*RecordSize, 0);

	  fread(&TimeStamp, sizeof(unsigned long), 1, Fin);
	  fread(BufferData, sizeof(short), BufferSize, Fin);

	  for (i=beginloop; i<=endloop; i++) {

	    ChannelCount = 0;

	    for (j=0; j<nChan; j++) {

	      if (ChannelMask[j]) {
		EEGArrayS[ChannelCount*LoadBlocks[BlockCount].RecordCount + SampleCount] = BufferData[i*nChan + j];
		ChannelCount++;
	      }

	    }

	    TimeArray[SampleCount] = (double) (TimeStamp / mwl_MASTERCLOCKFREQ + i*nChan / SamplingFreq);
	    SampleCount++;

	  }
	}

      }

      break;
    }
  }

  sprintf(TempBuffer,"%s: Data successfully loaded.\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);


  /* CREATE INFO STRUCTURE */

  ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS2;
  InfoStruct = mxCreateStructArray(ndim, dims, nfields, field_names2);

  if(paraminfo->ReturnType == RETNoData)
    mxSetFieldByNumber(OutStruct, 0, INFO_F3, InfoStruct);
  else
    mxSetFieldByNumber(OutStruct, 0, INFO_F, InfoStruct);

  mxSetFieldByNumber(InfoStruct, 0, FNAME_F, mxCreateString(strFileName));
  
  getcwd(TempBuffer, mwl_MAXSTRING);

  mxSetFieldByNumber(InfoStruct, 0, CWD_F, mxCreateString(TempBuffer));

  mxSetFieldByNumber(InfoStruct, 0, SOURCE_F, mwl_FileSourceStructure(Fin, FUNCNAME, paraminfo));

  mxSetFieldByNumber(InfoStruct, 0, MWLTYPE_F, mxCreateString(MWLTS_EEG));
  
  mxSetFieldByNumber(InfoStruct, 0, SAMPLEFREQ_F, mxCreateDoubleScalar(SamplingFreq/nChan));

  mxSetFieldByNumber(InfoStruct, 0, UNITS_F, mxCreateString("ADC"));

  TempArray = mxCreateDoubleMatrix(1,nLoadChannels,mxREAL);
  pArray = mxGetPr(TempArray); 
  ChannelCount = 0;
  for (i=0; i<nChan; i++) {
    if (ChannelMask[i]) {
      pArray[ChannelCount] = i+1;
      ChannelCount++;
    }
  }
  mxSetFieldByNumber(InfoStruct, 0, CHANNELS_F, TempArray);

  TempArray = mxCreateDoubleMatrix(1,nLoadChannels,mxREAL);
  pArray = mxGetPr(TempArray); 
  ChannelCount = 0;
  for (i=0; i<nChan; i++) {
    if (ChannelMask[i]) {
      pArray[ChannelCount] = i / SamplingFreq;
      ChannelCount++;
    }
  }
  mxSetFieldByNumber(InfoStruct, 0, SAMPLEOFFSET_F, TempArray);

  TempArray = mxCreateDoubleMatrix(1, nLoadChannels, mxREAL);
  pArray = mxGetPr(TempArray);
  /* retrieve gains */
  ChannelCount=0;
  for (i=0; i<nChan; i++) {
    if (ChannelMask[i]) {
      sprintf(TempBuffer, "channel %ld ampgain:", i);
      if (( HeaderField = (char *)GetHeaderParameter(HeaderContents, TempBuffer) )!=NULL ) {
	pArray[ChannelCount] = atof(HeaderField);
      } else {
	sprintf(TempBuffer, "%s: Unable to retrieve gain information for channel %ld", FUNCNAME, i+1);
	mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
      }
      ChannelCount++;
    }
  }
  mxSetFieldByNumber(InfoStruct, 0, GAIN_F, TempArray);

  TempArray = mxCreateDoubleMatrix(2, nLoadChannels, mxREAL);
  pArray = mxGetPr(TempArray);
  /* retrieve filter settings */
  ChannelCount=0;
  for (i=0; i<nChan; i++) {
    if (ChannelMask[i]) {
      sprintf(TempBuffer, "channel %ld filter:", i);
      if (( HeaderField = (char *)GetHeaderParameter(HeaderContents, TempBuffer) )!=NULL ) {
	FilterSetting = atoi(HeaderField);
	mwl_ConvertFilterSetting(FilterSetting, &pArray[2*ChannelCount], &pArray[2*ChannelCount+1]);
      } else {
	sprintf(TempBuffer, "%s: Unable to retrieve filter information for channel %ld", FUNCNAME, i+1);
	mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
      }
      ChannelCount++;
    }
  }
  mxSetFieldByNumber(InfoStruct, 0, FILTER_F, TempArray); 
  
  TempArray = mxCreateDoubleMatrix(1,2,mxREAL);
  pArray = mxGetPr(TempArray); 
  pArray[0] = StartTime;
  pArray[1] = EndTime;
  mxSetFieldByNumber(InfoStruct, 0, FILESPAN_F, TempArray);

  TempArray = mxCreateDoubleMatrix(1,2,mxREAL);
  pArray = mxGetPr(TempArray); 
  pArray[0] = -2048;
  pArray[1] = 2047;
  mxSetFieldByNumber(InfoStruct, 0, ADCRANGE_F, TempArray);
  
  TempArray = mxCreateDoubleMatrix(1,2,mxREAL);
  pArray = mxGetPr(TempArray); 
  pArray[0] = -10;
  pArray[1] = 10;
  mxSetFieldByNumber(InfoStruct, 0, INPUTRANGE_F, TempArray);
  



  /* CLEAN UP */

  if (HeaderContents!=NULL)
    free(HeaderContents);

  if (Fin!=NULL)
    fclose(Fin);


}


/*
 *$Log: eeg2mat.c,v $
 *Revision 1.11  2004/11/07 03:03:29  fabian
 *changed get_current_working_dir call to getcwd for windows compatibility
 *
 *Revision 1.10  2004/06/22 15:21:30  dpnguyen
 *added filename and cwd fields to the info structure
 *
 *Revision 1.9  2004/03/17 21:18:55  dpnguyen
 *eeg2mat returns a struct array corresponding to the blocks of input
 *
 *Revision 1.8  2004/03/15 19:44:28  fabian
 *fixed possible errors caused by subtraction of ulong variables. Errors were only visible if you had gaps in the eeg file.
 *
 *Revision 1.7  2004/01/14 01:35:27  dpnguyen
 *updated output structures to include mwltype under each info field
 *
 *Revision 1.6  2003/12/12 04:55:51  dpnguyen
 *added functionality for (+) and (-) options
 *
 *Revision 1.5  2003/12/09 21:41:39  dpnguyen
 *Fixed bug in pos2mat.c (RecordCount --> FrameCount)
 *Fixed time to timestamp in hte output structure
 *
 *Revision 1.4  2003/12/01 21:00:20  fabian
 *major update: now fully compliant with CheckFilterParams function
 *Processing of filter has been simplified
 *source structure added to output info structure
 *
 *Revision 1.3  2003/11/21 18:17:00  fabian
 *updated eeg2mat to reflect changes to mwlParseFilterParams
 *
 *Revision 1.2  2003/11/21 01:10:01  fabian
 *updated eeg2mat: now uses mwlPrintf for printing messages
 *
 *Revision 1.1  2003/11/19 16:58:35  fabian
 *added eeg2mat for reading .eeg files, supports relative to start / first index options, and verbose options, does not support array indexing (only block)
 *
 *Revision 1.12  2003/11/10 22:02:53  dpnguyen
 *fixed the bug where it read only one channel
 *
 *Revision 1.11  2003/11/10 20:28:29  fabian
 *Major update: include support for parameter name/value pairs in eeg2mat, event2mat, tt2mat and fv2mat, debugged all of them: no crashes anymore (??)
 *
 *Revision 1.10  2003/11/07 19:57:49  fabian
 *added brand new function for parsing prop name / prop value pairs
 *also included is a small test mex function
 *
 *Revision 1.9  2003/11/07 01:19:42  fabian
 *debugged eeg2mat. seems more stable now. inputs can be passed as parameter name / parameter value pairs
 *
 *Revision 1.8  2003/11/07 01:15:18  fabian
 *debugged mwlParseParams functions, renamed the files according to convention
 *
 */
