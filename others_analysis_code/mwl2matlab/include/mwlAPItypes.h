/******************************************************************************
 
Filename: mwlAPItypes.h

Function: -

Input: -

Output: -

Description: definitions of data and info structures

Author: David P. Nguyen (dpnguyen@mit.edu) and Fabian Kloosterman (fkloos@mit.edu)

$Id: mwlAPItypes.h,v 1.16 2004/11/07 04:50:57 fabian Exp $

******************************************************************************/

/* Field Information Structure */
typedef struct
{
  char   szFieldLabel[mwl_MAXSTRING];
  uint32 dwType;
  uint32 dwElementSize;
  uint32 dwID;
  uint32 dwLength;
  uint32 dwSourceCount;
  uint32 dwItemCount; 

} mwl_FIELDINFO;

/* File information structure (the time of file creation should be reported in GMT) */
typedef struct
{
  uint32 dwFileType;             /* MWL File type */
  uint32 dwFieldCount;           /* Number of Fields in the data file. */
  mwl_FIELDINFO *pFieldInfo;      /* Field Information */
  double dTimeStampResolution;   /* Minimum timestamp resolution */
  char szAppName[mwl_MAXSTRING];          /* Name of the application that created the file */
  uint32 dwIsBinary;             /* 1 if Binary, 0 if Ascii */
  char szDate[mwl_MAXSTRING];
  
  /*uint32 dwTime_Year;            /* Year the file was created */
  /*uint32 dwTime_Month;           /* Month (0-11; January = 0) */
  /*uint32 dwTime_DayofWeek;       /* Day of the week (0-6; Sunday = 0) */
  /*uint32 dwTime_Day;             /* Day of the month (1-31) */
  /*uint32 dwTime_Hour;            /* Hour since midnight (0-23) */
  /*uint32 dwTime_Min;             /* Minute after the hour (0-59) */
  /*uint32 dwTime_Sec;             /* Seconds after the minute (0-59) */
  /*uint32 dwTime_MilliSec;		   /* Milliseconds after the second (0-1000) */
  
  char   szFileComment[mwl_MAXSTRING];	   /* Comments embedded in the source file */
  uint32 dwHeaderSize;           /* Header size in bytes */

} mwl_FILEINFO;


 
/********************************** END AD INFORMATION STRUCTURES **************************/
/********************************** START PARSE PARAMETER STUFF   **************************/

typedef struct {  
  int FilterType;      /* sec, id, or timestamp */
  int FilterParamType; /* block or vector */
  int DataFormat;      /* matlab or original */
  int RelativeFileStart;   /* relative to start of file? */
  int RelativeStartIndex;  /* relative to first index ? */
  int Verbose;            /* print information while running function */
  int ReturnType;         /* return data, or just timestamps */
} mwl_ParamInfo;

typedef struct {
  unsigned long FirstBuffer;
  unsigned long LastBuffer;
  unsigned long RecordCount;
  int FirstBufferOffset;
  int LastBufferOffset;
  char ValidBlock;
} mwl_EegBlock;

/* Define MWLTYPE Strings */
#define MWLTS_EEG             "eeg"
#define MWLTS_EVENT           "event"
#define MWLTS_FEATUREVECTOR   "featurevector"
#define MWLTS_WAVEFORM        "waveform"
#define MWLTS_TRACKER         "tracker"
#define MWLTS_DIODEPOSITION   "diodeposition"
#define MWLTS_RATPOSITION     "ratposition"
#define MWLTS_SPIKE           "spike"
#define MWLTS_CLUSTER         "cluster"

/* Filter Type Definitions */ 
#define FSNone               "none"
#define FTNone                0
#define FSTimeStamp          "timestamps"  /* filter string */
#define FTTimeStamp           1            /* filter type */
#define FSSeconds            "seconds"
#define FTSeconds             2
#define FSSpikeID            "id of spike"
#define FTSpikeID            3
#define FSRecordID           "record of index"
#define FTRecordID            4
#define FTDefault             0

/* Filter Parameter Type */
#define FPSNone                "none"
#define FPTNone                0
#define FPSBlock               "block"
#define FPTBlock               1
#define FPSArray               "array"
#define FPTArray               2
#define FPTDefault             1

/* Data Format */
#define DFSMatlabFormat       "double"
#define DFTMatlabFormat       1
#define DFSOrigFormat         "orig"
#define DFTOrigFormat         2
#define DFTDefault            1

/* Relative Start */          
#define RTNone                    0
#define RSFileStart               "|" 
#define RTFileStart               1
#define RSStartIndex               ">"
#define RTStartIndex              2
#define RTDefault                 0

