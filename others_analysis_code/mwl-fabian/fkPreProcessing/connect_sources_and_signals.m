function [sources,signals] = connect_sources_and_signals( sources, signals )
%CONNECT_SOURCES_AND_SIGNALS helper function to associate signals with sources
%
%  [sources,signals]=CONNECT_SOURCES_AND_SIGNALS(sources,signals) presents
%  the user with a gui in which for each signal the corresponding source
%  and reference can be selected.
%

% Copyright 2009 Fabian Kloosterman


%convert sources to text strings
sourcestext = vertcat( {'NONE'}, local_sources2text( sources ) );

%convert signals to text strings
signalstext = local_signals2text( signals );

%create dialog box
hDlg = dialog('Visible', 'off', 'Name', 'Describe all sources and signals' , 'Resize', 'on');

hSignalList = uicontrol( 'Style', 'listbox', 'Min', 0, 'Max', 2, 'String', signalstext, 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.05 0.05 0.4 0.85], 'Value', [], 'BackgroundColor', [0.9 0.9 0.9], 'ForegroundColor', [0 0 0] );
hSourceList = uicontrol( 'Style', 'listbox', 'Min', 0, 'Max', 1, 'String', sourcestext, 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.5 0.05 0.2 0.85], 'Value', 1, 'BackgroundColor', [0.9 0.9 0.9], 'ForegroundColor', [0 0 0.5] );
hRefList = uicontrol( 'Style', 'listbox', 'Min', 0, 'Max', 1, 'String', sourcestext, 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.75 0.05 0.2 0.85], 'Value', 1, 'BackgroundColor', [0.9 0.9 0.9], 'ForegroundColor', [0.5 0 0] );

hLabel(1) = uicontrol('Style', 'text', 'String', 'Signal', 'HorizontalAlignment', 'center', 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.05 0.9 0.4 0.05]);
hLabel(1) = uicontrol('Style', 'text', 'String', 'Source', 'HorizontalAlignment', 'center', 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.5 0.9 0.2 0.05]);
hLabel(1) = uicontrol('Style', 'text', 'String', 'Reference', 'HorizontalAlignment', 'center', 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.75 0.9 0.2 0.05]); %#ok


set( hSignalList, 'Callback', @local_signal_callback );
set( hSourceList, 'Callback', {@local_source_callback,'source'} );
set( hRefList, 'Callback', {@local_source_callback,'refsource'} );

set(hDlg, 'Visible', 'on' );

uiwait(hDlg);

    function local_source_callback(hObj, eventdata, target ) %#ok
       
        idx = get( hObj, 'Value' );
        
        sigidx = get( hSignalList, 'Value' );
        if isempty(sigidx)
            return
        end
        
        signals.(target)(sigidx) = idx - 1;
        
    end

    function local_signal_callback(hObj, eventdata ) %#ok
       
        idx = get( hObj, 'Value' );
        
        if isempty( idx )
            srcidx = 1;
            refidx = 1;
        else
            srcidx = unique( signals.source(idx) ) + 1;
            if ~isscalar(srcidx)
                srcidx = 1;
            end
            refidx = unique( signals.refsource(idx) ) + 1;
            if ~isscalar(refidx)
                refidx = 1;
            end
        end
        
        set( hSourceList, 'Value', srcidx );
        set( hRefList, 'Value', refidx );
        
    end

end


function t = local_sources2text( src )

    n = numel(src.id);

    t = cell( n, 1 );

    for k=1:n
       
        t{k} = [src.name{k} '/' src.sensor{k}];
        
        if ~isempty( src.description{k})
            t{k} = [t{k} ' (' src.description{k} ')'];
        end
        
    end

end

function t = local_signals2text( sig )

    n = numel(sig.id);

    t = cell( n, 1 );
    
    for k=1:n
       
        t{k} = [ sig.name{k} ' (' sig.file{k} ' chan ' num2str(sig.channel(k)) ')'];

    end

end