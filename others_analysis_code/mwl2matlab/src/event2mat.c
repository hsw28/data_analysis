/******************************************************************************
 
Filename: event2mat.c

Function: mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )

Input:

 Filename [string]                           required

Output:

 Events [structure]
     time [vector]
     events [cell array]
     info [structure]

Description:
       Load events from a .es file into Matlab

Author: David P. Nguyen (dpnguyen@mit.edu) and Fabian Kloosterman (fkloos@mit.edu)



$Id: event2mat.c,v 1.3 2004/01/14 01:35:27 dpnguyen Exp $
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

#define FUNCNAME "event2mat"

const char *usage1 = " USAGE: \nevents = event2mat( FileName )\n";

const char *field_names1[] = {"timestamp", "event", "info"};
enum Field1Numbers {TIME_F=0, EVENT_F, INFO_F, N_FIELDS1};
const char *field_names2[] = {"source", "mwltype"};
enum Field2Numbers {SOURCE_F=0, MWLTYPE_F, N_FIELDS2};

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
  /* iterators */
  long i,r;

  /* strings */
  char TempBuffer[mwl_MAXSTRING];
  char strFileName[mwl_MAXSTRING];

  /* parameter processing variables */
  mwl_ParamInfo ParamInfo, *paraminfo;

  /* file variables */
  FILE *Fin = NULL;
  char **HeaderContents = NULL;
  int HeaderSize;
  mwl_FILEINFO FileInfo;

  /* file info */
  int RecordSize;
  unsigned long FileSize, nRecords;

  /* output variables */
  int ndim, *dims, nfields;
  double *TimeArray = NULL;
  mxArray *OutStruct, *TempArray, *InfoStruct;
  char *EventData = NULL;
  unsigned long TimeStamp;


  /*****************************input argument check******************/
  paraminfo = &ParamInfo;
  dims = mxCalloc(3, sizeof(int));


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


  /* do the parameters */
  if(nrhs > (2)) {
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
  if (FileInfo.dwFileType != mwl_FILETYPE_EVENT) {
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

  /********************************LOAD DATA***************************/

  if (nRecords<1) {
    sprintf(TempBuffer, "%s: No data.", FUNCNAME);
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

  TempArray = mxCreateDoubleMatrix(nRecords, 1, mxREAL);
  TimeArray = mxGetPr(TempArray);
  mxSetFieldByNumber(OutStruct, 0, TIME_F, TempArray);

  TempArray  = mxCreateCellMatrix(nRecords, 1);

  EventData = mxCalloc(FileInfo.pFieldInfo[1].dwLength, sizeof(char));

  for (r=0; r<nRecords; r++) {

    fseek(Fin, HeaderSize + r*RecordSize, 0);
    fread(&TimeStamp, sizeof(unsigned long), 1, Fin);
    TimeArray[r] = (double) (TimeStamp/mwl_MASTERCLOCKFREQ);

    fread(EventData, sizeof(char), FileInfo.pFieldInfo[1].dwLength, Fin);
    mxSetCell(TempArray, r, mxCreateString(EventData));

  }

  mxSetFieldByNumber(OutStruct, 0, EVENT_F, TempArray);

  /* VERBOSE */
  sprintf(TempBuffer, "%s: %ld events successfully loaded.", FUNCNAME, nRecords);
  mwlPrintf(TempBuffer, VBNormal, paraminfo->Verbose);

  /************* CREATE INFO STRUCTURE AND SET IT **********/
  ndim = 2; dims[0] = 1; dims[1] = 1; nfields = N_FIELDS2;
  InfoStruct = mxCreateStructArray(ndim, dims, nfields, field_names2);

  mxSetFieldByNumber(OutStruct, 0, INFO_F, InfoStruct);

  mxSetFieldByNumber(InfoStruct, 0, SOURCE_F,
		     mwl_FileSourceStructure(Fin, FUNCNAME, paraminfo));

  mxSetFieldByNumber(InfoStruct, 0, MWLTYPE_F, mxCreateString(MWLTS_EVENT));

  /******************************Done********************************/

  if (HeaderContents!=NULL)
    free(HeaderContents);

  if (Fin!=NULL)
    fclose(Fin);


}
