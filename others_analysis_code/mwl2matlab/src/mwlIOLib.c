/******************************************************************************
 
Filename: mwlIOLib.c

Function: standard routines written by Matt Wilson <wilson@ai.mit.edu>
You can find the prototypes in mwlAPITypes.h

Input: -

Output: -

Description: definitions of data and info structures

Author: David P. Nguyen (dpnguyen@mit.edu) and Fabian Kloosterman (fkloos@mit.edu)

$Id: mwlIOLib.c,v 1.15 2004/11/21 00:20:25 fabian Exp $

******************************************************************************/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <mex.h>
#include "mwlIOLib.h"
#include "mwlAPItypes.h"


/* timestamp sample frequency */
#define MWLTIMESTAMPFREQ 10000.0f;


void mwlPrintf(const char *msg, int MsgVerboseLevel, int UserRequestedLevel) {
  int temp;
  switch(MsgVerboseLevel) {
  case VBNormal:
  case VBDetail:
    temp = strlen(msg);
    if(UserRequestedLevel)
      if(UserRequestedLevel >= MsgVerboseLevel) {
	mexPrintf(msg);
	if(msg[temp-1] != '\n')
	  mexPrintf("\n");
      }
    break;
  case VBWarning:
    if(UserRequestedLevel)
      if(UserRequestedLevel >= VBWarning)
	mexWarnMsgTxt(msg);
    break;
  case VBError:
    mexWarnMsgTxt(msg);
    break;
  default:
    break;
  }
}


int GetLine(char *line,int maxline,FILE *fp)
{
  int	eoh_offset;
  char	eoh_str[80];
  char	c;
  int	i,j;

  /*
  ** read in a line, checking for the magic end-of-header string
  ** anywhere in the line
  */
  eoh_offset = 0;
  sprintf(eoh_str,"%s\n",MAGIC_EOH_STR);
  for(i=0;i<maxline-1;i++){
    c = fgetc(fp);
    if(c == eoh_str[eoh_offset]){
      /*
      ** bump to the next char
      */
      eoh_offset++;
      if(eoh_offset == strlen(eoh_str)){
	/*
	** found the magic string
	*/
	return(-2);
      }
    } else {
      if(eoh_offset > 0){
	/*
	** output the held partial match characters
	*/
	for(j=0;j<eoh_offset;j++){
	  line[i-eoh_offset+j] = eoh_str[j];
	}
      }
      eoh_offset = 0;
      if(c == '\n') break;
      line[i] = c;
    }
  }
  /*
  ** null terminate the line
  */
  line[i] = '\0';
  return(i);
}

char **ReadHeader(fp,headersize)
     FILE	*fp;
     int	*headersize;
{
  int	hasheader;
  char	line[MAXLINE];
  long	start;
  char	**header_contents;
  char	**new_header_contents;
  int	nheaderlines;
  int	done;
  int	status;
  /*int	eol;*/

  if(fp == NULL) return(NULL);
  if(headersize == NULL) return(NULL);
  hasheader = 1;
  nheaderlines = 0;
  header_contents = NULL;
  done = 0;
  /*
  ** determine the starting file position
  */
  start = ftell(fp);
  /*
  ** look for the magic start-of-header string
  */
  if(fread(line,sizeof(char),MAGIC_SOH_STRSIZE,fp) != MAGIC_SOH_STRSIZE){
    /*
    ** unable to read the header
    */
    hasheader = 0;
  } else {
    /*
    ** null terminate the string
    */
    line[MAGIC_SOH_STRSIZE-1] = '\0';
    /*
    ** is it the magic start of header string?
    */
    if((status = strcmp(line,MAGIC_SOH_STR)) != 0){
      /*
      ** not the magic string
      */
      hasheader = 0;
    } 
  }
  if(!hasheader){
    /*
    ** no header was found so reset the file position to its starting
    ** location
    */
    fseek(fp,start,0L);
  } else
    /*
    ** read the header
    */
    while(!done && !feof(fp)){	
      if((status = GetLine(line,MAXLINE,fp)) <= 0){
	if(status == -2){
	  /*
	  ** found the magic end-of-header string
	  */
	  done = 1;
	} else {
	  /*
	  ** unable to read the header
	  */
	  fprintf(stderr,"ERROR in file header. Abnormal termination\n");
	  return(NULL);
	}
      } else {
	/*
	** add the string to the list of header contents
	** by reallocating space for the header list
	** (dont forget the NULL entry at the end of
	** the list)
	*/
	if(header_contents == NULL){
	  if((header_contents = (char **)malloc(sizeof(char *)*2)) ==
	     NULL){
	    fprintf(stderr,"initial malloc failed. Out of memory\n");
	    break;
	  }
	} else {
	  if((new_header_contents = (char **)calloc(
						    nheaderlines+2,sizeof(char *))) == NULL){
	    fprintf(stderr,"realloc failed. Out of memory\n");
	    break;
	  }
	  /*
	  ** copy the previous contents
	  */
	  bcopy(header_contents,new_header_contents,sizeof(char
							   *)*(nheaderlines +1));
	  /*
	  ** and free the old stuff
	  */
	  free(header_contents);
	  /*
	  ** and reassign to the new stuff
	  */
	  header_contents = new_header_contents;
	}
	if((header_contents[nheaderlines] = 
	    (char *)malloc((strlen(line)+1)*sizeof(char))) == NULL){
	  fprintf(stderr,"malloc failed. Out of memory\n");
	  break;
	}
	strcpy(header_contents[nheaderlines],line);
	header_contents[nheaderlines+1] = NULL;
	nheaderlines++;
      }
    }
  /*
  ** report the headersize by comparing the current position with
  ** the starting position
  */
  *headersize = ftell(fp) - start;
  if(*headersize == 0) return(NULL);
  return(header_contents);
}



