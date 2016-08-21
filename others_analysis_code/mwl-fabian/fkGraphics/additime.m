function additime(h, varargin)
%ITIMEADD add time interface to ui containers and axes
%
%  ITIMEADD(h)
%

%  Copyright 2008-2008 Fabian Kloosterman

if nargin<1 || ~all(ishandle(h))
    error('itimeadd:invalidArguments', 'Need a handle')
end

if numel(h)>1
  for k=1:numel(h)
    additime(h(k));
  end
  return
end

%interface
ii = struct('properties',{{'TimeCenter','TimeSpan','TimeRange','TimeChangedFcn', 'TimeLimits', 'CurrentTime'}}, ...
    'methods', {{}});

handle_type = get(h, 'Type');

if ~any(strcmp(handle_type,{'figure','uipanel','axes'}))
    error('itime:invalidHandle', 'Need a figure, uipanel or axes handle');
end

h = handle(h);

if hasinterface(h,ii)
    return
end

%let's add properties
p(1) = schema.prop(h,'TimeCenter','double');
p(1).Description = 'Current time center';
p(1).SetFunction = @settimecenter;

p(2) = schema.prop(h,'TimeSpan','double');
p(2).Description = 'Current time span';
p(2).SetFunction = @settimespan;

p(3) = schema.prop(h,'TimeRange','MATLAB array');
p(3).Description = 'Current time range';
p(3).SetFunction = @settimerange;

p(4) = schema.prop(h,'CurrentTime', 'double');
p(4).Description = 'Current time';
p(4).SetFunction = @setcurrenttime;

p(5) = schema.prop(h,'TimeLimits','MATLAB array');
p(5).Description = 'Time limits';
p(5).SetFunction = @settimelimits;
set(h, 'TimeLimits', [-Inf Inf]);

p(6) = schema.prop(h, 'EnforceTimeLimits', 'bool');
p(6).Description = 'Enforce time limits true/false';
set(h, 'EnforceTimeLimits', false);

L = handle.listener(h, p(1:4), 'PropertyPostSet', @timechanged);
L(end+1) = handle.listener(h, p(5:6), 'PropertyPostSet', @timelimitschanged);

Lp = schema.prop(h,'TimeChangedListener','handle vector');
Lp.description = 'Time changed listener';
Lp.Visible = 'off';

h.TimeChangedListener = L;

Lp.AccessFlags.PublicSet = 'off';

p(7) = schema.prop(h,'TimeChangedFcn', 'MATLAB array');
p(7).Description = 'Time changed hook';

p(8) = schema.prop(h,'TimePropagateUp','bool');
p(9) = schema.prop(h,'TimePropagateDown','bool');

switch handle_type
    case 'axes'
        p(end+1) = schema.prop(h, 'XLimChangedFcn', 'MATLAB array');
        p(end).Description = 'XLim changed hook';
        L = handle.listener(h, h.findprop('XLim'), 'PropertyPostSet', @xlimchanged);
        Lp = schema.prop(h,'XLimChangedListener','handle vector');
        Lp.description = 'XLim changed listener';
        Lp.Visible = 'off';
        h.XLimChangedListener = L;
        Lp.AccessFlags.PublicSet = 'off';
        set(h, 'TimeChangedFcn', @propagateTime, 'XLimChangedFcn', @propagateXLim, 'TimePropagateUp',  true, ...
            'TimePropagateDown', false, 'TimeRange', get(h, 'XLim'), varargin{:} );
    otherwise
        %h.TimeChangedFcn = @propagateTimeDown;
        set(h, 'TimePropagateUp', false, 'TimePropagateDown', true, 'TimeRange', [0 1], varargin{:} );
end

function propagateTime(hObj,e)

set(hObj,'XLim',get(hObj,'TimeRange'));

function propagateXLim(hObj,e)

set(hObj,'TimeRange',get(hObj,'XLim'))


function xlimchanged(hObj,eventdata)
%call XLimChangedFcn of object
h = eventdata.affectedObject;
if ~isempty(h.XLimChangedFcn)
    process_callbacks(h.XLimChangedFcn,double(h),[]);
end

function val=setcurrenttime(h,val) %#ok

if val<h.TimeRange(1)
    val = h.TimeRange(1);
elseif val>h.TimeRange(2)
    val = h.TimeRange(2);
elseif isnan(val)
    error('setcurrenttime:invalidValue', 'Invalid value for current time')
end

