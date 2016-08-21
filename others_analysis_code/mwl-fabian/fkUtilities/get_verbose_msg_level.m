function l = get_verbose_msg_level()
%GET_VERBOSE_LEVEL helper function to get verbose level
%
%  l=GET_VERBOSE_LEVEL()
%

%  Copyright 2009 Fabian Kloosterman

if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  l = evalin('caller', 'VERBOSE_MSG_LEVEL')+1; %#ok
else
  l = 1; %#ok
end