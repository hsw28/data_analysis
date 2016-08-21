function build_function_list( rootdir, doc_path, toolbox_name, function_list )
%BUILD_FUNCTION_LIST

body = {'<h3>Functions -- alphabetical list</h3>'};

for k=1:numel(function_list)
  
  body{end+1} = ['<a href="' function_list{k} '.html">' function_list{k} ...
                 '</a><br>'];
end

body = help_template( 'body', body, ...
                      'title', [toolbox_name ' - alphabetical function list'], ...
                      'label', toolbox_name );

fid = fopen( fullfile( rootdir, doc_path, 'reference.html'), 'w' );

fprintf( fid, '%s', body );

fclose(fid);