function val=settimecenter(h,val) %#ok
%pass
if h.EnforceTimeLimits
    
    if (val - 0.5*h.TimeSpan) < h.TimeLimits(1)
        val = h.TimeLimits(1) + 0.5*h.TimeSpan;
    elseif (val + 0.5*h.TimeSpan) > h.TimeLimits(2)
        val = h.TimeLimits(2) - 0.5*h.TimeSpan;
    end
    
end
    
function val=settimespan(h,val) %#ok
%make sure time span is > 0
if val<=0
  val = 0.001;
end

if h.EnforceTimeLimits
    if (h.TimeCenter - 0.5*val) < h.TimeLimits(1)
        val = 2*(h.TimeCenter - h.TimeLimits(1));
    elseif (h.TimeCenter + 0.5*val) > h.TimeLimits(2)
        val = 2*(h.TimeLimits(2) - h.TimeCenter);
    end
end

function val=settimerange(h,val) %#ok

if ~isequal(size(val),[1 2]) || ~isnumeric(val) || val(2)<=val(1)
  error('settimerange:invalidRange', 'Invalid time range' )
end

val = double(val);

if h.EnforceTimeLimits

    if all( val<h.TimeLimits(1) )
        val = h.TimeLimits(1) + [0 min(diff(h.TimeLimits), diff(val))];
    elseif all( val>h.TimeLimits(2) )
        val = h.TimeLimits(2) - [min(diff(h.TimeLimits), diff(val)) 0];
    elseif val(1) < h.TimeLimits(1)
        val = val - val(1) + h.TimeLimits(1);
        val(2) = min( val(2), h.TimeLimits(2) );
    elseif val(2) > h.TimeLimits(2)
        val = val - val(2) + h.TimeLimits(2);
        val(1) = max( val(1), h.TimeLimits(1) );
    end

end


function val=settimelimits(hProp,val) %#ok

if ~isequal(size(val),[1 2]) || ~isnumeric(val) || val(2)<=val(1)
  error('settimelimits:invalidRange', 'Invalid time limits' )
end    

function timelimitschanged(hProp, eventdata)

h = eventdata.affectedObject;

if h.EnforceTimeLimits

    val = h.TimeRange;
    if all( val<h.TimeLimits(1) )
        val = h.TimeLimits(1) + [0 min(diff(h.TimeLimits), diff(val))];
    elseif all( val>h.TimeLimits(2) )
        val = h.TimeLimits(2) - [min(diff(h.TimeLimits), diff(val)) 0];
        val = val - val(1) + h.TimeLimits(1);
        val(2) = min( val(2), h.TimeLimits(2) );
    elseif val(2) > h.TimeLimits(2)
        val = val - val(2) + h.TimeLimits(2);
    end

    h.TimeRange = val;

end

function timechanged(hProp, eventdata)

h = eventdata.affectedObject;
set(h.TimeChangedListener,'Enabled','off');

switch hProp.Name
 case {'TimeCenter','TimeSpan'}
     relpos = h.CurrentTime - mean(h.TimeRange);
     h.TimeRange = [-0.5 0.5].*h.TimeSpan + h.TimeCenter;
     h.CurrentTime = mean(h.TimeRange) + relpos;
 case 'TimeRange'
     h.CurrentTime = mean(h.TimeRange) + h.CurrentTime - h.TimeCenter;
     h.TimeCenter = mean(h.TimeRange);
     h.TimeSpan = diff(h.TimeRange);
end

set(h.TimeChangedListener,'Enabled','on');

%propagate up
if h.TimePropagateUp
  p = double(h);

  while ~isempty(p)
    p = get(p,'parent');
    if isprop(handle(p),'TimeRange')
      set(p,'TimeRange',h.TimeRange, 'CurrentTime', h.CurrentTime);
      break
    end
  end
end

%propagate down
if h.TimePropagateDown
  p = findobj(h.Children,'-property','TimeRange');
  set(p,'TimeRange',h.TimeRange, 'CurrentTime', h.CurrentTime);  
end


%call TimeChangedFcn of object
if ~isempty(h.TimeChangedFcn)
    process_callbacks(h.TimeChangedFcn,double(h),[]);
end

%propagate to all descendant uipanels and axes that have property
%childObj = findobj( get( h, 'Children' ), 'Type', 'uipanel' );
%childObj = [childObj ; findobj( get( h, 'Children' ), 'Type', 'axes' )];

%for k=1:numel(childObj)
  
%  if isprop( childObj(k), hProp.Name )
%    set( childObj(k), hProp.Name, h.(hProp.Name) );
%  end
  
%end
