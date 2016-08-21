function build_packages(rootdir, doc_path, toolbox_name, pkg_list, hidden_class_methods)
%BUILD_PACKAGES

up_target = [toolbox_name '_product_page.html'];
up = 'Toolbox page';

for k=1:numel(pkg_list)

  if k>1
    prev = pkg_list{k-1};
    prev_target = [prev '.html'];
  else
    prev = '';
    prev_target = '';
  end
  if k<numel(pkg_list)
    next = pkg_list{k+1};
    next_target = [next '.html'];
  else
    next = '';
    next_target = '';
  end
  
  pkg = findpackage(pkg_list{k});
  
  body = {['<h2>Package ' pkg.Name '</h2>']};
  
  fcn = cell(size(pkg.Functions));
  for j=1:numel(pkg.Functions)
    fcn{j} = pkg.Functions(j).Name;
  end
  
  build_methods( rootdir, doc_path, toolbox_name, pkg.Name, '', fcn);  
  
  contents = parse_contents( fullfile( rootdir, ['@' pkg.Name], 'Contents.m'));
  
  %remove sections without any files or with hidden functions
  for j = 1:numel(contents)
    contents(j).files = setdiff( contents(j).files, hidden_class_methods );
  end
  
  contents( cellfun('length', {contents.files})==0 ) = [];  
 
  if isempty( contents ) && ~isempty(pkg.Functions)
    body{end+1} = '<h3>functions:</h3>';
    body{end+1}='<ul>';
    for m=1:numel(pkg.Functions)
      body{end+1}=['<li><a href="' pkg.Name '.' pkg.Functions(m).Name ...
                   '.html">' pkg.Functions(m).Name '</a></li>'];
    end
    body{end+1}='</ul>';
  elseif ~isempty( contents )
    body{end+1} = '<h3>functions:</h3>';
    for m=1:numel(contents)
      body{end+1} = ['<h4>' contents(m).name '</h4><ul>'];
      for n=1:numel(contents(m).files)
        body{end+1}=['<li><a href="' pkg.Name '.' contents(m).files{n} ...
                     '.html"' contents(m).files{n} '</a></li>'];
      end
      body{end+1}='</ul>';
    end
  end
  
  cls = pkg.findclass;
  
  build_pkg_classes( rootdir, doc_path, toolbox_name, pkg.Name, cls, hidden_class_methods );
  
  if ~isempty(cls)
    body{end+1} = '<h3>classes:</h3>';
    body{end+1}='<ul>';
    for m=1:numel(cls)
      body{end+1}=['<li><a href="' pkg.Name '.' cls(m).Name ...
                   '.html">' cls(m).Name '</a></li>'];
    end
    body{end+1}='</ul>';      
  end

  
  %save html file
  body = help_template( 'body', body, ...
                        'title', [toolbox_name ' - ' pkg.Name], ...
                        'label', [pkg.Name ' package'], ...
                        'prev_label', prev, ...
                        'prev_target', prev_target, ...
                        'next_label', next, ...
                        'next_target', next_target, ...
                        'up_label', up, ...
                        'up_target', up_target);
  
  fid = fopen( fullfile( rootdir, doc_path, [pkg.Name '.html']), 'w');
  
  fprintf(fid, '%s', body );
  
  fclose(fid);  
end