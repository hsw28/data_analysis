/******************************************************************************
 
Filename: mwlIOLib.h

Function: -

Input: -

Output: -

Description: MWL Input / output header file

Author: David P. Nguyen (dpnguyen@mit.edu) and Fabian Kloosterman (fkloos@mit.edu)

$Id: mwlIOLib.h,v 1.5 2004/11/07 04:49:26 fabian Exp $

******************************************************************************/

#include <stdint.h>

char 	**ReadHeader();
int	GetFieldCount();
char	*GetHeaderParameter();
int	GetFieldInfoByNumber();
int     ParseSingleFieldDescriptor();
char    *GetFieldString();

void mwlPrintf(const char *msg, int MsgVerboseLevel, int UserRequestedLevel);

/*
** this is the magic start of header string
*/
#define MAGIC_SOH_STR "%%BEGINHEADER"
/*
** this is the magic end of header string
*/
#define MAGIC_EOH_STR "%%ENDHEADER"
/*
** this is the length of the magic start of header string %%BEGINHEADER
*/
#define MAGIC_SOH_STRSIZE	14
/*
** this is the length of the magic end of header string %%ENDHEADER
*/
#define MAGIC_EOH_STRSIZE	12

#define MAXLINE 1000

#define INVALID_TYPE	-1
#define ASCII	0
#define BINARY	1

typedef struct field_info_type {
    char	*name;	
    int		column;	
    int		type;
    int		size;
    int		count;
} FieldInfo;

#define INVALID	0
#define CHAR	1
#define SHORT	2
#define INT	3
#define FLOAT	4
#define DOUBLE	5
#define FUNC	6
#define FFUNC	7
#define ULONG	8

#ifndef TRUE
#define TRUE	1
#define FALSE	0
#endif

#define mwl_MASTERCLOCKFREQ  10000.0f
#define mwl_TRACKERCLOCKFREQ  60.0f

typedef int BOOL;
typedef int8_t   int8;
typedef uint8_t  uint8;
typedef int16_t  int16;
typedef uint16_t uint16;
typedef int32_t  int32;
typedef uint32_t uint32;

typedef	int32 mwl_RESULT;
	
/* Return values */
#define mwl_OK            0  /* OK */
#define mwle_INPUTFILE    -1  /* INPUTFILE */
#define mwle_OUTPUTFILE   -2  /* OUTPUTFILE */
#define mwle_BADINDEX     -3  /* BAD INDEX */
#define mwle_BADPARAM     -4  /* BAD INPUT PARAMETER */
#define mwle_MEMORYALLOC  -5  /* OUT OF MEMORY */


/* Flags used for locating data entries */
#define mwl_BEFORE  -1  /* less than or equal to specified time	 */
#define mwl_CLOSEST  0  /* closest time  */
#define mwl_AFTER   +1  /* greater than or equal to specified time */

/* Flags used to identify the size and type of field */
#define mwl_INVALID 0
#define mwl_CHAR    1
#define mwl_SHORT   2
#define mwl_INT     3
#define mwl_FLOAT   4
#define mwl_DOUBLE  5
#define mwl_FUNC    6
#define mwl_FFUNC   7
#define mwl_ULONG   8

#define mwl_MAXSTRING 256

#define mwl_FILETYPE_UNKNOWN  0
#define mwl_FILETYPE_EVENT    1  /* event string */
#define mwl_FILETYPE_EEG      2  /* eeg , dma buffered */
#define mwl_FILETYPE_CR       3  /* single channel eeg, dma buffered */
#define mwl_FILETYPE_RAWPOS   4  /* tracker data */
#define mwl_FILETYPE_DIODE    5  /* processed tracker data */
#define mwl_FILETYPE_PXYABW   6  /* features */
#define mwl_FILETYPE_WAVEFORM 7  /* waveform from tetrodes */
#define mwl_FILETYPE_CB       8  /* cluster bounds from xclust */
#define mwl_FILETYPE_CLUSTER  9  /* cl files from xclust */


#define	BIT0	0x0001
#define	BIT1	0x0002
#define	BIT2	0x0004
#define	BIT3	0x0008
#define	BIT4	0x0010
#define	BIT5	0x0020
#define	BIT6	0x0040
#define	BIT7	0x0080
#define	BIT8	0x0100
#define	BIT9	0x0200
#define	BIT10	0x0400
#define	BIT11	0x0800
#define	BIT12	0x1000
#define	BIT13	0x2000
#define	BIT14	0x4000
#define	BIT15	0x8000


#define HDAMP_LOWCUT_TENTHHZ	0
#define HDAMP_LOWCUT_1HZ	BIT0
#define HDAMP_LOWCUT_10HZ	BIT1
#define HDAMP_LOWCUT_100HZ	BIT2
#define HDAMP_LOWCUT_300HZ	BIT3
#define HDAMP_LOWCUT_600HZ	BIT4
#define HDAMP_LOWCUT_900HZ	(BIT3 | BIT4)

#define HDAMP_HICUT_50HZ	0
#define HDAMP_HICUT_100HZ	BIT5   /* 120 HZ ACTUALLY */
#define HDAMP_HICUT_200HZ	BIT8
#define HDAMP_HICUT_250HZ	BIT9
#define HDAMP_HICUT_275HZ	(BIT5  | BIT8)
#define HDAMP_HICUT_325HZ	(BIT5  | BIT9)
#define HDAMP_HICUT_400HZ	(BIT8 | BIT9)
#define HDAMP_HICUT_475HZ	(BIT5 | BIT8 | BIT9)
#define HDAMP_HICUT_3KHZ	BIT6
#define HDAMP_HICUT_6KHZ	BIT7
#define HDAMP_HICUT_9KHZ	(BIT6|BIT7)


/****************************************************************
 *
 * $Log: mwlIOLib.h,v $
 * Revision 1.5  2004/11/07 04:49:26  fabian
 * increased mwl_MAXSTRING constant value to 256
 *
 * Revision 1.4  2003/11/23 17:27:21  dpnguyen
 * added mwlTRACKERFREQCLOCK
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
