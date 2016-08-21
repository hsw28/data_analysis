function [selection,value] = track_selection(fig, headpos, varargin)
%   TRACK_SELECTION(figure, position_struct, 'ListString', str)
%   based upon listdlg.m but changed to handle the displaying of a track
%   simultaneously.   
%   
%   figure must be a figure handle
%   position_struct must be a struct with a headpos vector which is 2xN
%   'ListString' & str are the same name value pair used in listdlg
%   For further documentation consult the listdlg help file
%
%  See also LISTDLG, DIALOG, ERRORDLG, HELPDLG, INPUTDLG,
%    MSGBOX, QUESTDLG, WARNDLG.
 
error(nargchk(1,inf,nargin))

figname = '';
smode = 2;   % (multiple)
promptstring = {};
liststring = [];
listsize = [160 300];
initialvalue = [];
okstring = 'OK';
cancelstring = 'Cancel';
fus = 8;
ffs = 8;
uh = 22;

if mod(length(varargin),2) ~= 0
    % input args have not com in pairs, woe is me
    error('MATLAB:listdlg:InvalidArgument', 'Arguments to LISTDLG must come param/value in pairs.')
end
for i=1:2:length(varargin)
    switch lower(varargin{i})
     case 'name'
      figname = varargin{i+1};
     case 'promptstring'
      promptstring = varargin{i+1};
     case 'selectionmode'
      switch lower(varargin{i+1})
       case 'single'
        smode = 1;
       case 'multiple'
        smode = 2;
      end
     case 'listsize'
      listsize = varargin{i+1};
     case 'liststring'
      liststring = varargin{i+1};
     case 'initialvalue'
      initialvalue = varargin{i+1};
     case 'uh'
      uh = varargin{i+1};
     case 'fus'
      fus = varargin{i+1};
     case 'ffs'
      ffs = varargin{i+1};
     case 'okstring'
      okstring = varargin{i+1};
     case 'cancelstring'
      cancelstring = varargin{i+1};
     otherwise
      error('MATLAB:listdlg:UnknownParameter', 'Unknown parameter name passed to LISTDLG.  Name was %s', varargin{i})
    end
end

if ischar(promptstring)
    promptstring = cellstr(promptstring); 
end

if isempty(initialvalue)
    initialvalue = 1;
end

if isempty(liststring)
    error('MATLAB:listdlg:NeedParameter', 'ListString parameter is required.')
end

ex = get(0,'defaultuicontrolfontsize')*1.7;  % height extent per line of uicontrol text (approx)

fp = get(0,'defaultfigureposition');
w = 2*(fus+ffs)+listsize(1);
h = 2*ffs+6*fus+ex*length(promptstring)+listsize(2)+uh+(smode==2)*(fus+uh);
fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper left corner fixed

fig_props = { ...
    'name'                   figname ...
    'color'                  get(0,'defaultUicontrolBackgroundColor') ...
    'resize'                 'off' ...
    'numbertitle'            'off' ...
    'menubar'                'none' ...
    'windowstyle'            'modal' ...
    'visible'                'off' ...
    'createfcn'              ''    ...
    'position'               fp   ...
    'closerequestfcn'        'delete(gcbf)' ...
            };

liststring=cellstr(liststring);

 set(fig,fig_props{:});

if length(promptstring)>0
    prompt_text = uicontrol('style','text','string',promptstring,...
        'horizontalalignment','left',...
        'position',[ffs+fus fp(4)-(ffs+fus+ex*length(promptstring)) ...
        listsize(1) ex*length(promptstring)]); %#ok
end

btn_wid = (fp(3)-2*(ffs+fus)-fus)/2;

listbox = uicontrol('style','listbox',...
                    'position',[ffs+fus ffs+uh+4*fus+(smode==2)*(fus+uh) listsize],...
                    'string',liststring,...
                    'backgroundcolor','w',...
                    'max',smode,...
                    'tag','listbox',...
                    'value',initialvalue, ...
                    'callback', {@doListboxClick});

ok_btn = uicontrol('style','pushbutton',...
                   'string',okstring,...
                   'position',[ffs+fus ffs+fus btn_wid uh],...
                   'callback',{@doOK,listbox});

cancel_btn = uicontrol('style','pushbutton',...
                       'string',cancelstring,...
                       'position',[ffs+2*fus+btn_wid ffs+fus btn_wid uh],...
                       'callback',{@doCancel,listbox});

if smode == 2
    selectall_btn = uicontrol('style','pushbutton',...
                              'string','Select all',...
                              'position',[ffs+fus 4*fus+ffs+uh listsize(1) uh],...
                              'tag','selectall_btn',...
                              'callback',{@doSelectAll, listbox});

    if length(initialvalue) == length(liststring)
        set(selectall_btn,'enable','off')
    end
    set(listbox,'callback',{@doListboxClick, selectall_btn})
end

set([fig, ok_btn, cancel_btn, listbox], 'keypressfcn', {@doKeypress, listbox});

%set(fig,'position',getnicedialoglocation(fp, get(fig,'Units')));
% Make ok_btn the default button.
%setdefaultbutton(fig, ok_btn);

% make sure we are on screen
movegui(fig)
set(fig, 'visible','on'); drawnow;
set(fig, 'units', 'pixels', 'position', [300 200 600 400]);
a = axes();
plot(headpos(:,1), headpos(:,2), 'r.', 'Parent', a)
set(a, 'units', 'pixels', 'position', [200 10 380, 380]);
set(a, 'XTick', [], 'YTick', []);


try
    % Give default focus to the listbox *after* the figure is made visible
    uicontrol(listbox);
    uiwait(fig);
catch
    if ishandle(fig)
        delete(fig)
    end
end

if isappdata(0,'ListDialogAppData__')
    ad = getappdata(0,'ListDialogAppData__');
    selection = ad.selection;
    value = ad.value;
    rmappdata(0,'ListDialogAppData__')
else
    % figure was deleted
    selection = [];
    value = 0;
end

%% figure, OK and Cancel KeyPressFcn
function doKeypress(src, evd, listbox) %#ok
switch evd.Key
 case 'escape'
  doCancel([],[],listbox);
end

%% OK callback
function doOK(ok_btn, evd, listbox) %#ok
if (~isappdata(0, 'ListDialogAppData__'))
    ad.value = 1;
    ad.selection = get(listbox,'value');
    setappdata(0,'ListDialogAppData__',ad);
    delete(gcbf);
end

%% Cancel callback
function doCancel(cancel_btn, evd, listbox) %#ok
ad.value = 0;
ad.selection = [];
setappdata(0,'ListDialogAppData__',ad)
delete(gcbf);

%% SelectAll callback
function doSelectAll(selectall_btn, evd, listbox) %#ok
set(selectall_btn,'enable','off')
set(listbox,'value',1:length(get(listbox,'string')));

%% Listbox callback
function doListboxClick(listbox, evd, selectall_btn) %#ok
% if this is a doubleclick, doOK
if strcmp(get(gcbf,'SelectionType'),'open')
    doOK([],[],listbox);
elseif nargin == 3
    if length(get(listbox,'string'))==length(get(listbox,'value'))
        set(selectall_btn,'enable','off')
    else
        set(selectall_btn,'enable','on')
    end
end
