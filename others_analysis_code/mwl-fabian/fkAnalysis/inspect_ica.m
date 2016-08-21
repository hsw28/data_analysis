function hf = inspect_ica( time, data, A, W )
%INSPECT_ICA


handles.time = time;
handles.data = data;
handles.A = A;
handles.W = W;

handles.ymax = max( abs( handles.data(:) ) );
        
%create matrix of axes
hf = figure();
handles.ui.panel1 = uipanel( 'Parent', hf, 'Units', 'characters', 'Position', ...
                             [0 0 100 100]);
handles.ui.panel1a = uipanel( 'Parent', handles.ui.panel1, 'Units', 'normalized', 'Position', ...
                             [0 0.1 1 0.9]);
handles.ui.panel1b = uipanel( 'Parent', handles.ui.panel1, 'Units', 'normalized', 'Position', ...
                             [0 0 1 0.05]);
handles.ui.axes = axismatrix( size(handles.data,2), 2 , 'Parent', handles.ui.panel1a, 'Argin', {'YLim', handles.ymax.*[-1 1]}, 'YSpacing', 0.01, 'Width', [4 1]);
handles.ui.slider = slider(handles.ui.panel1b, 'limits', [min(handles.time) max(handles.time)], 'windowsize', 1);
add_callback(handles.ui.slider, @updateplot)

%create control panel
handles.ui.panel2 = uipanel( 'Parent', hf, 'Units', 'characters', 'Position', [0 0 100 100]);

handles.ui.view(1) = uicontrol( 'Parent', handles.ui.panel2, 'Units', 'characters', 'Position', [1 25 28 1.5], 'Style', 'radio', 'String', 'Sources', 'Callback', @changeview, 'Value', 1);
handles.ui.sources(1) = uicontrol( 'Parent', handles.ui.panel2, 'Units', 'characters', 'Position', [4 23 35 1.5], 'Style', 'check', 'String', 'Original', 'Value', 1, 'Callback', @changesource);
handles.ui.sources(2) = uicontrol( 'Parent', handles.ui.panel2, 'Units', 'characters', 'Position', [4 19 35 1.5], 'Style', 'check', 'String', 'Reconstruction', 'Callback', @changesource);
handles.ui.reconstruct = uicontrol( 'Parent', handles.ui.panel2, 'Units', 'characters', 'Position', [4 15 35 1.5], 'Style', 'edit', 'String', '', 'Callback', @changereconstruct);

handles.ui.view(2) = uicontrol( 'Parent', handles.ui.panel2, 'Units', 'characters', 'Position', [1 12 28 1.5], 'Style', 'radio', 'String', 'Independent Components', 'Callback', @changeview);

handles.ui.ylimlabel = uicontrol( 'Parent', handles.ui.panel2, 'Units', 'characters', 'Position', [1 2 10 1.5], 'Style', 'text', 'String', 'Y lim');
handles.ui.ylim = uicontrol( 'Parent', handles.ui.panel2, 'Units', 'characters', 'Position', [12 2 10 1.5], 'Style', 'edit', 'String', num2str(handles.ymax), 'Callback', @changeymax);

setappdata( hf, 'inspect_ica', handles );

fireUpdateEvent(handles.ui.slider);
set(hf, 'ResizeFcn', {@figresize});
figresize( hf, []);


function changereconstruct(hObj, eventdata)
handles = getappdata( ancestor( hObj, 'figure' ) , 'inspect_ica' );
if get( handles.ui.sources(2), 'Value')
    fireUpdateEvent(handles.ui.slider);
end


function changesource( hObj, eventdata )

handles = getappdata( ancestor( hObj, 'figure' ) , 'inspect_ica' );
sources = get(handles.ui.sources, 'Value');
if all( [sources{:}]==0 )
    set( hObj, 'Value', 1);
elseif get(handles.ui.view(1), 'Value')
    fireUpdateEvent(handles.ui.slider);
end

function changeview( hObj, eventdata )

handles = getappdata( ancestor( hObj, 'figure' ) , 'inspect_ica' );

if strcmp( get(handles.ui.view(2), 'Enable' ), 'off' )
    set( hObj, 'Value', 1);
else
    set( setdiff( handles.ui.view, hObj), 'Value', 0 );
    fireUpdateEvent(handles.ui.slider);
end


function changeymax( hObj, eventdata)

