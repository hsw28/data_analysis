function sources=define_sources(sources)
%DEFINE_SOURCES user defined sources
%
%  sources=DEFINE_SOURCES(sources) presents the user with a gui to enter
%  and update source definitions.
%

%  Copyright 2009 Fabian Kloosterman


%convert sources to text strings
sourcestext = local_sources2text( sources );

%create dialog box
hDlg = dialog('Visible', 'off', 'Name', 'Define sources' , 'Resize', 'on');

hSourceList = uicontrol( 'Style', 'edit', 'Min', 0, 'Max', 2, 'String', sourcestext, 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.05 0.15 0.9 0.75], 'BackgroundColor', [0.9 0.9 0.9], 'ForegroundColor', [0 0 0], 'HorizontalAlignment', 'left' );
hLabel = uicontrol('Style', 'text', 'String', 'Sources', 'HorizontalAlignment', 'center', 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.05 0.9 0.9 0.05]); %#ok
hButton = uicontrol('String', 'Done', 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.2 0.05 0.15 0.075] );
hButton(2) = uicontrol('String', 'Cancel', 'Parent', hDlg, 'Units', 'normalized', 'Position', [0.65 0.05 0.15 0.075] );

set(hButton(1), 'Callback', @local_closefcn );
set(hButton(2), 'Callback', @(hObj,eventdata) delete(hDlg) );
set(hDlg, 'CloseRequestFcn', @local_closefcn );

uiwait( hDlg );


    function local_closefcn(hObj,eventdata) %#ok
       
        try
            sources = local_text2sources( get(hSourceList,'String') );
            delete(hDlg)
        catch
            %errors, don't close
            %TODO: report errors
        end
        
        
    end


end

function src = local_text2sources( t )

    r = '\s*(?<name>\w+)\s+(?<sensor>\w+)\s*(?<description>.*)';

    matches = regexp( t, r, 'names' );
    
    if any( cellfun( 'prodofsize', matches )~=1 )
        error('local_text2sources:invalidText', 'Error parsing text')
    end
    
    matches = vertcat( matches{:} );
    
    src = struct( 'id', (1:numel(matches)), ...
                  'name', {{ matches.name }}, ...
                  'sensor', {{ matches.sensor }}, ...
                  'description', {{ matches.description }} );
    
end

function t = local_sources2text( src )

    n = numel(src.id);

    t = cell( n, 1 );

    TAB = sprintf('\t');
    
    for k=1:n
       
        t{k} = [src.name{k} TAB src.sensor{k} TAB src.description{k}];
        
    end    

end