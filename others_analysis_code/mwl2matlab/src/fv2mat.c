/******************************************************************************
 
Filename: fv2mat.c

Function: mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )

Input:

 Filename [string]                           required
 Features [vector of indices or cell array of names] optional
 ParameterString [string]                    optional
 Index Vector                                optional, but required if filtering is applied

Output:
 Features [structure]                                  required
     field names [cell array of strings]
     featuredata [matrix]
     info

Description:
       Load spike features from a MWL .pxyabw file into a Matlab matrix

Author: David P. Nguyen (dpnguyen@mit.edu) and Fabian Kloosterman (fkloos@mit.edu)



$Id: fv2mat.c,v 1.3 2004/01/14 01:35:27 dpnguyen Exp $
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

#define FUNCNAME "fv2mat"

const char *usage1 = " USAGE: \nfeatures = fv2mat( FileName, [Features], [Parameter String], [Indexing Vector] )\n";

const char *field_names1[] = {"featurenames", "featuredata", "info"};
enum Field1Numbers {FEATURENAMES_F=0, FEATUREDATA_F, INFO_F, N_FIELDS1};
const char *field_names2[] = {"source", "mwltype"};
enum Field2Numbers {SOURCE_F=0, MWLTYPE_F, N_FIELDS2};


void swap(unsigned long source[], int i, int j) {

  unsigned long tmp=source[i];
  source[i] = source[j];
  source[j] = tmp;

}

int intrandom(int i, int j) {
  return i+rand() % (j-i+1);
}

void quickindexing(unsigned long source[], long left, long right, unsigned long index[]) {

  int last = left, i;
  if (left>=right) return;

  swap(index, left, intrandom(left, right));

  for (i=left+1; i<=right; i++) 
    if (source[index[i]] < source[index[left]])
      swap(index, ++last, i);
  swap(index, left, last);
  quickindexing(source, left, last-1, index);
  quickindexing(source, last+1, right, index);

}

void indexx(unsigned long source[], unsigned long nitems, unsigned long index[]) {
  int i;
  for (i=0; i<nitems; i++) index[i] = i;
  quickindexing(source, 0, nitems-1, index);
}

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

unsigned long convert2ulong(val, type)
     void *val;
     uint32 type;
{

  switch (type) {
  case SHORT:
    return *(short*)val;
  case ULONG:
    return *(unsigned long*)val;
  case DOUBLE:
    return *(double*)val;
  case FLOAT:
    return *(float*)val;
  case INT:
    return *(int*)val;
  case CHAR:
    return *(char*)val;
  }

  return 0;
}

int convert2int(val, type)
     void *val;
     uint32 type;
{

  switch (type) {
  case SHORT:
    return *(short*)val;
  case ULONG:
    return *(unsigned long*)val;
  case DOUBLE:
    return *(double*)val;
  case FLOAT:
    return *(float*)val;
  case INT:
    return *(int*)val;
  case CHAR:
    return *(char*)val;
  }

  return 0;
}

double convert2double(val, type)
     void *val;
     uint32 type;
{

  switch (type) {
  case SHORT:
    return *(short*)val;
  case ULONG:
    return *(unsigned long*)val;
  case DOUBLE:
    return *(double*)val;
  case FLOAT:
    return *(float*)val;
  case INT:
    return *(int*)val;
  case CHAR:
    return *(char*)val;
  }

  return 0;
}

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{

  /**********************************variables************************/

  /* general variables */
  char nAmpFields = 5;
  char nPosFields = 3;
  const char *AmpFields[] = {"id", "t_px", "t_py", "t_pa", "t_pb"};
  const char *PosFields[] = {"id", "pos_x", "pos_y"};
  long i,j,k;
  char TempBuffer[mwl_MAXSTRING];
  char TempBuffer2[mwl_MAXSTRING];
  int BlockCount, colcount;

  /* input checking variables */
  BOOL FeaturesSpecified = FALSE;
  int NextParameter;
  mwl_ParamInfo ParamInfo, *paraminfo;

  /* file variables */
  char strFileName[mwl_MAXSTRING];
  FILE *Fin = NULL;
  char **HeaderContents = NULL;
  int HeaderSize;
  mwl_FILEINFO FileInfo;

  /* file info variables */
  BOOL TimeStampFieldPresent = FALSE, TimeFieldPresent=FALSE;
  int RecordSize;
  unsigned long FileSize, nRecords;
  unsigned long StartTimeStamp=0, EndTimeStamp=0;
  double StartTime=0, EndTime=0;
  unsigned long StartSpikeIndex=0, EndSpikeIndex=0;

  /* field variables */
  char *FieldMask = NULL;
  int *FieldOffset = NULL;
  unsigned long FeatureVectorSize;
  double *pFieldVector;
  int nLoadFeatures;
  int SpikeFieldID, TimeFieldID=0;
  void *pFieldData = NULL;
  double *FeatureArray = NULL;

  /* filtering variables */
  int nBlocks;
  unsigned long *FilterParams = NULL;
  unsigned long TimeStamp;

  /* output variables */
  mxArray *OutStruct, *TempArray, *pCell=NULL, *InfoStruct;
  int ndim, *dims, nfields;

  unsigned long *ReadDataTable = NULL;
  unsigned long RecordCount = 0;
  unsigned long ReadDataCount = 0;


  unsigned long *IDTable = NULL;
  unsigned long *TempList = NULL;
  unsigned long ia, Counter;

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

  /* is there a second input specifying the features to retrieve?*/
  FeaturesSpecified = FALSE;
  NextParameter = 1;
  if (nrhs>1){
    if ( (mxIsDouble(prhs[1]) || mxIsCell(prhs[1])) && !mxIsEmpty(prhs[1]) ) {
      FeaturesSpecified = TRUE;
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
  case FTSpikeID: 
    break;
  default:
    sprintf(TempBuffer,"%s: Unsupported Filter Type", FUNCNAME);
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
    
  /* is it a .pxyabw file? */
  if (FileInfo.dwFileType != mwl_FILETYPE_PXYABW) {
    sprintf(TempBuffer, "%s: This is not an pxyabw file", FUNCNAME);
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

  /* VERBOSE */
  sprintf(TempBuffer, "%s: File size: %ld bytes, Header size %d bytes", FUNCNAME, FileSize, HeaderSize);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  sprintf(TempBuffer, "%s: Record size: %d bytes, # Records: %ld", FUNCNAME, RecordSize, nRecords);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);

  /**********************check requested fields*********************/

  FieldMask = (char *) mxCalloc(FileInfo.dwFieldCount, sizeof(char));
  for (i=0; i<FileInfo.dwFieldCount; i++) {
    FieldMask[i]=0;
  }

  FieldOffset = (int *) mxCalloc(FileInfo.dwFieldCount, sizeof(int));
  FieldOffset[0]=0;
  for (i=1; i<FileInfo.dwFieldCount; i++) {
    FieldOffset[i] = FieldOffset[i-1] + FileInfo.pFieldInfo[i-1].dwElementSize * FileInfo.pFieldInfo[i-1].dwLength;
  }

  if (FeaturesSpecified) {

    FeatureVectorSize = mxGetN(prhs[1])*mxGetM(prhs[1]);

    if (mxIsDouble(prhs[1])) {

      pFieldVector = mxGetPr(prhs[1]);
      for (i=0; i<FeatureVectorSize; i++)
	if (pFieldVector[i]>=1 && pFieldVector[i]<=FileInfo.dwFieldCount)
	  FieldMask[(int) pFieldVector[i]-1] = 1;

    } else if (mxIsCell(prhs[1])) {

      for (i=0; i<FeatureVectorSize; i++) {
	pCell = mxGetCell(prhs[1], i);
	if (mxIsChar(pCell)) {
	  mxGetString(pCell, TempBuffer, mwl_MAXSTRING);

	  /* check for special strings */
	  if (strcmp(TempBuffer, "all") == 0) {
	    for (j=0; j<FileInfo.dwFieldCount; j++)
	      FieldMask[j] = 1;
	  } else if (strcmp(TempBuffer, "amp") == 0) {
	    for (j=0; j<nAmpFields; j++) {
	      for (k=0; k<FileInfo.dwFieldCount; k++) {
		if (strcmp(FileInfo.pFieldInfo[k].szFieldLabel, AmpFields[j])==0) {
		  FieldMask[k] = 1;
		  break;
		}
	      }
	    }
	  } else if (strcmp(TempBuffer, "pos")==0) {
	    for (j=0; j<nPosFields; j++) {
	      for (k=0; k<FileInfo.dwFieldCount; k++) {
		if (strcmp(FileInfo.pFieldInfo[k].szFieldLabel, PosFields[j])==0) {
		  FieldMask[k] = 1;
		  break;
		}
	      }
	    }
	  } else {
	    for (j=0; j<FileInfo.dwFieldCount; j++) {
	      if (strcmp(FileInfo.pFieldInfo[j].szFieldLabel, TempBuffer) == 0) {
		FieldMask[j] = 1;
		break;
	      }
	    }
	  }
	}
      }
    }
    /* if not, load all features */
  } else {
    for (i=0; i<FileInfo.dwFieldCount; i++)
      FieldMask[i] = 1;
  }

  /* check the number of features to load */
  nLoadFeatures = 0;
  for (i=0; i<FileInfo.dwFieldCount; i++) {
    if (FieldMask[i] == 1)
      nLoadFeatures++;
  }

  if (nLoadFeatures==0) {
    sprintf(TempBuffer, "%s: No valid features specified", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    if (Fin!=NULL)
      fclose(Fin);
    return;
  }

  /* VERBOSE */
  sprintf(TempBuffer,"%s: Feature mask created.", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  sprintf(TempBuffer,"%s: Feature mask: ", FUNCNAME);
  for (i=0; i<FileInfo.dwFieldCount; i++) {
    sprintf(TempBuffer2,"%d",FieldMask[i]);
    strcat(TempBuffer,TempBuffer2);
  }
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  sprintf(TempBuffer, "     -> %d features selected for importing.", nLoadFeatures);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);


  /*****************************GET START/END TIME/INDICES*********************/

  /* start and end spike index */
  SpikeFieldID = 0;
  pFieldData = mxCalloc(1, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize);
  fseek(Fin, HeaderSize + FieldOffset[SpikeFieldID], 0);
  fread(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize,1,Fin);
  StartSpikeIndex = convert2int(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwType);
  fseek(Fin, HeaderSize + (nRecords-1)*RecordSize + FieldOffset[SpikeFieldID], 0);
  fread(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize,1,Fin);
  EndSpikeIndex = convert2int(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwType);
  mxFree(pFieldData);


  /* start and end time(stamp) */
  /* is there a timestamp or time field? */
  TimeStampFieldPresent = FALSE;
  TimeFieldPresent = TRUE;

  for (i=0; i<FileInfo.dwFieldCount; i++) {
    if (strcmp(FileInfo.pFieldInfo[i].szFieldLabel, "timestamp")==0) {
      TimeFieldID = i;
      TimeStampFieldPresent = TRUE;
      pFieldData = mxCalloc(1, FileInfo.pFieldInfo[TimeFieldID].dwElementSize);
      fseek(Fin, HeaderSize + FieldOffset[TimeFieldID], 0);
      fread(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwElementSize,1,Fin);
      StartTimeStamp = convert2ulong(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwType);
      fseek(Fin, HeaderSize + (nRecords-1)*RecordSize + FieldOffset[TimeFieldID], 0);
      fread(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwElementSize,1,Fin);
      EndTimeStamp = convert2ulong(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwType);
      StartTime = (double) StartTimeStamp / mwl_MASTERCLOCKFREQ;
      EndTime = (double) EndTimeStamp / mwl_MASTERCLOCKFREQ;
      mxFree(pFieldData);
      break;
    } else if (strcmp(FileInfo.pFieldInfo[i].szFieldLabel, "time")==0) {
      TimeFieldID = i;
      TimeFieldPresent = TRUE;
      pFieldData = mxCalloc(1, FileInfo.pFieldInfo[TimeFieldID].dwElementSize);
      fseek(Fin, HeaderSize + FieldOffset[TimeFieldID], 0);
      fread(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwElementSize,1,Fin);
      StartTime = convert2double(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwType);
      fseek(Fin, HeaderSize + (nRecords-1)*RecordSize + FieldOffset[TimeFieldID], 0);
      fread(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwElementSize,1,Fin);
      EndTime = convert2double(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwType);
      StartTimeStamp = (unsigned long) (StartTime * mwl_MASTERCLOCKFREQ);
      EndTimeStamp = (unsigned long) (EndTime * mwl_MASTERCLOCKFREQ);
      mxFree(pFieldData);
      break;
    }
  }

  if (!TimeStampFieldPresent && !TimeFieldPresent && (paraminfo->FilterType == FTTimeStamp || paraminfo->FilterType == FTSeconds) ) {
    sprintf(TempBuffer, "%s: No time information in file, cannot filter on second or timestamps. Abort.", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
  }

  /* VERBOSE */
  if (TimeStampFieldPresent || TimeFieldPresent) {
    sprintf(TempBuffer, "%s: Start timestamp: %ld, end time stamp: %ld", FUNCNAME, StartTimeStamp, EndTimeStamp);
    mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
    sprintf(TempBuffer, "%s: Start time: %f, end time: %f", FUNCNAME, StartTime, EndTime);
    mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  } else {
    sprintf(TempBuffer, "%s: No time fields present in file", FUNCNAME);
    mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);
  }
  sprintf(TempBuffer, "%s: Start spike index: %ld, end spike index: %ld", FUNCNAME, StartSpikeIndex, EndSpikeIndex);
  mwlPrintf(TempBuffer, VBDetail, paraminfo->Verbose);


  /***************************** PROCESS PARAMETERS ***************************/
  
  sprintf(TempBuffer,"%s: Processing parameters\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  nBlocks = 0;
  if(mwl_CheckFilterParamADIO(paraminfo, prhs[NextParameter+1], StartTimeStamp, EndTimeStamp, StartSpikeIndex, EndSpikeIndex, nRecords, &FilterParams, &nBlocks) < 0)
    return;
  
  /**************************** PROCESS FILTER ****************************/

  sprintf(TempBuffer,"%s: Determining what data to read in.\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  switch (paraminfo->FilterType) {
  case FTNone:
    ReadDataTable = mxCalloc(sizeof(long), nRecords);
    ReadDataCount = 0;
    RecordCount = 0;
    for (RecordCount=0; RecordCount<nRecords; RecordCount++)
      ReadDataTable[RecordCount] = RecordCount;
    ReadDataCount = nRecords;
    break;
  case FTTimeStamp:
  case FTSeconds:
    ReadDataTable = mxCalloc(sizeof(long), nRecords);
    ReadDataCount = 0;
    RecordCount = 0;

    if (TimeStampFieldPresent) {

      pFieldData = mxCalloc(1, FileInfo.pFieldInfo[TimeFieldID].dwElementSize);

      for (RecordCount=0; RecordCount<nRecords; RecordCount++) {
	fseek(Fin, HeaderSize + RecordCount*RecordSize + FieldOffset[TimeFieldID], 0);
	fread(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwElementSize,1,Fin);
	TimeStamp = convert2ulong(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwType);

	for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {
	  if ((TimeStamp >= FilterParams[M2D(BlockCount,0,nBlocks)]) && (TimeStamp <= FilterParams[M2D(BlockCount,1,nBlocks)])) {
	    ReadDataTable[ReadDataCount] = RecordCount;
	    ReadDataCount++;
	    break;
	  }
	}
      }

      mxFree(pFieldData);

    } else if (TimeFieldPresent) {

      pFieldData = mxCalloc(1, FileInfo.pFieldInfo[TimeFieldID].dwElementSize);

      for (RecordCount=0; RecordCount<nRecords; RecordCount++) {
	fseek(Fin, HeaderSize + RecordCount*RecordSize + FieldOffset[TimeFieldID], 0);
	fread(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwElementSize,1,Fin);
	TimeStamp = (unsigned long) ( convert2double(pFieldData, FileInfo.pFieldInfo[TimeFieldID].dwType) * mwl_MASTERCLOCKFREQ);

	for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {
	  if ((TimeStamp >= FilterParams[M2D(BlockCount,0,nBlocks)]) && (TimeStamp <= FilterParams[M2D(BlockCount,1,nBlocks)])) {
	    ReadDataTable[ReadDataCount] = RecordCount;
	    ReadDataCount++;
	    break;
	  }
	}
      }

      mxFree(pFieldData);
    }
    break;
  case FTRecordID:

    ReadDataTable = mxCalloc(sizeof(long), nRecords);
    ReadDataCount = 0;
    RecordCount = 0;

    if (paraminfo->FilterParamType == FPTBlock) {
      for (RecordCount=1; RecordCount<=nRecords; RecordCount++) {
	for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {
	  if ( (RecordCount>= FilterParams[M2D(BlockCount, 0, nBlocks)]) && (RecordCount <= FilterParams[M2D(BlockCount,1,nBlocks)]) ) {
	    ReadDataTable[ReadDataCount] = RecordCount - 1;
	    ReadDataCount++;
	  }
	}
      }
    } else if (paraminfo->FilterParamType == FPTArray) {
      for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {
	if (FilterParams[BlockCount] >= 1 && FilterParams[BlockCount] <= nRecords) {
	  ReadDataTable[ReadDataCount] = FilterParams[BlockCount];
	  ReadDataCount++;
	}
      }
    }

    break;
  case FTSpikeID:
    

    if (paraminfo->FilterParamType == FPTBlock) {
    
      ReadDataTable = mxCalloc(sizeof(long), nRecords);
      ReadDataCount = 0;
      RecordCount = 0;

      pFieldData = mxCalloc(1, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize);
      
      for (RecordCount=0; RecordCount<nRecords; RecordCount++) {
	fseek(Fin, HeaderSize + RecordCount*RecordSize + FieldOffset[SpikeFieldID], 0);
	fread(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize,1,Fin);
	TimeStamp = (unsigned long) convert2ulong(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwType)+1;
	
	for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {
	  if ((TimeStamp >= FilterParams[M2D(BlockCount,0,nBlocks)]) && (TimeStamp <= FilterParams[M2D(BlockCount,1,nBlocks)])) {
	    ReadDataTable[ReadDataCount] = RecordCount;
	    ReadDataCount++;
	    break;
	  }
	}
      }
    
      mxFree(pFieldData);

    } else if (paraminfo->FilterParamType == FPTArray) {


      /* create sort index table */
      IDTable = mxCalloc(nBlocks, sizeof(long));
      indexx(FilterParams, nBlocks, IDTable);

      TempList = mxCalloc(nBlocks, sizeof(unsigned long));
      pFieldData = mxCalloc(1, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize);

      ia = 0; RecordCount = 0;
      fseek(Fin, HeaderSize + RecordCount*RecordSize + FieldOffset[SpikeFieldID], 0);
      fread(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize,1,Fin);
      TimeStamp = (unsigned long) convert2ulong(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwType)+1;
      RecordCount++;
      Counter = 0;

      while (RecordCount<nRecords && ia<nBlocks) {

	while (ia<nBlocks && FilterParams[IDTable[ia]]<=TimeStamp) {
	  if (FilterParams[IDTable[ia]]==TimeStamp) {
	    TempList[IDTable[ia]] = RecordCount+1;
	    Counter++;
	  }
	  ia++;
	}

	while (RecordCount<nRecords && ia<nBlocks && FilterParams[IDTable[ia]]>TimeStamp) {
	  fseek(Fin, HeaderSize + RecordCount*RecordSize + FieldOffset[SpikeFieldID], 0);
	  fread(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize,1,Fin);
	  TimeStamp = (unsigned long) convert2ulong(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwType)+1;
	  RecordCount++;
	}

      }

      ReadDataTable = mxCalloc(sizeof(long), Counter);
      ReadDataCount = 0;
      for (i=0; i<Counter; i++) {
	if (TempList[i]!=0) {
	  ReadDataTable[ReadDataCount] = TempList[i]-1;
	  ReadDataCount++;
	}
      }

    /*
      ReadDataTable = mxCalloc(sizeof(long), nBlocks);
      ReadDataCount = 0;
      RecordCount = 0;
      mexPrintf("nBlocks: %d\n", nBlocks);
      pFieldData = mxCalloc(1, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize);
      
      for (RecordCount=0; RecordCount<nRecords; RecordCount++) {
      fseek(Fin, HeaderSize + RecordCount*RecordSize + FieldOffset[SpikeFieldID], 0);
      fread(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwElementSize,1,Fin);
      TimeStamp = (unsigned long) convert2ulong(pFieldData, FileInfo.pFieldInfo[SpikeFieldID].dwType)+1;
      
      for (BlockCount=0; BlockCount<nBlocks; BlockCount++) {
      if (TimeStamp == FilterParams[BlockCount]) {
      ReadDataTable[ReadDataCount] = RecordCount;
      ReadDataCount++;
      }
      }
      }*/
    
    }

    break;
  }


  /***************************LOAD DATA**********************************/

  if (ReadDataCount<1) {
    sprintf(TempBuffer, "%s: No data matches filter", FUNCNAME);
    mwlPrintf(TempBuffer, VBError, 0);
    if (HeaderContents!=NULL)
      free(HeaderContents);
    if (Fin!=NULL)
      fclose(Fin);
    return;
  }

  ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS1;
  OutStruct = mxCreateStructArray(ndim, dims, nfields, field_names1);
  plhs[0] = OutStruct;

  TempArray = mxCreateDoubleMatrix(ReadDataCount, nLoadFeatures, mxREAL);
  FeatureArray = mxGetPr(TempArray);
  mxSetFieldByNumber(OutStruct, 0, FEATUREDATA_F, TempArray);

  /* loop through all fields */
  colcount = 0;
  for (i=0; i<FileInfo.dwFieldCount; i++) {

    if (FieldMask[i]==1) {

      /* loop through all records */
      pFieldData = mxCalloc(1, FileInfo.pFieldInfo[i].dwElementSize);

      for (RecordCount=0; RecordCount<ReadDataCount; RecordCount++) {

	fseek(Fin, HeaderSize + ReadDataTable[RecordCount]*RecordSize + FieldOffset[i], 0);
	fread(pFieldData, FileInfo.pFieldInfo[i].dwElementSize, 1, Fin);
	FeatureArray[colcount*ReadDataCount + RecordCount] = convert2double(pFieldData, FileInfo.pFieldInfo[i].dwType);
      }
      mxFree(pFieldData);
      colcount++;
    }
  }

  sprintf(TempBuffer,"%s: Data successfully loaded.\n", FUNCNAME);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);


  TempArray = mxCreateCellMatrix(1, nLoadFeatures);
  colcount = 0;
  for (i=0; i<FileInfo.dwFieldCount; i++) {
    if (FieldMask[i] == 1) {
      mxSetCell(TempArray, colcount, mxCreateString(FileInfo.pFieldInfo[i].szFieldLabel));
      colcount++;
    }
  }
  mxSetFieldByNumber(plhs[0], 0, FEATURENAMES_F, TempArray);


  ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS2;
  InfoStruct = mxCreateStructArray(ndim, dims, nfields, field_names2);

  mxSetFieldByNumber(OutStruct, 0, INFO_F, InfoStruct);

  mxSetFieldByNumber(InfoStruct, 0, SOURCE_F,
		     mwl_FileSourceStructure(Fin, FUNCNAME, paraminfo));

  mxSetFieldByNumber(InfoStruct, 0, MWLTYPE_F, mxCreateString(MWLTS_FEATUREVECTOR));
		     

  /******************************Done********************************/

  if (HeaderContents!=NULL)
    free(HeaderContents);

  if (Fin!=NULL)
    fclose(Fin);


}
