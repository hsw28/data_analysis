function msg( msg_type, varargin )
%MSG message helper function
%
%  MSG(msg_type,message_id,message,message_level) prints message to
%  screen and/or files. For detailed information see the help of wrapper
%  functions (i.e. verbosemsg and debugmsg)
%
%  MSG(msg_type,message,message_level) alternative syntax
%
%  See also: verbosemsg, debugmsg
%

%  Copyright 2005-2008 Fabian Kloosterman


L = lower(msg_type);
H = upper(msg_type);

%find message sinks
if evalin('caller', ['exist(''' H '_SINK'',''var'')'])
  vsink = evalin('caller', [H '_SINK']);
elseif evalin('base', ['exist(''' H '_SINK'',''var'')'])
  vsink = evalin('base', [H '_SINK']);
else
  vsink = getpref( H, [L '_sink'], 1 );
end

%open files if necessary and keep track which files have to be closed at
%the end
if isnumeric(vsink)
  vsinkclose = zeros( size(vsink) );
elseif iscell(vsink)
  tmp = vsink;
  vsink = [];
  vsinkclose = [];
  for k = 1:numel(tmp)
    if isnumeric(tmp{k})
      vsink = [vsink tmp{k}(:)'];
      vsinkclose = [vsinkclose zeros(1, numel(tmp{k}))];
    elseif ischar(tmp{k})
      fid = fopen( tmp{k}, 'a' );
      if fid>0
        vsink = [vsink fid];
        vsinkclose(end+1) = 1;
      end
    end
  end
else
  return
end

%remove invalid file identifiers
vsink( ~ismember( vsink, [1 2 fopen('all')] ) ) = [];


%no place to put our message :(
if isempty(vsink)
  return
end

%parse input arguments 
if nargin<2
  return
elseif nargin==2 && ischar(varargin{1})
  vmsgid = '';
  vmsg = varargin{1};
  vmsglevel = [];
elseif nargin==3
  if ischar(varargin{1}) && ischar(varargin{2})
    vmsgid = varargin{1};
    vmsg = varargin{2};
    vmsglevel = [];
  elseif ischar(varargin{1}) && isnumeric(varargin{2})
    vmsgid = '';
    vmsg = varargin{1};
    vmsglevel = varargin{2};
  else
    error(['fkUtilities:' L 'msg:invalidArguments'], 'Invalid arguments')
  end
elseif nargin==4
  vmsgid = varargin{1};
  vmsg = varargin{2};
  vmsglevel = varargin{3};
end


%check message, message id and message level
if ~ischar(vmsgid)
  error(['fkUtilities:' L 'msg:invalidArguments'],'Invalid message id')
end

if ~ischar(vmsg)
  error(['fkUtilities:' L 'msg:invalidArguments'],'Invalid message')
end

if ~isnumeric(vmsglevel) && ~isscalar(vmsglevel) && vmsglevel<1
  error(['fkUtilities:' L 'msg:invalidArguments'],['Invalid message ' ...
                      'level'])
end

%find message level, if none is specified
if isempty(vmsglevel)
  if evalin( 'caller', ['exist(''' H '_MSG_LEVEL'',''var'')'])
    vmsglevel = evalin('caller', [H '_MSG_LEVEL']);
  elseif evalin( 'base', ['exist(''' H '_MSG_LEVEL'',''var'')'])
    vmsglevel = evalin('base', [H '_MSG_LEVEL']);
  else
    vmsglevel = getpref( H, [L '_msg_level'], 1 );
  end
  if ~isnumeric(vmsglevel) && ~isscalar(vmsglevel) && vmsglevel<1
    vmsglevel = 1;
  end
end

%find level
if evalin( 'caller', ['exist(''' H ''',''var'')'] )
  v = evalin( 'caller', H );
elseif evalin( 'base', ['exist(''' H ''',''var'')'] )
  v = evalin( 'base', H );
else
  v = getpref(H, L, 0);
end

%if level if not valid, or the message level > level, the message will
%not be printed
if ~isnumeric(v) && ~isscalar(v)
  return
end

if vmsglevel > v
  return
end

%find message id, if none was specified
if isempty(vmsgid)
  if evalin( 'caller', ['exist(''' H '_MSG_ID'',''var'')'] )
    vmsgid = evalin( 'caller', [H '_MSG_ID'] );
  elseif evalin( 'base', ['exist(''' H '_MSG_ID'',''var'')'] )
    vmsgid = evalin( 'base', [H '_MSG_ID'] );
  else
    vmsgid = getpref( H, [L '_msg_id'], L);
  end
  if ~ischar(vmsgid)
    vmsgid = '';
  end
end

%get message format
vformat = getpref( H, [L '_fmt'], '[msgid] :: [msg] (level [msglevel])' );

if ~ischar(vformat)
  disp([H ' :: invalid ' L ' format'])
end

%replace tokens
m = regexprep(vformat, {'\[indent\]', '\[msg\]', '\[msgid\]', '\[msglevel\]', ['\[' L '\]'], '\[time\]', '\[date\]'}, ...
              {repmat('\t',1,(vmsglevel-1)), vmsg, vmsgid, num2str(vmsglevel), num2str(v), datestr(now,13), date} );


%print message to all sinks
for k=1:numel(vsink)
  
  fprintf( vsink(k), [m '\n'] );
  
  if vsinkclose(k)
    fclose( vsink(k) );
  end
  
end