handles = getappdata( ancestor( hObj, 'figure' ) , 'inspect_ica' );
handles.ymax = str2num( get(hObj, 'String') );
set(handles.ui.axes(:,1), 'YLim', handles.ymax.*[-1 1]);
setappdata( ancestor( hObj, 'figure' ) , 'inspect_ica', handles );


function retval = updateplot( hAx, c, sz )

handles = getappdata( ancestor( hAx, 'figure' ), 'inspect_ica' );

views = [ get( handles.ui.view, 'Value') ];

idx = find( handles.time>=(c-0.5*sz) & handles.time<=(c+0.5*sz) );

data = handles.data(idx,:);

reconstruct_ic = str2num( get(handles.ui.reconstruct, 'String' ) );
A = handles.A;
A(:, setdiff( 1:size(A,2), reconstruct_ic ) ) = 0;

if views{1} %sources
    sources = [ get( handles.ui.sources, 'Value' ) ];    
    if sources{2}
        %reconstruct
        data_reconstruct = (A*handles.W*data')';
    end
    
    %plot data
    for k=1:size(handles.ui.axes,1)
        cla( handles.ui.axes(k,1) )
        cla( handles.ui.axes(k,2) )
        
        nFFT = min(numel(idx),4096);
        
        if sources{1}
            [sp, f] = pwelch(data(:,k), hanning(nFFT), 0.5*nFFT, nFFT);
            line( f, abs(sp), 'Color', [0 0 0], 'Parent',handles.ui.axes(k,2) );
            line( handles.time(idx), data(:,k), 'Parent', handles.ui.axes(k,1), 'Color', [0 0 0] );
        end
        if sources{2}
            [sp, f] = pwelch(data_reconstruct(:,k), hanning(nFFT), 0.5*nFFT, nFFT);
            line( f, abs(sp), 'Color', [0 0 1], 'Parent',handles.ui.axes(k,2) );
            line( handles.time(idx), data_reconstruct(:,k), 'Parent', handles.ui.axes(k,1), 'Color', [0 0 1] );
        end
        
    end
    
elseif views{2} %independent components

    %separate
    data = (handles.W*data')';
    
    %plot data
    for k=1:size(data,2)
        cla( handles.ui.axes(k,1) )
        cla( handles.ui.axes(k,2) );
        
        nFFT = min(numel(idx),4096);
        
        [sp, f] = pwelch(data(:,k), hanning(nFFT), 0.5*nFFT, nFFT);
        line( f, abs(sp), 'Color', [0 0 0], 'Parent',handles.ui.axes(k,2) );
        line( handles.time(idx), data(:,k), 'Parent', handles.ui.axes(k,1), 'Color', [0 0 0] );
    end
    
end

set(handles.ui.axes(:,1), 'YDir', 'normal', 'HitTest', 'on', 'ButtonDownFcn', {@zoomaxes, handles.ui.slider} );
set(handles.ui.axes(:,2), 'YLimMode', 'auto', 'XLimMode', 'auto', 'XScale', 'linear', 'YScale', 'log', 'XLim', [0 1]);
set(handles.ui.axes(1:end-1,:), 'XTick', []);
set(handles.ui.axes(:,1), 'XLim', c + sz.*[-0.5 0.5] );

retval = true;


function zoomaxes(hObj, eventdata, hs)

if strcmp( get( gcbf, 'SelectionType' ), 'alt' ) %right button click
    
    point = get( hObj, 'CurrentPoint');
    setslider( hs, 'Center', point(1), 'WindowSize', diff( get( hObj, 'XLim' ) ).*2 );
    
else

    point1 = get( hObj, 'CurrentPoint');
    finalrect = rbbox();
    point2 = get( hObj, 'CurrentPoint');

    if diff([point1(1) point2(1)])<0.02
        setslider( hs, 'Center', point1(1) );
    else
        setslider( hs, 'Center', mean( [point1(1) point2(1)] ), 'WindowSize', abs(point1(1)-point2(1)) );
    end

end
updateslider(hs);
 

function figresize(hObj, eventdata)

handles = getappdata( hObj, 'inspect_ica');

old_units = get(hObj, 'Units');
set(hObj, 'Units', 'characters');
pos = get(hObj, 'Position');
set(hObj, 'Units', old_units);

set(handles.ui.panel2, 'Units', 'characters', 'Position', [pos(3)-40 pos(4)-30 40 30]);
set(handles.ui.panel1, 'Units', 'characters', 'Position', [0 0 max(0,pos(3)-40), pos(4)]);

