/******************************************************************************
 
Filename: tt2mat.c

Function: mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )

Input:

 Filename [string]                           required
 ParameterString [string]                    optional
 Index Vector                                optional, but required if filtering is applied

Output:

 Waveform [structure]
     time [Nx1 vector] (in seconds)
     spikeid [Nx1 vector]
     data [NxMxL array]
          N => number of samples
          M => number of electrodes
          L => number of waveforms
     info [structure]

Description:
       Load spike waveforms from a .tt file into Matlab

Author: David P. Nguyen (dpnguyen@mit.edu) and Fabian Kloosterman (fkloos@mit.edu)



$Id: tt2mat.c,v 1.15 2004/11/07 04:58:54 fabian Exp $
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

#define FUNCNAME "tt2mat"

const char *usage1 = " USAGE: \nwaveforms = tt2mat( FileName, [Parameter String], [Indexing Vector])\n";

const char *field_names1[] = {"timestamp", "spikeid", "waveform", "info"};
enum Field1Numbers {TIMESTAMP_F=0, SPIKEID_F, WAVEFORM_F, INFO_F, N_FIELDS1};
const char *field_names2[] = {"source", "mwltype", "createdate", "createfunc", "probe", "samplingfreq", "nchans", "lwaveform", "sepspike", "units", "gain", "filter", "adcrange", "inputrange", "timespan"};
enum Field2Numbers {SOURCE_F=0, MWLTYPE_F, DATE_F, CREATEFUNC_F, PROBE_F, SAMPLEFREQ_F, NCHAN_F, SPIKELEN_F, SPIKESEP_F, UNITS_F, GAIN_F, FILTER_F, ADCRANGE_F, INPUTRANGE_F, TIMESPAN_F, N_FIELDS2};
const char *field_names3[] = {"timestamp", "spikeid", "info"};
enum Field3Numbers {TIMESTAMP_F3, SPIKEID_F3, INFO_F3, N_FIELDS3};

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
 /* General Variables */
  FILE *InFD = NULL;
  char TempBuffer[mwl_MAXSTRING];
  char *DateBuffer;
  char *headerfield = NULL;
  char **headercontents = NULL;
  int headersize;
  time_t TSeconds;
  mwl_FILEINFO fileinfo;
  mwl_RESULT result;
  mwl_ParamInfo ParamInfo, *paraminfo;
  int mrow = 0, mcol = 0, row = 0;
  long i;


  /* Read-in Data Variables */
  unsigned long EndOfFile, bytecount;
  unsigned long nRecords = 0;
  unsigned long RecordCount = 0;
  unsigned long RecordLength = 0;
  unsigned long ReadDataCount = 0;  /* number of points to read in */
  unsigned long StartOfData, TimeStamp, StartTimeStamp, EndTimeStamp;
  double StartTime, EndTime;
  short *waveform;
  int samp, elec;
  int nBlocks;

  /* Variables from header */
  int nChans, nTotalChannels;
  int lWaveform;
  int SpikeSeperation;
  char ProbeNumber;
  double SampFrequency;
  

  /* output structure parameters */
  int ndim, *dims, nfields;
  mxArray *outstruct, *tempArray, *infostruct;
  unsigned long iter;
  double *TimeStampArray, *Waveforms, *IDArray;
  short *WaveformsS;
  int filtersetting;
  double *pArray=NULL;

  /* Filter Parameter Variables */
  unsigned long *FilterParams = NULL;
  unsigned long *ReadDataTable = NULL;


  /*******************************************input check****************************/

  /* create default empty matrices for each output variable */
  for (i=0; i<nlhs; i++) {
    plhs[i] = mxCreateDoubleMatrix(0,0,mxREAL);
  }

  dims = mxCalloc(3, sizeof(int));
  paraminfo = &ParamInfo;


 /* if no input arguments present, show usage of this function */
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
  case FTSpikeID: 
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
  if(fileinfo.dwFileType != mwl_FILETYPE_WAVEFORM) {
    sprintf(TempBuffer, "%s: This is not a tetrode file.", FUNCNAME);
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
  RecordLength = 0;
  for (i=0; i<fileinfo.dwFieldCount; i++) {
    RecordLength = RecordLength + (fileinfo.pFieldInfo[i].dwElementSize * fileinfo.pFieldInfo[i].dwLength);
  }

  /******** READ HEADER FIELDS *************/

  /* read header */
  headercontents = (char **) ReadHeader(InFD, &headersize);
  if (headercontents == NULL || headersize==0) {
    sprintf(TempBuffer, "%s: Unable to retrieve file header", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    fclose(InFD);
    return;
  }

  /* get number of channels in file*/
  if ((headerfield = GetHeaderParameter(headercontents, "nchannels:")) !=NULL) {
    nTotalChannels = atoi(headerfield);
  } else {
    sprintf(TempBuffer, "%s: No -nchannels- field in header, assume 8 channels", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    nTotalChannels = 8;
  }

  /* get sampling frequency*/
  if ((headerfield = GetHeaderParameter(headercontents, "rate:")) !=NULL) {
    SampFrequency = atof(headerfield);
  } else {
    sprintf(TempBuffer, "%s: No -rate- field in header; corrupted file??", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    if (headercontents!=NULL)
      free(headercontents);
    fclose(InFD);
    return;
  }
  
  /* get number of channels in file*/
  if ((headerfield = GetHeaderParameter(headercontents, "nelect_chan:")) !=NULL) {
    nChans = atoi(headerfield);
  } else {
    sprintf(TempBuffer, "%s: No -nelect_chan- field in header, assume tetrode", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    nChans = 4;
  }

  
  /* get spike length (in samples) */
  if ((headerfield = GetHeaderParameter(headercontents, "spikelen:")) !=NULL) {
    lWaveform = atoi(headerfield);
  } else {
    sprintf(TempBuffer, "%s: No -spikelen- field in header, assume 32", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    lWaveform=32;
  }

  /* get spike separation */
  if ((headerfield = GetHeaderParameter(headercontents, "spikesep:")) !=NULL) {
    SpikeSeperation = atoi(headerfield);
  } else {
    sprintf(TempBuffer, "%s: No -spikesep- field in header", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    SpikeSeperation = -1;
  }

  /* get probe number */
  if ((headerfield = GetHeaderParameter(headercontents, "Probe:")) !=NULL) {
    ProbeNumber = atoi(headerfield);
  } else {
    sprintf(TempBuffer, "%s: No -Probe- field in header, assume 0", FUNCNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    ProbeNumber = 0;
  }


  /******* DETERMINE PRELIMINARY INFO ABOUT DATA IN FILE ******/

  /* Determine size of file */
  fseek(InFD, 0, SEEK_END);
  EndOfFile = ftell(InFD);

  /* Determine start of data */
  fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
  StartOfData = ftell(InFD);
  
  nRecords = (EndOfFile - StartOfData)/RecordLength;
  bytecount = RecordLength*nRecords + fileinfo.dwHeaderSize;

  fread(&StartTimeStamp, sizeof(long), 1, InFD);
  fseek(InFD, RecordLength*(nRecords-1) + fileinfo.dwHeaderSize, SEEK_SET);
  fread(&EndTimeStamp, sizeof(long), 1, InFD);
  StartTime = ((double)StartTimeStamp)/mwl_MASTERCLOCKFREQ;
  EndTime = ((double)EndTimeStamp)/mwl_MASTERCLOCKFREQ;
   
  /* VERBOSE */
  sprintf(TempBuffer,"%s: File is ok and has been opened\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: Header Ends at %d\n", FUNCNAME, fileinfo.dwHeaderSize);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: Start Time = %.3lf sec, End Time = %.3lf sec\n", FUNCNAME, StartTime, EndTime);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: StartTimeStamp = %ld, EndTimeStamp = %ld\n", FUNCNAME, StartTimeStamp, EndTimeStamp);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: Number of Records = %ld, Bytes Available = %ld/%ld\n", FUNCNAME, nRecords, bytecount, EndOfFile);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);


  /***************************** PROCESS PARAMETERS ***************************/
  sprintf(TempBuffer,"%s: Processing parameters\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  nBlocks = 0;
  if(mwl_CheckFilterParamADIO(paraminfo, prhs[2], StartTimeStamp, EndTimeStamp, 1, nRecords, nRecords, &FilterParams, &nBlocks) < 0)
    return;


  /*********************************** allocate read data table *****************************/
  sprintf(TempBuffer,"%s: Determining what data to read in.\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);

  if(paraminfo->FilterType == FTNone) {

    ReadDataTable = mxCalloc(sizeof(long),(nRecords));
    ReadDataCount = 0;

    for(RecordCount = 0; RecordCount < nRecords; RecordCount++)
      ReadDataTable[RecordCount] = RecordCount;
    
    ReadDataCount = nRecords;

  } else {

    mrow = mxGetM(prhs[2]);
    mcol = mxGetN(prhs[2]);
    
    /** PROCESS BLOCK **/
    if(paraminfo->FilterParamType == FPTBlock) {

      ReadDataTable = mxCalloc(sizeof(long),(nRecords));
      RecordCount = 0;
      ReadDataCount = 0;

      /** FILTER WITH SECONDS AND TIMESTAMPS */
      if((paraminfo->FilterType == FTSeconds)||
	 (paraminfo->FilterType == FTTimeStamp)) {
	
	fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
	clearerr(InFD);
	while(1) {

	  /******** START DATA TYPE DEPENDENT CODE **************/
	  fread(&TimeStamp, sizeof(long), 1, InFD);
	  fseek(InFD, (RecordLength - sizeof(long)), SEEK_CUR);
	  
	  for(row = 0; row < nBlocks; row++)
	    if((TimeStamp >= FilterParams[M2D(row,0,nBlocks)]) && 
	       (TimeStamp <= FilterParams[M2D(row,1,nBlocks)])) {
	      ReadDataTable[ReadDataCount] = RecordCount;
	      ReadDataCount++;
	    }
	  /******** END DATA TYPE DEPENDENT CODE **************/

	  RecordCount++;
	  if(RecordCount == nRecords)
	    break;
	}

	/** FILTER WITH SAMPLE ID **/
      } else if((paraminfo->FilterType == FTSpikeID)||(paraminfo->FilterType == FTRecordID)) {
	
	for(RecordCount = 1; RecordCount <= nRecords; RecordCount++) {
	  for(row = 0; row < nBlocks; row++)
	    if((RecordCount >= FilterParams[M2D(row,0,nBlocks)]) && 
	       (RecordCount <= FilterParams[M2D(row,1,nBlocks)])) {
	      ReadDataTable[ReadDataCount] = RecordCount-1;
	      ReadDataCount++;
	    }
	}
      } 
      
      /** PROCESS ARRAY **/
    } else if(paraminfo->FilterParamType == FPTArray) {
      
  
      ReadDataTable = mxCalloc(sizeof(long),(nBlocks));
      ReadDataCount = 0;
      RecordCount = 0;
      
      for(RecordCount = 0; RecordCount < nBlocks; RecordCount++) {
	if((FilterParams[RecordCount] >= 1) && (FilterParams[RecordCount] <= nRecords)) {
	  ReadDataTable[ReadDataCount] = FilterParams[RecordCount]-1;
	  ReadDataCount++;
	}       
      }
    }
  }


  /** WHAT TYPE OF DATA SHOULD WE RETURN **/
  if(paraminfo->ReturnType == RETNoData) {  /***** Return only timestamps and id of timestmaps *****/

    /* CREATE MAIN OUTPUT STRUCTURE */
      
    sprintf(TempBuffer,"%s: Allocating memory for %ld frames.\n", FUNCNAME, ReadDataCount);
    mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);
    
    ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS3;
    outstruct = mxCreateStructArray(ndim, dims, nfields, field_names3);
    plhs[0] = outstruct;
    
    tempArray = mxCreateDoubleMatrix(ReadDataCount, 1, mxREAL);
    TimeStampArray = mxGetPr(tempArray);
    mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F3, tempArray);
    
    tempArray = mxCreateDoubleMatrix(ReadDataCount, 1, mxREAL);
    IDArray = mxGetPr(tempArray);
    mxSetFieldByNumber(outstruct, 0, SPIKEID_F3, tempArray);
    
    fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
    
    sprintf(TempBuffer,"%s: Reading in data.\n", FUNCNAME);
    mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);
    
    for(i=0; i < ReadDataCount; i++) {    
      iter = ReadDataTable[i];
      
      fseek(InFD, fileinfo.dwHeaderSize + iter * RecordLength, 0);
      fread(&TimeStamp, sizeof(long), 1, InFD);
	TimeStampArray[i] = (double)(TimeStamp/mwl_MASTERCLOCKFREQ);
	IDArray[i] = (double)iter+1;
    }

  } else {

    /*****************************Load data*******************************/

    waveform = mxCalloc(nChans*lWaveform, sizeof(short));

    /* CREATE MAIN OUTPUT STRUCTURE */


    if (paraminfo->DataFormat == DFTMatlabFormat) {
      sprintf(TempBuffer,"%s: Allocating memory for %ld frames.\n", FUNCNAME, ReadDataCount);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

      ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS1;
      outstruct = mxCreateStructArray(ndim, dims, nfields, field_names1);
      plhs[0] = outstruct;
    
      tempArray = mxCreateDoubleMatrix(ReadDataCount, 1, mxREAL);
      TimeStampArray = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F, tempArray);
    
      tempArray = mxCreateDoubleMatrix(ReadDataCount, 1, mxREAL);
      IDArray = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, SPIKEID_F, tempArray);
    
      ndim = 3; dims[1] = nChans; dims[0] = lWaveform; dims[2] = ReadDataCount;
      tempArray = mxCreateNumericArray(ndim, dims, mxDOUBLE_CLASS, mxREAL);
      Waveforms = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, WAVEFORM_F, tempArray);

      fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);

      sprintf(TempBuffer,"%s: Reading in data.\n", FUNCNAME);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

      for(i=0; i < ReadDataCount; i++) {    
	iter = ReadDataTable[i];
      
	fseek(InFD, fileinfo.dwHeaderSize + iter * RecordLength, 0);
	fread(&TimeStamp, sizeof(long), 1, InFD);
	TimeStampArray[i] = (double)(TimeStamp/mwl_MASTERCLOCKFREQ);
	IDArray[i] = (double)iter+1;
      
	fread(waveform, sizeof(short), nChans*lWaveform, InFD);
	for(elec=0; elec < nChans; elec++)
	  for(samp=0; samp < lWaveform; samp++)
	    Waveforms[M3D(samp, elec, i, lWaveform, nChans)] =
	      (double)(waveform[M2D(elec, samp,  nChans)]); 
      }
    } else {

      sprintf(TempBuffer,"%s: Allocating memory for %ld frames.\n", FUNCNAME, ReadDataCount);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

      ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS1;
      outstruct = mxCreateStructArray(ndim, dims, nfields, field_names1);
      plhs[0] = outstruct;
    
      tempArray = mxCreateDoubleMatrix(ReadDataCount, 1, mxREAL);
      TimeStampArray = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, TIMESTAMP_F, tempArray);
    
      dims[1] = ReadDataCount;
      tempArray = mxCreateNumericArray(ndim, dims, mxDOUBLE_CLASS, mxREAL);
      IDArray = mxGetPr(tempArray);
      mxSetFieldByNumber(outstruct, 0, SPIKEID_F, tempArray);
    
      ndim = 3; dims[1] = nChans; dims[0] = lWaveform; dims[2] = ReadDataCount;
      tempArray = mxCreateNumericArray(ndim, dims, mxINT16_CLASS, mxREAL);
      WaveformsS = mxGetData(tempArray);
      mxSetFieldByNumber(outstruct, 0, WAVEFORM_F, tempArray);

      fseek(InFD, fileinfo.dwHeaderSize, SEEK_SET);
    
      sprintf(TempBuffer,"%s: Reading in data.\n", FUNCNAME);
      mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

      for(i=0; i < ReadDataCount; i++) {    
	iter = ReadDataTable[i];
      
	fseek(InFD, fileinfo.dwHeaderSize+iter*RecordLength,0);
	fread(&TimeStamp, sizeof(long), 1, InFD);
	TimeStampArray[i] = (double) (TimeStamp/mwl_MASTERCLOCKFREQ);
	IDArray[i] = (double)iter+1;
      
	fread(waveform, sizeof(short), nChans*lWaveform, InFD);
	for(elec=0; elec < nChans; elec++)
	  for(samp=0; samp < lWaveform; samp++)
	    WaveformsS[M3D(samp, elec, i, lWaveform, nChans)] =
	      (short)(waveform[M2D(elec, samp, nChans)]); 
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

  mxSetFieldByNumber(infostruct, 0, MWLTYPE_F, mxCreateString(MWLTS_WAVEFORM));

  time(&TSeconds);
  DateBuffer = ctime(&TSeconds); 
  mxSetFieldByNumber(infostruct, 0, DATE_F,
		     mxCreateString(DateBuffer));

  mxSetFieldByNumber(infostruct, 0, CREATEFUNC_F,
		     mxCreateString(FUNCNAME));
  
  mxSetFieldByNumber(infostruct, 0, PROBE_F, 
		     mxCreateDoubleScalar((double)ProbeNumber));
  mxSetFieldByNumber(infostruct, 0, SAMPLEFREQ_F, 
		     mxCreateDoubleScalar((double)(SampFrequency/nTotalChannels)));
  mxSetFieldByNumber(infostruct, 0, NCHAN_F, 
		     mxCreateDoubleScalar((double)nChans));
  mxSetFieldByNumber(infostruct, 0, SPIKELEN_F, 
		     mxCreateDoubleScalar((double)lWaveform));
  mxSetFieldByNumber(infostruct, 0, SPIKESEP_F, 
		     mxCreateDoubleScalar((double)SpikeSeperation));

  mxSetFieldByNumber(infostruct, 0, UNITS_F, 
		     mxCreateString("ADC"));

  tempArray = mxCreateDoubleMatrix(1, nChans, mxREAL);
  pArray = mxGetPr(tempArray);
  /* retrieve gains */
  for (i=(ProbeNumber*nChans); i<((ProbeNumber+1)*nChans); i++) {
    sprintf(TempBuffer, "channel %ld ampgain:", i);
    if (( headerfield = (char *)GetHeaderParameter(headercontents, TempBuffer) )!=NULL ) {
      pArray[i] = atof(headerfield);
    } else {
      sprintf(TempBuffer,"%s: Unable to retrieve gain information.", FUNCNAME);
      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    }
  }
  mxSetFieldByNumber(infostruct, 0, GAIN_F, 
		     tempArray);

  tempArray = mxCreateDoubleMatrix(2, nChans, mxREAL);
  pArray = mxGetPr(tempArray);
  /* retrieve filter settings */
  for (i=(ProbeNumber*nChans); i<((ProbeNumber+1)*nChans); i++) {
    sprintf(TempBuffer, "channel %ld filter:", i);
    if (( headerfield = (char *)GetHeaderParameter(headercontents, TempBuffer) )!=NULL ) {
      filtersetting = atoi(headerfield);
      mwl_ConvertFilterSetting(filtersetting, &pArray[2*(i-ProbeNumber*nChans)], &pArray[2*(i-ProbeNumber*nChans)+1]);
    } else {
      sprintf(TempBuffer,"%s: Unable to retrieve filter information.", FUNCNAME);
      mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    }
  }
  mxSetFieldByNumber(infostruct, 0, FILTER_F, 
		     tempArray);

  tempArray = mxCreateDoubleMatrix(1,2,mxREAL);
  pArray = mxGetPr(tempArray); 
  pArray[0] = -2048;
  pArray[1] = 2047;
  mxSetFieldByNumber(infostruct, 0, ADCRANGE_F, 
		     tempArray);

  tempArray = mxCreateDoubleMatrix(1,2,mxREAL);
  pArray = mxGetPr(tempArray); 
  pArray[0] = -10;
  pArray[1] = 10;
  mxSetFieldByNumber(infostruct, 0, INPUTRANGE_F, 
		     tempArray);


  tempArray = mxCreateDoubleMatrix(1,2,mxREAL);
  pArray = mxGetPr(tempArray); 
  pArray[0] = StartTime;
  pArray[1] = EndTime;
  mxSetFieldByNumber(infostruct, 0, TIMESPAN_F, 
		     tempArray);
  
  /*****CREATE SOURCE STRUCTURE*******/




  /*****************************Done*******************************/

  sprintf(TempBuffer,"%s: Successful.\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  if(ReadDataTable != NULL)
    mxFree(ReadDataTable);
  if(FilterParams != NULL)
    mxFree(FilterParams);

  if (InFD!=NULL)
    fclose(InFD);

  return;
}


/*
 *$Log: tt2mat.c,v $
 *Revision 1.15  2004/11/07 04:58:54  fabian
 *replaced ctime_r call by ctime call (Windows compatibility reasons)
 *
 *Revision 1.14  2004/05/18 18:17:28  fabian
 *bug fix: waveform data returned in original file data type now has properly colum/row orientation
 *
 *Revision 1.13  2004/01/14 01:35:27  dpnguyen
 *updated output structures to include mwltype under each info field
 *
 *Revision 1.12  2003/12/12 21:47:18  dpnguyen
 *removed Fabian's c++ style comments
 *
 *Revision 1.11  2003/12/12 03:23:50  dpnguyen
 *forgot to indent
 *
 *Revision 1.10  2003/12/12 03:05:17  dpnguyen
 *added support for the (+) and (-) data options
 *
 *Revision 1.9  2003/12/01 21:10:06  fabian
 *updated to work with new mwl_CheckFilterParams
 *timestamps now always returned in seconds
 *
 *Revision 1.8  2003/11/26 02:57:01  dpnguyen
 *implemented multi-block parameter types
 *
 *Revision 1.7  2003/11/26 02:36:58  dpnguyen
 *made updates for incorporating FTSpikeID
 *Checking to see if FTSpikeID is suppported
 *
 *Revision 1.6  2003/11/26 01:51:38  fabian
 *added record index as a filter type, changed #define FTSampleID to FTSpikeID, and updated p2mat, pos2mat, tt2mat
 *
 *Revision 1.5  2003/11/25 00:53:42  dpnguyen
 *brought code up to date with mwl_FileSourceStructure
 *
 *Revision 1.4  2003/11/23 17:26:54  dpnguyen
 *changed setup of code to rely on the header for parameters
 *
 *Revision 1.3  2003/11/23 08:24:05  dpnguyen
 *fixed the option character from 'o' to 'p' to preserve original format
 *  in mwlParseFilterParams
 *In tt2mat, fixed a bug in code that reads data in original format
 *
 *Revision 1.2  2003/11/23 06:58:33  dpnguyen
 *major changes, tt2mat.c still needs some attention
 *made a new function in mwlParseFilterparams (checkFilterParams)
 *used checkFilterParams in tt2mat.c
 *
 *Revision 1.1  2003/11/21 20:50:00  fabian
 *added tt2mat function to import waveform data from .tt files
 *
 *Revision 1.4  2003/11/10 20:28:29  fabian
 *Major update: include support for parameter name/value pairs in eeg2mat, event2mat, tt2mat and fv2mat, debugged all of them: no crashes anymore (??)
 *
 *Revision 1.3  2003/11/07 19:57:49  fabian
 *added brand new function for parsing prop name / prop value pairs
 *also included is a small test mex function
 *
 *Revision 1.2  2003/11/05 02:59:58  fabian
 *major bug fixes: now it actually works
 *
 */
