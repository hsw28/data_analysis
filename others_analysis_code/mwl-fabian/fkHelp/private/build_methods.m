function build_methods(rootdir, doc_path, toolbox_name, pkg_name, class_name, method_list)
%BUILD_METHODS

if isempty(pkg_name) && isempty(class_name) %function
  prefix = '';
  up_target = [toolbox_name '_product_page.html'];
  up = 'Toolbox page';
  pth = '';
  lbl = toolbox_name;
elseif isempty(pkg_name) %class method
  prefix = [class_name '.'];
  up_target = [prefix 'html'];
  up = class_name;
  pth = ['@' class_name];
  lbl = class_name;
elseif isempty(class_name) %package function
  prefix = [pkg_name '.'];
  up_target = [prefix 'html'];
  up = pkg_name;
  pth = ['@' pkg_name];
  lbl = pkg_name;
else %package class method
  prefix = [pkg_name '.' class_name '.'];
  up_target = [prefix 'html'];
  up = [pkg_name '.' class_name];
  pth = fullfile( ['@' pkg_name], ['@' class_name] );
  lbl = [pkg_name '.' class_name];
end

for k=1:numel(method_list)
  
  if k>1
    prev = method_list{k-1};
    prev_target = [prefix prev '.html'];
  else
    prev = '';
    prev_target = '';
  end
  if k<numel(method_list)
    next = method_list{k+1};
    next_target = [prefix next '.html'];
  else
    next = '';
    next_target = '';
  end
  
  body = parse_help( fullfile( rootdir, pth, [method_list{k} '.m'] ) );
  
  body = help_template( 'body', body, ...
                        'title', [toolbox_name ' - ' prefix method_list{k}], ...
                        'label', [lbl ' reference pages'], ...
                        'prev_label', prev, ...
                        'prev_target', prev_target, ...
                        'next_label', next, ...
                        'next_target', next_target, ...
                        'up_label', up, ...
                        'up_target', up_target);
  
  fid = fopen( fullfile( rootdir, doc_path, [prefix method_list{k} '.html']), 'w');
  
  if fid<0
    warning('fkHelp:build_methods:invalidFile', ['Unable to write to ' ...
                        fullfile( rootdir, doc_path, [prefix method_list{k} '.html']) ]);
    continue
  end    
  
  fprintf( fid, '%s', body );
  
  fclose(fid);
  
end  