function save_props( rootdir, target, props, merge_structs )
%SAVE_PROPS save property data
%
%  SAVE_PROPS(rootdir,target,props) saves the structure props in the file
%  rootdir/target.props.
%
%  SAVE_PROPS(rootdir,target,props,merge) if merge is 1, the function
%  will merge the structure with the data already present in an existing
%  file.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if nargin<3
    return
end

if ~isstruct(props)
    error('Invalid properties - need a structure')
end

if nargin<4 || isempty(merge_structs)
    merge_structs = 0;
end
    

filename = fullfile( rootdir, [target '.props']);


if exist(filename, 'file')
    
    if merge_structs
        %for every structure in props, check if exists (as struct) in file
        %if so, then load and make union
        propfile_contents = whos('-file', filename);
        fn = fieldnames( props );
        for k=1:numel(fn)
            [dummy, idx] = ismember( fn{k}, {propfile_contents.name} ); %#ok
            if idx>0 && strcmp(propfile_contents(idx).class, 'struct')
                p = load(filename, '-mat', fn{k} );
                props.(fn{k}) = struct_union( p.(fn{k}), props.(fn{k}));
            end
        end     
    end
    
    save(filename, '-mat', '-append', '-struct', 'props');
    
else
    
    save(filename, '-mat', '-struct', 'props');
    
end