/* Return type */
#define RETData                0
#define RESData                "+"
#define RETNoData              1
#define RESNoData              "-"
#define RETDefault             RETData

/* Verbose */
#define VBError                 -1
#define VSError                 "Error"
#define VBOff                   0  /* error only */
#define VSOff                   "Off"
#define VBWarning               1  /* warning + error */
#define VSWarning               "Warnings and Errors"
#define VBNormal                2  /*  warn + err + info */
#define VSNormal                "Warns, Errors, and Mesages"
#define VBDetail                3  /* warn + err + info + details */
#define VSDetail                "Everything"
#define VTPrint                 0
#define VTWarn                  1
#define VTError                 2

mwl_RESULT mwl_GetFileInfo(FILE *fin, mwl_FILEINFO *pFileInfo);
mwl_RESULT mwl_GetInfoFromHeader(char **headercontents, int headersize, mwl_FILEINFO *pFileInfo);
mwl_RESULT mwl_ConvertFilterSetting(int FilterSetting, double *pLowFilter, double *pHighFilter);
mwl_RESULT mwl_ParseFilterParamADIO(const mxArray *paramstring, const mxArray *param,  mwl_ParamInfo *paraminfo);
void mwl_ParseFilterParamUsage(void);
mxArray * mwl_FileSourceStructure(FILE *InFD, const char *FUNCTIONNAME, mwl_ParamInfo *paraminfo);
mwl_RESULT mwl_CheckFilterParamADIO(mwl_ParamInfo *paraminfo, 
				    const mxArray *InputFilterParams,
				    unsigned long StartTimeStamp,
				    unsigned long EndTimeStamp,
				    unsigned long StartSpikeIndex,
				    unsigned long EndSpikeIndex,
				    unsigned long nRecords,
				    unsigned long **FilterParamsOut,
				    int *nBlocks);

/************************************************************
 *
 * $Log: mwlAPItypes.h,v $
 * Revision 1.16  2004/11/07 04:50:57  fabian
 * replaced time fields in mwl_FILEONFO struct with szDate string field (for Windows compatibility, i.e. strptime does not exist on Windows platform)
 *
 * Revision 1.15  2004/03/17 21:18:55  dpnguyen
 * eeg2mat returns a struct array corresponding to the blocks of input
 *
 * Revision 1.14  2004/01/14 01:35:27  dpnguyen
 * updated output structures to include mwltype under each info field
 *
 * Revision 1.13  2003/12/12 03:04:56  dpnguyen
 * added ReturnType to the paraminfo structure
 *
 * Revision 1.12  2003/12/12 02:30:47  dpnguyen
 * added options (+ include data) and (- include only timestamps)
 *
 * Revision 1.11  2003/12/01 20:53:19  fabian
 * removed all unused structure definitions
 *
 * Revision 1.10  2003/11/26 02:36:58  dpnguyen
 * made updates for incorporating FTSpikeID
 * Checking to see if FTSpikeID is suppported
 *
 * Revision 1.9  2003/11/26 01:51:38  fabian
 * added record index as a filter type, changed #define FTSampleID to FTSpikeID, and updated p2mat, pos2mat, tt2mat
 *
 * Revision 1.8  2003/11/25 00:47:38  dpnguyen
 *  added the prototype for mwl_FileSourceStructure
 *
 * Revision 1.7  2003/11/25 00:33:49  fabian
 * added new filtertype: recordid ('r')
 * fix: it is not an error anymore to pass multiple blocks, but these blocks should be passed in a 2 column matrix
 *
 * Revision 1.6  2003/11/23 06:58:33  dpnguyen
 * major changes, tt2mat.c still needs some attention
 * made a new function in mwlParseFilterparams (checkFilterParams)
 * used checkFilterParams in tt2mat.c
 *
 * Revision 1.5  2003/11/21 18:14:01  dpnguyen
 * updated some of the filter defines in mwlAPItypes
 * changed mwlPrintf to always print a carriage return
 * added VBDetail level messages in mwlParseFilterParams
 *
 * Revision 1.4  2003/11/21 04:17:18  dpnguyen
 * fixed up more filter parameter settings
 * and the mwlPrintf function
 * pos2mat.c is know verified to be working correctly
 *
 * Revision 1.3  2003/11/21 01:10:02  fabian
 * updated eeg2mat: now uses mwlPrintf for printing messages
 *
 * Revision 1.2  2003/11/19 16:56:58  fabian
 * relative to start / first index options in parameter string now correctly interpreted. Added v (verbose normal) and w (verbose detailed level) to options string
 *
 * Revision 1.1  2003/11/11 06:03:06  dpnguyen
 * restarting the repository once again
 * boy, what a bunch of amateurs
 *
 *
 */
