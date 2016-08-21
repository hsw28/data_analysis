function verbosemsg( varargin )
%VERBOSEMSG write message to screen or file
%
%  VERBOSEMSG(message) prints the message to screen or file. The level of
%  the message is 1. The message is only printed if the level is smaller
%  than or equal to the debug level.
%
%  VERBOSEMSG(id,message) adds an optional message identifier to the
%  message.
%
%  VERBOSEMSG(...,level) sets the level of the message.
%
%  Several variables affect printing of a verbose message:
%    VERBOSE - debug level, only messages with a level <= VERBOSE will be
%              printed (default = 0)
%    VERBOSE_MSG_LEVEL - if no message level is specified in the function
%                        call, then it is set to the value of this variable
%                        (default = 1)
%    VERBOSE_MSG_ID - if no message id is specified in the function call,
%                     then it is set to the value of this variable (default
%                     = '')
%    VERBOSE_SINK - vector of file IDs or cell array of file IDs or file
%                   names. Messages are printed to each file. The file IDs
%                   1 and 2 are special since they represent stdout and
%                   stderr respectively (default = 1).
%
%  These variables are searched for in the following order:
%  caller workspace, base workspace, VERBOSE group in preferences
%
%  The verbose_fmt string in the VERBOSE preference group allows
%  for customization of the message format. Special tokens in the
%  string are replaced by their values, according to the following
%  table:
%    |  token   |  replace by                     |
%    ----------------------------------------------
%    |  [msg]   |  message                        |
%    | [msgid]  |  message identifier             |
%    |[msglevel]|  message level                  |
%    | [debug]  |  debug level                    |
%    | [time]   |  time when message was printed  |
%    | [date]   |  date when message was printed  |
%  The default format is: '[msgid] :: [msg] (level [msglevel])'
%
%  Example
%    VERBOSE = 1;
%    verbosemsg( 'message' );
%    verbosemsg( 'this message won''t be printed', 2 );
%    
%    VERBOSE_MSG_ID = 'verbose';
%    verbosemsg( 'message' );
%    verbosemsg( 'my_message_id', 'message' );
%    
%    VERBOSE_MSG_LEVEL = 2;
%    verbosemsg( 'this message won''t be printed' );
%
%    clear VERBOSE_MSG_LEVEL;
%    fid = fopen( 'test.log', 'w' );
%    VERBOSE_SINK = [1 fid];
%    verbosemsg( 'message is sent to both standard out and test.log' )
%
%    setpref( 'VERBOSE', 'verbose_fmt', 'the following message: [msg], occurred at [time]' )
%    verbosemsg( 'custom formatted message' )
%    fclose(fid)
%    rmpref( 'VERBOSE', 'verbose_fmt')
%

%  Copyright 2005-2008 Fabian Kloosterman

%copy variables from caller
if evalin( 'caller', 'exist(''VERBOSE_MSG_ID'',''var'')' )
  VERBOSE_MSG_ID = evalin( 'caller', 'VERBOSE_MSG_ID' ); %#ok
end
if evalin( 'caller', 'exist(''VERBOSE'',''var'')' )
  VERBOSE = evalin( 'caller', 'VERBOSE' ); %#ok
end
if evalin( 'caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')' )
  VERBOSE_MSG_LEVEL = evalin( 'caller', 'VERBOSE_MSG_LEVEL' ); %#ok
end
if evalin( 'caller', 'exist(''VERBOSE_SINK'',''var'')' )
  VERBOSE_MSG_SINK = evalin( 'caller', 'VERBOSE_SINK' ); %#ok
end

%call generic message function
msg( 'verbose', varargin{:});



