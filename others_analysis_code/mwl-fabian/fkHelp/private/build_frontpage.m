function build_frontpage( rootdir, doc_path, toolbox_name, T, cat_list, ...
                          class_list, pkg_list )
%BUILD_FRONTPAGE


body = {['<h1>' toolbox_name '</h1><h3>version VERSIONNUMBER RELEASEDATE</h3><hr></hr>']};
body{end+1} = '<h2>Functions</h2>';
body{end+1} = ['<h4><a href="reference.html">In alphabetical order</a></' ...
               'h4>'];

if cat_list
  body{end+1} =  '<h4><a href="reference1.html">By category</a></h4>';
end

if numel(class_list)>0
  body{end+1} = '<hr></hr><h2>Classes</h2>';
  for k=1:numel(class_list)
    body{end+1} = ['<h4><a href="' [class_list{k} '.html'] '">' class_list{k} ...
                  '</a></h4>'];
  end
end

if numel(pkg_list)>0
  body{end+1} = '<hr></hr><h2>Packages</h2>';
  for k=1:numel(pkg_list)
    body{end+1} = ['<h4><a href="' [pkg_list{k} '.html'] '">' pkg_list{k} ...
                  '</a></h4>'];
  end
end

idx = find([T.level]==0);

if numel(idx)>0

  body{end+1} = '<hr></hr><h2>Documentation</h2>';

  for k=1:numel(idx)
  
    body{end+1} = [ '<h4><a href="' T(idx(k)).target '">' T(idx(k)).label ...
                    '</a></h4>'];            
  end
  
end

body{end+1} = '<br>';
  
body = help_template( 'body', body, ...
                      'title', [toolbox_name ' Toolbox'], ...
                      'label', [toolbox_name ' Toolbox'] );

fid = fopen( fullfile( rootdir, doc_path, [toolbox_name '_product_page.html']), 'w');

fprintf(fid, '%s', body );

fclose(fid);