/*
** returns the string value of a parameter imbedded in the header
*/
char *GetHeaderParameter(header,parm)
     char	**header;
     char	*parm;
{
  int	i;
  char	*value;
  /*char	*ptr; */

  value = NULL;
  if(header != NULL){
    /*
    ** go through each line of the header
    */
    for(i=0;header[i] != NULL;i++){
      /*
      ** search for the parameter string which must start on the
      ** third character of the line
      */
      if(strlen(header[i]) < 3) continue;
      /*
      ** does it match
      */
      if(strncmp(header[i]+2,parm,strlen(parm)) == 0){
	/*
	** now return the value which begins following
	** the whitespace at the end of the parameter name
	*/
	for(value=header[i]+2+strlen(parm)+1; (value)&&(*value!='\0');value++){
	  /*
	  ** skip white space
	  */
	  if((*value != ' ') && (*value != '\t') && 
	     (*value != '\n')){
	    /*
	    ** found the value and return it
	    */
	    return(value);
	  }
	}
      }
    }
  } 
  return(value);
}



int GetFieldCount(fieldstr)
     char	*fieldstr;
{
  int	count;
  /*char	*sptr; */

  if(fieldstr == NULL){
    return(0);
  }
  /*
  ** parse individual names and assign them to 
  ** projections 
  */
  count = 0;
  while(*fieldstr != '\0'){
    /*
    ** strip off leading white space
    */
    while((fieldstr != NULL) && (*fieldstr != '\0')){
      if((*fieldstr != ' ') && (*fieldstr != '\t')){
	break;
      }
      fieldstr++;
    }
    if(*fieldstr == '\0') return(count);
    /*
    ** find the trailing white space marking the end
    ** of the field descriptor
    */
    while((fieldstr != NULL) && (*fieldstr != '\0')){
      if((*fieldstr == '\t')){     
	/*if((*fieldstr == ' ') || (*fieldstr == '\t')){*/
	break;
      }
      fieldstr++;
    }
    /*
    ** increment the field counter
    */
    count++;
  }
  return(count);
}



#define MAXLINE 1000
int GetFieldInfoByNumber(fieldstr,index,fieldinfo)
     char	*fieldstr;
     int	index;
     FieldInfo	*fieldinfo;
{
  char	*eptr;
  char	*sptr;
  char	line[MAXLINE];
  int	len;
  int	count;

  if(fieldstr == NULL || fieldinfo == NULL){
    return(0);
  }
  /*
  ** parse individual names and assign them to 
  ** projections 
  */
  count = 0;
  sptr = fieldstr;
  while(*sptr != '\0'){
    /*
    ** strip off leading white space
    */
    while((sptr != NULL) && (*sptr != '\0')){
      if((*sptr != ' ') && (*sptr != '\t')){
	break;
      }
      sptr++;
    }
    if(*sptr == '\0') break;
    /*
    ** find the trailing white space marking the end
    ** of the field descriptor
    */
    eptr = sptr;
    while((eptr != NULL) && (*eptr != '\0')){
      if((*eptr == '\t')){  
	/*if((*eptr == ' ') || (*eptr == '\t')){ */
	break;
      }
      eptr++;
    }
    /*
    ** is this the field to process?
    */
    if(count == index){
      /*
      ** copy the field descriptor into temporary storage
      */
      if((len = (int)(eptr - sptr)) >= MAXLINE){
	fprintf(stderr,"field descriptor too long\n");
	return(0);
      }
      strncpy(line,sptr,len);
      line[len] = '\0';
      /*
      ** parse the field descriptor
      */
      if(ParseSingleFieldDescriptor(line,fieldinfo)){
	fieldinfo->column = count;
	return(1);
      } else {
	return(0);
      }
    }
    /*
    ** move to the next descriptor field
    */
    if(*eptr == '\0'){
      sptr = eptr;
    } else {
      sptr = eptr+1;
    }
    /*
    ** increment the field counter
    */
    count++;
  }
  return(0);
}
#undef MAXLINE



