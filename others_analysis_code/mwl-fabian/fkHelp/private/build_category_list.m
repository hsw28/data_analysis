function [success, contents] = build_category_list( rootdir, doc_path, toolbox_name, hidden_functions )
%BUILD_CATEGORY_LIST

%parse Contents.m
contents = parse_contents( fullfile(rootdir, 'Contents.m'));

%remove sections without any files or with hidden functions
for k = 1:numel(contents)
  contents(k).files = setdiff( contents(k).files, hidden_functions );
end
  
contents( cellfun('length', {contents.files})==0 ) = [];

success=0;

if numel(contents)>1
    h1 = {'<h3>Functions -- categorical list</h3>'};
    h2 = {'<br><hr></hr>'};
    for j = 1:numel(contents)
        h1{end+1} = ['<p><a href="reference1.html#' num2str(j) '">' contents(j).name '</a></p>'];
        h2{end+1} = ['<br><h4><a name="' num2str(j) '">' contents(j).name '</a></h4>'];
        for k = 1:numel(contents(j).files)            
            h2{end+1} = ['<p><a href="' [contents(j).files{k} '.html'] '">' contents(j).files{k} '</a></p>'];
        end
        
    end

    %generate html file
    body = help_template( 'body', cat(2, h1, h2), ...
                          'title', [toolbox_name ' - categorical function list' ], ...
                          'label', toolbox_name );
    
    fid = fopen( fullfile( doc_path, 'reference1.html'), 'w');
    
    fprintf(fid, '%s', body );
    
    fclose(fid); 

    
    success = 1;
end