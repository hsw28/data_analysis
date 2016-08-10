function makeadio(target)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION PROTOTYPE: makeadio(target)
% 
% INPUT: the name of the function to compile
%
% OUTPUT: the .mexglx file
%
% DESCRIPTION: Makefile for mex functions
%
% AUTHOR: David Nguyen <dpnguyen@mit.edu>, Fabian Kloosterman <fkloos@mit.edu>
%
% $Id: makesources.m,v 1.2 2004/11/07 02:59:02 fabian Exp $ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('target') ~= 1
  target = 'all';
else  
  if strncmp(class(target), 'char', 4) ~= 1
    error('makeadio: Target must be a string!');
    return;
  end
end

target = lower(target)
  
if (strcmp(target, 'p2mat') | strcmp(target, 'all'))
  mex -Iinclude src/p2mat.c src/mwlIOLib.c src/mwlParseFilterParams.c
end

if (strcmp(target, 'pos2mat') | strcmp(target, 'all'))
  mex -Iinclude src/pos2mat.c src/mwlIOLib.c src/mwlParseFilterParams.c
end

if (strcmp(target, 'tt2mat') | strcmp(target, 'all'))
  mex -Iinclude src/tt2mat.c src/mwlIOLib.c src/mwlParseFilterParams.c
end

if  (strcmp(target, 'eeg2mat') | strcmp(target, 'all'))
  mex -Iinclude src/eeg2mat.c src/mwlIOLib.c src/mwlParseFilterParams.c
end

if  (strcmp(target, 'fv2mat') | strcmp(target, 'all'))
  mex -Iinclude src/fv2mat.c src/mwlIOLib.c src/mwlParseFilterParams.c
end

if  (strcmp(target, 'event2mat') | strcmp(target, 'all'))
  mex -Iinclude src/event2mat.c src/mwlIOLib.c src/mwlParseFilterParams.c
end
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% $Log: makesources.m,v $
%% Revision 1.2  2004/11/07 02:59:02  fabian
%% changed short circuit logical operator (||) to normal or operator (|) so that it will work with older matlab versions
%%
%% Revision 1.1  2004/11/02 01:55:55  fabian
%% renamed makeadio.m to makesources.m
%%
%% Revision 1.11  2004/11/01 20:02:39  fabian
%% Created new cvs repository and reorganized and copied old adio3 repository to new repository. Created include, src and doc folders in repository for *.h, *.c and documentation respectively. Updated makeadio.m to compile the source from the src folder into mex files.
%%
%% Revision 1.10  2004/03/18 02:41:12  dpnguyen
%% included entry for pos2mat
%%
%% Revision 1.9  2004/02/26 02:48:50  dpnguyen
%% misc changes
%%
%% Revision 1.8  2004/01/06 01:48:15  dpnguyen
%% working on position processing routines
%% updated diodeconfig.c & posest.c to work with
%% new output of pos2mat.c
%%
%% Revision 1.7  2003/12/10 18:28:53  fabian
%% changed step 4 in the instructions in Readme.txt: change to MWLTools/adio directory
%% in makeadio.m commented out lines that compile posest.c and diodeconfig.c
%% cl2mat will now display usage string if no input arguments are supplied
%%
%% Revision 1.6  2003/12/09 21:42:28  dpnguyen
%% added documentation of mex files using .m interfaces
%%
%% Revision 1.5  2003/11/23 06:58:33  dpnguyen
%% major changes, tt2mat.c still needs some attention
%% made a new function in mwlParseFilterparams (checkFilterParams)
%% used checkFilterParams in tt2mat.c
%%
%% Revision 1.4  2003/11/21 20:51:48  dpnguyen
%% fixed some print statments
%%
%% Revision 1.3  2003/11/21 04:17:18  dpnguyen
%% fixed up more filter parameter settings
%% and the mwlPrintf function
%% pos2mat.c is know verified to be working correctly
%%
%% Revision 1.2  2003/11/11 16:00:49  dpnguyen
%% added plotpos to see output of posextract.m
%%
%% Revision 1.1  2003/11/11 15:48:34  dpnguyen
%% added makefile for mex functions
%%
%%