char *GetFieldString(header)
     char	**header;
{
  char	*str;

  if(header == NULL) return(NULL);
  if((str = GetHeaderParameter(header,"PARAMETERS:")) == NULL){
    /*
    ** try the other identifier
    */
    str = GetHeaderParameter(header,"Fields:");
  }
  return(str);
}




int ParseSingleFieldDescriptor(fieldstr,fieldinfo)
     char	*fieldstr;
     FieldInfo	*fieldinfo;
{
  char	*sptr;
  char	*eptr;
  int	len;
  char	line[100];

  if(fieldstr == NULL || fieldinfo == NULL) return(0);
  sptr = fieldstr;
  /*
  ** strip off leading white space
  */
  while((sptr != NULL) && (*sptr != '\0')){
    if((*sptr != ' ') && (*sptr != '\t')){
      break;
    }
    sptr++;
  }
  if(*sptr == '\0') return(0);
  /*
  ** the first comma separated string is the field name
  */
  if((eptr = strchr(sptr,',')) == NULL){
    /*
    ** no comma so just take the whole thing
    ** and leave the field descriptor info unknown
    */
    fieldinfo->name = (char *)malloc(strlen(sptr)+1);
    strcpy(fieldinfo->name,sptr);
    fieldinfo->type = -1;
    fieldinfo->size = -1;
    fieldinfo->count = -1;
    return(1);
  } else {
    /*
    ** just take the string up to the comma
    */
    len = (int)(eptr - sptr);
    fieldinfo->name = (char *)malloc(len+1);
    strncpy(fieldinfo->name,sptr,len);
    fieldinfo->name[len] = '\0';
  }
  sptr = eptr + 1;
  /*
  ** the next comma separated field is the type
  */
  if((eptr = strchr(sptr,',')) == NULL){
    /*
    ** no comma so just take the whole thing
    ** and leave the field descriptor info unknown
    */
    fieldinfo->type = atoi(sptr);
    fieldinfo->size = -1;
    fieldinfo->count = -1;
    return(1);
  } else {
    /*
    ** just take the string up to the comma
    */
    len = (int)(eptr - sptr);
    strncpy(line,sptr,len);
    line[len] = '\0';
    fieldinfo->type = atoi(line);
  }
  sptr = eptr + 1;
  /*
  ** the next comma separated field is the size
  */
  if((eptr = strchr(sptr,',')) == NULL){
    /*
    ** no comma so just take the whole thing
    ** and leave the field descriptor info unknown
    */
    fieldinfo->size = atoi(sptr);
    fieldinfo->count = -1;
    return(1);
  } else {
    /*
    ** just take the string up to the comma
    */
    len = (int)(eptr - sptr);
    strncpy(line,sptr,len);
    line[len] = '\0';
    fieldinfo->size = atoi(line);
  }
  sptr = eptr + 1;
  /*
  ** the last field is the count
  */
  /*
  ** no comma so just take the whole thing
  ** and leave the field descriptor info unknown
  */
  fieldinfo->count = atoi(sptr);
  return(1);
}



/* -----------
 * GetFileInfo
 * -----------
 * last updated 10-12-2003 by Fabian Kloosterman */

