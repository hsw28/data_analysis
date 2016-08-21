function build_classes( rootdir, doc_path, toolbox_name, class_list, hidden_class_methods)
%BUILD_CLASSES

up_target = [toolbox_name '_product_page.html'];
up = 'Toolbox page';

for k=1:numel(class_list)

  if k>1
    prev = class_list{k-1};
    prev_target = [prev '.html'];
  else
    prev = '';
    prev_target = '';
  end
  if k<numel(class_list)
    next = class_list{k+1};
    next_target = [next '.html'];
  else
    next = '';
    next_target = '';
  end
  
  class_name = class_list{k};
  
  %find base class, single inheritance only!
  base_class = '';
  base_methods = {};
  class_struct = struct( eval(class_name) );
  fn = fieldnames( class_struct );
  if isobject( class_struct.(fn{end}) )
    base_class = class_struct.(fn{end});
    base_methods = setdiff( methods(base_class), hidden_class_methods );
    base_class = class(base_class);    
  end

  
  class_methods = setdiff( methods( eval(class_name) ), hidden_class_methods);

  build_methods( rootdir, doc_path, toolbox_name, '', class_name, class_methods );
  
  contents = parse_contents( fullfile( rootdir, ['@' class_name], ...
                                       'Contents.m' ) );
  
  %remove sections without any files or with hidden functions
  for j = 1:numel(contents)
    contents(j).files = setdiff( contents(j).files, hidden_class_methods );
  end
  
  contents( cellfun('length', {contents.files})==0 ) = [];

  body = {['<h2>Class ' class_name '</h2>']};
  body{end+1} = '<h3>class methods</h3>';
  
  if isempty(contents)
    body{end+1} = '<p>none</p>';
  else
    for m = 1:numel(contents)
      body{end+1} = ['<h4>' contents(m).name '</h4><ul>'];
      
      for n=1:numel(contents(m).files)
        body{end+1} = ['<li><a href="' class_name '.' contents(m).files{n} ...
                       '.html">' contents(m).files{n} '</a></li>'];
      end
      
      body{end+1} = '</ul>';
    end
  end
  
  if ~isempty(base_class)
    
    body{end+1} = '<h3>base class</h3>';
    body{end+1} = ['<a href="' base_class '.html">' base_class '</a>'];
    body{end+1} = ['<h3>methods inherited from ' base_class '</h3>'];
    %list base class methods
    if ~isempty(base_methods)
      body{end+1} = '<ul>';
      for m=1:numel(base_methods)
        body{end+1} = ['<li><a href="' base_class '.' base_methods{m} '.html">' base_methods{m} '</a></li>'];
      end
      body{end+1} = '</ul>';
    else
      body{end+1} = '<p>none</p>';
    end
  end
  
  %save html file
  body = help_template( 'body', body, ...
                        'title', [toolbox_name ' - ' class_name], ...
                        'label', [class_name ' class'], ...
                        'prev_label', prev, ...
                        'prev_target', prev_target, ...
                        'next_label', next, ...
                        'next_target', next_target, ...
                        'up_label', up, ...
                        'up_target', up_target);
  
  fid = fopen( fullfile( rootdir, doc_path, [class_name '.html']), 'w');
  
  fprintf(fid, '%s', body );
  
  fclose(fid);
end