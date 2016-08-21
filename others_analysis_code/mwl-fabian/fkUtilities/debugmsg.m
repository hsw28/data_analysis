function debugmsg( varargin )
%DEBUGMSG write message to screen or file
%
%  DEBUGMSG(message) prints the message to screen or file. The level of
%  the message is 1. The message is only printed if the level is smaller
%  than or equal to the debug level.
%
%  DEBUGMSG(id,message) adds an optional message identifier to the
%  message.
%
%  DEBUGMSG(...,level) sets the level of the message.
%
%  Several variables affect printing of a debug message:
%    DEBUG - debug level, only messages with a level <= DEBUG will be
%            printed (default = 0)
%    DEBUG_MSG_LEVEL - if no message level is specified in the function
%                      call, then it is set to the value of this variable
%                      (default = 1)
%    DEBUG_MSG_ID - if no message id is specified in the function call,
%                   then it is set to the value of this variable (default
%                   = '')
%    DEBUG_SINK - vector of file IDs or cell array of file IDs or file
%                 names. Messages are printed to each file. The file IDs
%                 1 and 2 are special since they represent stdout and
%                 stderr respectively (default = 1).
%
%  These variables are searched for in the following order:
%  caller workspace, base workspace, DEBUG group in preferences
%
%  The debug_fmt string in the DEBUG preference group allows
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
%    DEBUG = 1;
%    debugmsg( 'message' );
%    debugmsg( 'this message won''t be printed', 2 );
%    
%    DEBUG_MSG_ID = 'debug';
%    debugmsg( 'message' );
%    debugmsg( 'my_message_id', 'message' );
%    
%    DEBUG_MSG_LEVEL = 2;
%    debugmsg( 'this message won''t be printed' );
%
%    clear DEBUG_MSG_LEVEL;
%    fid = fopen( 'test.log', 'w' );
%    DEBUG_SINK = [1 fid];
%    debugmsg( 'message is sent to both standard out and test.log' )
%
%    setpref( 'DEBUG', 'debug_fmt', 'the following message: [msg], occurred at [time]' )
%    debugmsg( 'custom formatted message' )
%    fclose(fid)
%    rmpref( 'DEBUG', 'debug_fmt')
%

%  Copyright 2005-2008 Fabian Kloosterman

%copy variable from caller
if evalin( 'caller', 'exist(''DEBUG_MSG_ID'',''var'')' )
  DEBUG_MSG_ID = evalin( 'caller', 'DEBUG_MSG_ID' ); %#ok
end
if evalin( 'caller', 'exist(''DEBUG'',''var'')' )
  DEBUG = evalin( 'caller', 'DEBUG' ); %#ok
end
if evalin( 'caller', 'exist(''DEBUG_MSG_LEVEL'',''var'')' )
  DEBUG_MSG_LEVEL = evalin( 'caller', 'DEBUG_MSG_LEVEL' ); %#ok
end
if evalin( 'caller', 'exist(''DEBUG_SINK'',''var'')' )
  DEBUG_SINK = evalin( 'caller', 'DEBUG_SINK' ); %#ok
end

%call generic message function
msg( 'debug', varargin{:});