mwl_RESULT mwl_GetFileInfo(FILE *fin, mwl_FILEINFO *pFileInfo)
{
  
  int headersize;
  char **headercontents;
  char *headerfield;
  char *fieldstring;
  /* char datestring[mwl_MAXSTRING]; */
  /*  char typestring[mwl_MAXSTRING]; */
  int fieldcount;
  long placeholder;
  struct tm timestruct;
  FieldInfo fieldinfo;
  int i;
  
  
  /* keep the current position in the file,
     so that we can set it at the end of the function */
  placeholder = ftell(fin);

  /* Rewind file */
  fseek(fin, 0L, 0L);

  /* initialize the mwl_FILENFO structure */
  pFileInfo->dwFieldCount = 0;								/* number of fields in file */
  pFileInfo->dTimeStampResolution = 1/MWLTIMESTAMPFREQ;		/* resolution of timestamps */

  /*pFileInfo->dwTime_Year = 0;								/* Date */
  /*pFileInfo->dwTime_Month = 0;								/* Date */
  /*pFileInfo->dwTime_Day = 0;								/* Date */
  /*pFileInfo->dwTime_Hour = 0;								/* Time */
  /*pFileInfo->dwTime_Min = 0;								/* Time */
  /*pFileInfo->dwTime_Sec = 0;								/* Time */
  /*pFileInfo->dwTime_MilliSec = 0;							/* Time */

  pFileInfo->pFieldInfo = NULL;	 /* FieldInfo structure array */
  pFileInfo->dwHeaderSize = 0;

  /* strncpy(pFileInfo->pFieldInfo[0].szFieldLabel, "no label", mwl_MAXSTRING-1); 
     pFileInfo->pFieldInfo[0].dwType = 0;
     pFileInfo->pFieldInfo[0].dwItemCount = 0;
     pFileInfo->pFieldInfo[0].dwID = 0;
     pFileInfo->pFieldInfo[0].dwSourceCount = 0;
     pFileInfo->pFieldInfo[0].dwLength = 0;
     pFileInfo->pFieldInfo[0].dwElementSize= 0;*/

  
  /* Read the header of the file */
  headercontents = (char **)ReadHeader(fin, &headersize);
  if (headercontents == NULL || headersize == 0) {
    fprintf(stdout, "ReadHeader: error reading the header\n");
  }
  pFileInfo->dwHeaderSize = headersize;

  /* Get -Program- header field */
  if (( headerfield = (char *)GetHeaderParameter(headercontents, "Program:") )!=NULL ) {
    strncpy(pFileInfo->szAppName, headerfield, mwl_MAXSTRING-1);
  } else {
    fprintf(stdout, "GetFileInfo: error in GetHeaderParameter:Program\n");
  }

  /* Determine File Type */

  if ( (headerfield = (char *)GetHeaderParameter(headercontents, "File Format:") ) != NULL ) {
    if (strncmp(headerfield, "event", 5)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_EVENT;
    else if (strncmp(headerfield, "eeg", 3)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_EEG;
    else if (strncmp(headerfield, "rawpos", 6)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_RAWPOS;
    else if (strncmp(headerfield, "waveform", 8)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_WAVEFORM;
    else if (strncmp(headerfield, "diode", 5)==0)
	pFileInfo->dwFileType = mwl_FILETYPE_DIODE;
    else if (strncmp(headerfield, "pxyabw", 6)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_PXYABW;
    else
      pFileInfo->dwFileType = mwl_FILETYPE_UNKNOWN;
  }
  else {

    if (strstr(pFileInfo->szAppName, "adextract")!=NULL) {   /* i.e. either event string, eeg, pos or tt file */
    
							    /* Get -Extraction type- from header */ 
      if ((headerfield = (char *)GetHeaderParameter(headercontents, "Extraction type:") )!=NULL ) {
	if (strncmp(headerfield, "event strings", 13)==0)
	  pFileInfo->dwFileType = mwl_FILETYPE_EVENT;
	else if (strncmp(headerfield, "continuous data", 15)==0)
	  pFileInfo->dwFileType = mwl_FILETYPE_EEG;
	else if (strncmp(headerfield, "extended dual", 13)==0)
	  pFileInfo->dwFileType = mwl_FILETYPE_RAWPOS;
	else if (strncmp(headerfield, "tetrode waveforms", 17)==0)
	  pFileInfo->dwFileType = mwl_FILETYPE_WAVEFORM;
	else 
	  pFileInfo->dwFileType = mwl_FILETYPE_UNKNOWN;
      } else
	pFileInfo->dwFileType = mwl_FILETYPE_UNKNOWN;
    
    } else if (strstr(pFileInfo->szAppName, "posextract")!=NULL) {
      pFileInfo->dwFileType = mwl_FILETYPE_DIODE;
    } else if (strstr(pFileInfo->szAppName, "spikeparms")!=NULL) {
      pFileInfo->dwFileType = mwl_FILETYPE_PXYABW;
    } else if (strstr(pFileInfo->szAppName, "crextract")!=NULL) {
      pFileInfo->dwFileType = mwl_FILETYPE_CR;
    } else if (strstr(pFileInfo->szAppName, "Xclust")!=NULL) {
      if ((headerfield = (char *)GetHeaderParameter(headercontents, "Cluster:") )!=NULL ) {
	/* probably a cluster file */
	pFileInfo->dwFileType = mwl_FILETYPE_CLUSTER;
      } else {
	/* probably a cluster bounds file */
	pFileInfo->dwFileType = mwl_FILETYPE_CB;
      }
    } else {
      pFileInfo->dwFileType = mwl_FILETYPE_UNKNOWN;
    }
  }

  /* Get -File type- from header */
  if ((headerfield = (char *)GetHeaderParameter(headercontents, "File type:") )!=NULL ) {
    if ((headerfield[0] == 'B')||(headerfield[0] == 'b')) {
      pFileInfo->dwIsBinary = 1;
    } else
      pFileInfo->dwIsBinary = 0;
  } else {
    fprintf(stdout, "GetFileInfo: error in GetHeaderParameter:File type.\n");
  }

  /* Get -Date- field */
  if (( headerfield = (char *)GetHeaderParameter(headercontents, "Date:") )!=NULL ) {
    strncpy(pFileInfo->szDate, headerfield, mwl_MAXSTRING-1);
    /*
    if(strptime(datestring, "%a %b %d %H:%M:%S %Y", &timestruct) != NULL) {
      pFileInfo->dwTime_Year = timestruct.tm_year;
      pFileInfo->dwTime_Month = timestruct.tm_mon;
      pFileInfo->dwTime_Day = timestruct.tm_mday;
      pFileInfo->dwTime_Hour = timestruct.tm_hour;
      pFileInfo->dwTime_Min = timestruct.tm_min;
      pFileInfo->dwTime_Sec = timestruct.tm_sec;
      }*/
  } else {
    fprintf(stdout, "GetFileInfo: error in GetHeaderParameter:Date.\n");
  }


  /* Get -Fields- from header */
  if ((fieldstring = (char *)GetFieldString(headercontents)) != NULL) {
    strncpy(pFileInfo->szFileComment, fieldstring, mwl_MAXSTRING - 1);
    if ( (fieldcount = GetFieldCount(fieldstring))!=0 )
      {
	pFileInfo->dwFieldCount = fieldcount;
	pFileInfo->pFieldInfo = (mwl_FIELDINFO *) calloc(fieldcount, sizeof(mwl_FIELDINFO));
	for (i=0; i<fieldcount; i++)
	  {
	    GetFieldInfoByNumber(fieldstring, i, &fieldinfo);
	    pFileInfo->pFieldInfo[i].dwType = fieldinfo.type;
	    pFileInfo->pFieldInfo[i].dwElementSize = fieldinfo.size;
	    pFileInfo->pFieldInfo[i].dwID = i;
	    pFileInfo->pFieldInfo[i].dwLength = fieldinfo.count;
	    pFileInfo->pFieldInfo[i].dwSourceCount = 0;
	    pFileInfo->pFieldInfo[i].dwItemCount = 0;
	    strncpy(pFileInfo->pFieldInfo[i].szFieldLabel, fieldinfo.name, mwl_MAXSTRING -1);
	  } 
      } 
    else {
      fprintf(stdout, "GetFieldCount: error in GetFieldCount:\n");
    }
  } else {
    strcpy(pFileInfo->szFileComment, "no comments");
    fprintf(stdout, "GetFileInfo: error in GetHeaderParameter:Fields.\n");
  }

  fseek(fin, placeholder, SEEK_SET);
  return mwl_OK;

}

mwl_RESULT mwl_GetInfoFromHeader(char **headercontents, int headersize, mwl_FILEINFO *pFileInfo)
{
  
  char *headerfield;
  char *fieldstring;
  /*char datestring[mwl_MAXSTRING]; */
  /*char typestring[mwl_MAXSTRING]; */
  int fieldcount;
  /*long placeholder; */
  struct tm timestruct;
  FieldInfo fieldinfo;
  int i;
  
  /* initialize the mwl_FILENFO structure */
  pFileInfo->dwFieldCount = 0;								/* number of fields in file */
  pFileInfo->dTimeStampResolution = 1/MWLTIMESTAMPFREQ;		/* resolution of timestamps */
  
  /*pFileInfo->dwTime_Year = 0;								/* Date */
  /*pFileInfo->dwTime_Month = 0;								/* Date */
  /*pFileInfo->dwTime_Day = 0;								/* Date */
  /*pFileInfo->dwTime_Hour = 0;								/* Time */
  /*pFileInfo->dwTime_Min = 0;								/* Time */
  /*pFileInfo->dwTime_Sec = 0;								/* Time */
  /*pFileInfo->dwTime_MilliSec = 0;							/* Time */

  pFileInfo->pFieldInfo = NULL;	 /* FieldInfo structure array */
  pFileInfo->dwHeaderSize = 0;
  
  
  /* Check the header of the file */
  if (headercontents == NULL || headersize == 0) {
    fprintf(stdout, "ReadHeader: error reading the header\n");
    return mwle_INPUTFILE;
  }
  
  pFileInfo->dwHeaderSize = headersize;
  
  /* Get -Program- header field */
  if (( headerfield = (char *)GetHeaderParameter(headercontents, "Program:") )!=NULL ) {
    strncpy(pFileInfo->szAppName, headerfield, mwl_MAXSTRING-1);
  } else {
    fprintf(stdout, "GetFileInfo: error in GetHeaderParameter:Program\n");
  }
  
  /* Determine File Type */
  if ( (headerfield = (char *)GetHeaderParameter(headercontents, "File Format:") ) != NULL ) {
    if (strncmp(headerfield, "event", 5)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_EVENT;
    else if (strncmp(headerfield, "eeg", 3)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_EEG;
    else if (strncmp(headerfield, "rawpos", 6)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_RAWPOS;
    else if (strncmp(headerfield, "waveform", 8)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_WAVEFORM;
    else if (strncmp(headerfield, "diode", 5)==0)
	pFileInfo->dwFileType = mwl_FILETYPE_DIODE;
    else if (strncmp(headerfield, "pxyabw", 6)==0)
      pFileInfo->dwFileType = mwl_FILETYPE_PXYABW;
    else
      pFileInfo->dwFileType = mwl_FILETYPE_UNKNOWN;
  }
  else {  
    if (strstr(pFileInfo->szAppName, "adextract")!=NULL) {   /* i.e. either event string, eeg, pos or tt file */
    
							    /* Get -Extraction type- from header */ 
      if ((headerfield = (char *)GetHeaderParameter(headercontents, "Extraction type:") )!=NULL ) {
	if (strncmp(headerfield, "event strings", 13)==0)
	  pFileInfo->dwFileType = mwl_FILETYPE_EVENT;
	else if (strncmp(headerfield, "continuous data", 15)==0)
	  pFileInfo->dwFileType = mwl_FILETYPE_EEG;
	else if (strncmp(headerfield, "extended dual", 13)==0)
	  pFileInfo->dwFileType = mwl_FILETYPE_RAWPOS;
	else if (strncmp(headerfield, "tetrode waveforms", 17)==0)
	  pFileInfo->dwFileType = mwl_FILETYPE_WAVEFORM;
	else 
	  pFileInfo->dwFileType = mwl_FILETYPE_UNKNOWN;
      } else
	pFileInfo->dwFileType = mwl_FILETYPE_UNKNOWN;
      
    } else if (strstr(pFileInfo->szAppName, "posextract")!=NULL) {
      pFileInfo->dwFileType = mwl_FILETYPE_DIODE;
    } else if (strstr(pFileInfo->szAppName, "spikeparms")!=NULL) {
      pFileInfo->dwFileType = mwl_FILETYPE_PXYABW;
    } else if (strstr(pFileInfo->szAppName, "crextract")!=NULL) {
      pFileInfo->dwFileType = mwl_FILETYPE_CR;
    } else if (strstr(pFileInfo->szAppName, "Xclust")!=NULL) {
      if ((headerfield = (char *)GetHeaderParameter(headercontents, "Cluster:") )!=NULL ) {
	/* probably a cluster file */
	pFileInfo->dwFileType = mwl_FILETYPE_CLUSTER;
      } else {
	/* probably a cluster bounds file */
	pFileInfo->dwFileType = mwl_FILETYPE_CB;
      }
    } else {
      pFileInfo->dwFileType = mwl_FILETYPE_UNKNOWN;
    }
  }

  /* Get -File type- from header */
  if ((headerfield = (char *)GetHeaderParameter(headercontents, "File type:") )!=NULL ) {
    if ((headerfield[0] == 'B')||(headerfield[0] == 'b')) {
      pFileInfo->dwIsBinary = 1;
    } else
      pFileInfo->dwIsBinary = 0;
  } else {
    fprintf(stdout, "GetFileInfo: error in GetHeaderParameter:File type.\n");
  }
  
  /* Get -Date- field */
  if (( headerfield = (char *)GetHeaderParameter(headercontents, "Date:") )!=NULL ) {
    strncpy(pFileInfo->szDate, headerfield, mwl_MAXSTRING-1);
    /*
    if(strptime(datestring, "%a %b %d %H:%M:%S %Y", &timestruct) != NULL) {
      pFileInfo->dwTime_Year = timestruct.tm_year;
      pFileInfo->dwTime_Month = timestruct.tm_mon;
      pFileInfo->dwTime_Day = timestruct.tm_mday;
      pFileInfo->dwTime_Hour = timestruct.tm_hour;
      pFileInfo->dwTime_Min = timestruct.tm_min;
      pFileInfo->dwTime_Sec = timestruct.tm_sec;
      }*/
  } else {
    fprintf(stdout, "GetFileInfo: error in GetHeaderParameter:Date.\n");
  }
  
  
  /* Get -Fields- from header */
  if ((fieldstring = (char *)GetFieldString(headercontents)) != NULL) {
    strncpy(pFileInfo->szFileComment, fieldstring, mwl_MAXSTRING - 1);
    if ( (fieldcount = GetFieldCount(fieldstring))!=0 )
      {
	pFileInfo->dwFieldCount = fieldcount;
	pFileInfo->pFieldInfo = (mwl_FIELDINFO *) calloc(fieldcount, sizeof(mwl_FIELDINFO));
	for (i=0; i<fieldcount; i++)
	  {
	    GetFieldInfoByNumber(fieldstring, i, &fieldinfo);
	    pFileInfo->pFieldInfo[i].dwType = fieldinfo.type;
	    pFileInfo->pFieldInfo[i].dwElementSize = fieldinfo.size;
	    pFileInfo->pFieldInfo[i].dwID = i;
	    pFileInfo->pFieldInfo[i].dwLength = fieldinfo.count;
	    pFileInfo->pFieldInfo[i].dwSourceCount = 0;
	    pFileInfo->pFieldInfo[i].dwItemCount = 0;
	    strncpy(pFileInfo->pFieldInfo[i].szFieldLabel, fieldinfo.name, mwl_MAXSTRING -1);
	  } 
      } 
    else {
      fprintf(stdout, "GetFieldCount: error in GetFieldCount:\n");
    }
  } else {
    strcpy(pFileInfo->szFileComment, "no comments");
    fprintf(stdout, "GetFileInfo: error in GetHeaderParameter:Fields.\n");
  }
  
  return mwl_OK;
  
}

mwl_RESULT mwl_ConvertFilterSetting(int FilterSetting, double *pLowFilter, double *pHighFilter)
{
  *pLowFilter = 0;
  *pHighFilter = 0;  

  /* First get the low cutoff */
  
  if ( (FilterSetting & (BIT0  | BIT1 | BIT2 | BIT3 | BIT4)) == 0 ){	  /* 0.1 Hz */
    *pLowFilter = 0.1;
  }
  if (FilterSetting & HDAMP_LOWCUT_1HZ){				  /* 1 HZ */
    *pLowFilter = 1;
  }
  if (FilterSetting & HDAMP_LOWCUT_10HZ){				  /* 10 Hz */
    *pLowFilter = 10;
  }
  if (FilterSetting & HDAMP_LOWCUT_100HZ){				  /* 100 Hz */
    *pLowFilter = 100;
  }
  if ((FilterSetting & HDAMP_LOWCUT_900HZ) == HDAMP_LOWCUT_300HZ){	  /* 300Hz */
    *pLowFilter = 300;
  }
  if ((FilterSetting & HDAMP_LOWCUT_900HZ) == HDAMP_LOWCUT_600HZ){	  /* 600Hz */
    *pLowFilter = 600;
  }
  if ((FilterSetting & HDAMP_LOWCUT_900HZ) == HDAMP_LOWCUT_900HZ) {	  /* 900 Hz */
    *pLowFilter = 900;
  }
  
  /* and now get the high cutoff */
  
  if ((FilterSetting & (HDAMP_HICUT_475HZ | HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_50HZ ){      /* 50 Hz */
    *pHighFilter = 50;
  }
  if ((FilterSetting & (HDAMP_HICUT_475HZ | HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_100HZ  ){    /* 100 Hz */
    *pHighFilter = 100;
  }
  if ((FilterSetting & (HDAMP_HICUT_475HZ | HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_200HZ  ){    /* 200 Hz */
    *pHighFilter = 200;
  }
  if ((FilterSetting & (HDAMP_HICUT_475HZ | HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_250HZ  ){    /* 250 Hz */
    *pHighFilter = 250;
  }
  if ((FilterSetting & (HDAMP_HICUT_475HZ | HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_275HZ  ){    /* 275 Hz */
    *pHighFilter = 275;
  }
  if ((FilterSetting & (HDAMP_HICUT_475HZ | HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_325HZ  ){    /* 325 Hz */
    *pHighFilter = 325;
  }
  if ((FilterSetting & (HDAMP_HICUT_475HZ | HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_400HZ  ){    /* 400 Hz */
    *pHighFilter = 400;
  }
  if ((FilterSetting & (HDAMP_HICUT_475HZ | HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_475HZ  ){    /* 475 Hz */
    *pHighFilter = 475;
  }
  if ((FilterSetting & HDAMP_HICUT_9KHZ) == HDAMP_HICUT_3KHZ ){                            /* 3000 Hz */
    *pHighFilter = 3000;
  }
  if ((FilterSetting & HDAMP_HICUT_9KHZ) == HDAMP_HICUT_6KHZ ){                            /* 6000 Hz */
    *pHighFilter = 6000;
  }
  if ((FilterSetting & HDAMP_HICUT_9KHZ) == HDAMP_HICUT_9KHZ ){                            /* 9000 Hz */
    *pHighFilter = 9000;
  }
  

  return mwl_OK;
}


mxArray * mwl_FileSourceStructure(FILE *InFD, const char *FUNCTIONNAME, mwl_ParamInfo *paraminfo) {

  char **headercontents = NULL;
  char *headerfield;
  int headersize;
  char TempBuffer[mwl_MAXSTRING];
  int ndim, dims[3], i, nargc;

  mxArray *infostruct;
  const char *field_names[] = {"source", "createdate", "createfunc", "user", "fields", "argc"};
  enum FieldNumber {SOURCE_F=0, DATE_F, CREATEFUNC_F,  USER_F, FIELDS_F, ARGC_F,N_FIELDS};

  if(InFD == NULL) {
    sprintf(TempBuffer, "%s: Unable to open file", FUNCTIONNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    return NULL;
  }

  fseek(InFD, 0, SEEK_SET);
  headercontents = (char **) ReadHeader(InFD, &headersize);
  if (headercontents == NULL || headersize==0) {
    sprintf(TempBuffer, "%s: Unable to retrieve file header", FUNCTIONNAME);
    mwlPrintf(TempBuffer, VBWarning, paraminfo->Verbose);
    return NULL;
  }
  
  ndim = 2; dims[0] = 1; dims[1] = 1; 
  infostruct = mxCreateStructArray(ndim, dims, N_FIELDS, field_names);

  mxSetFieldByNumber(infostruct, 0, SOURCE_F,
		     mxCreateString(FUNCTIONNAME));
  
  if ((headerfield = GetHeaderParameter(headercontents, "Program:")) !=NULL) {
    mxSetFieldByNumber(infostruct, 0, CREATEFUNC_F,
		       mxCreateString(headerfield));
  }

  if ((headerfield = GetHeaderParameter(headercontents, "Date:")) !=NULL) {
    mxSetFieldByNumber(infostruct, 0, DATE_F,
		       mxCreateString(headerfield));
  }

  if ((headerfield = GetHeaderParameter(headercontents, "User:")) !=NULL) {
    mxSetFieldByNumber(infostruct, 0, USER_F,
		       mxCreateString(headerfield));
  }

  if ((headerfield = GetHeaderParameter(headercontents, "Fields:")) !=NULL) {
    mxSetFieldByNumber(infostruct, 0, FIELDS_F,
		       mxCreateString(headerfield));
  }

  if ((headerfield = GetHeaderParameter(headercontents, "Argc:")) !=NULL) {
    mxSetFieldByNumber(infostruct, 0, ARGC_F,
		       mxCreateDoubleScalar(atof(headerfield)));
    nargc = atoi(headerfield);

     for(i=1; i < nargc; i++) {

       sprintf(TempBuffer, "Argv[%d] :", i);
       
       if ((headerfield = GetHeaderParameter(headercontents, TempBuffer)) !=NULL) {
	 sprintf(TempBuffer, "argv%d", i);
	 mxAddField(infostruct, TempBuffer);
	 mxSetFieldByNumber(infostruct, 0, N_FIELDS+i-1,
			    mxCreateString(headerfield));
      
	 /* temporary print 
	    printf("%s\n", headerfield); */
       }
     }
     
  }
  
  return infostruct;

}

/************************************************************
 *
 * $Log: mwlIOLib.c,v $
 * Revision 1.15  2004/11/21 00:20:25  fabian
 * fixed small bugs (syntax errors)
 *
 * Revision 1.14  2004/11/20 23:02:45  fabian
 * For determination of file type it is enough that Program field in header contains, rather than equals program name.
 *
 * Revision 1.13  2004/11/07 04:56:09  fabian
 * removed strptime function calls, now copied date string directly into mwl_FILEINFO field szDate
 *
 * Revision 1.12  2004/11/05 22:39:29  fabian
 * fixed error: strcmp -> strncmp
 *
 * Revision 1.11  2004/11/05 19:11:42  fabian
 * check for File Format field in header while checking file type, now also in mwl_GetInfoFromHeader function
 *
 * Revision 1.10  2004/11/05 19:02:18  fabian
 * fixed string comparison error
 *
 * Revision 1.9  2004/11/05 18:46:41  fabian
 * checked for File Format field in header when determining the file type. This field has precedence over the existing method.
 *
 * Revision 1.8  2003/11/26 02:36:58  dpnguyen
 * made updates for incorporating FTSpikeID
 * Checking to see if FTSpikeID is suppported
 *
 * Revision 1.7  2003/11/25 01:15:34  dpnguyen
 * fixed bug where Argv[x] was being read from headers within headers
 *
 * Revision 1.6  2003/11/25 00:53:42  dpnguyen
 * brought code up to date with mwl_FileSourceStructure
 *
 * Revision 1.5  2003/11/25 00:42:21  dpnguyen
 * just added mwlFileSourceStructure
 * There is still a bug in the way the Argv[n] parameters are read in
 * I suspect it is something in GetHeaderParameter
 *
 * Revision 1.4  2003/11/21 18:14:01  dpnguyen
 * updated some of the filter defines in mwlAPItypes
 * changed mwlPrintf to always print a carriage return
 * added VBDetail level messages in mwlParseFilterParams
 *
 * Revision 1.3  2003/11/21 04:17:18  dpnguyen
 * fixed up more filter parameter settings
 * and the mwlPrintf function
 * pos2mat.c is know verified to be working correctly
 *
 * Revision 1.2  2003/11/21 01:10:02  fabian
 * updated eeg2mat: now uses mwlPrintf for printing messages
 *
 * Revision 1.1  2003/11/11 06:03:06  dpnguyen
 * restarting the repository once again
 * boy, what a bunch of amateurs
 *
 *
 */
