function h=formattext(varargin)
%FORMATTEXT
%
%  h=FORMATTEXT(x,y,string)
%
%  h=FORMATTEXT(x,y,format,data)
%
%  h=FORMATTEXT(x,y,z,...)
%
%  h=FORMATTEXT(...,param1,val1,...)
%

%  Copyright 2008-2008 Fabian Kloosterman

%we need at least three input arguments
if nargin<3 || (isnumeric(varargin{3}) && nargin<4)
    error('formattext:invalidArguments', 'Incorrect number of input arguments')
end

n = 1;
x = varargin{n}; n=n+1;
y = varargin{n}; n=n+1;
if isnumeric(varargin{n})
    z = varargin{n};
    n=n+1;
else
    z = 0;
end

if ~ischar(varargin{n})
    error('formattext:invalidArguments', 'Incorrect string/format argument')
end

fmt = varargin{n}; n=n+1;

if mod(nargin-n,2)==0
    data = varargin{n}; n=n+1;
end

h=text(x,y,z,'',varargin{n:end});
h = handle(h);

p_fmt=schema.prop(h,'Format','string');

p_data=schema.prop(h,'Data','MATLAB array');
h.Data = data;

l = handle.listener(h, [p_fmt p_data], 'PropertyPostSet', @updateText);

p = schema.prop(h, 'PropertyListeners', 'handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'off';
p.Visible='off';

h.PropertyListeners = l;
p.AccessFlags.PublicSet = 'off';

h.Format = fmt;

h = double(h);

function updateText(hProp, eventdata)
h = eventdata.affectedObject;
try
    if iscell(h.Data)
        s = sprintf( h.Format, h.Data{:} );
    else
        s = sprintf( h.Format, h.Data );
    end
    h.String = s;
catch
end
