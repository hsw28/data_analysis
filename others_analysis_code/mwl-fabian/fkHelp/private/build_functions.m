function build_functions(rootdir, doc_path, toolbox_name, function_list)
%BUILD_FUNCTIONS

up_target = [toolbox_name '_product_page.html'];
up = 'Toolbox page';

for k=1:numel(function_list)
  
  if k>1
    prev = function_list{k-1};
    prev_target = [prev '.html'];
  else
    prev = '';
    prev_target = '';
  end
  
  if k<numel(function_list)
    next = function_list{k+1};
    next_target = [next '.html'];
  else
    next = '';
    next_target = '';
  end
  
  body = parse_help( fullfile( rootdir, [function_list{k} '.m'] ) );
  
  body = help_template( 'body', body, ...
                        'title', [toolbox_name ' - ' function_list{k}], ...
                        'label', [toolbox_name ' reference pages'], ...
                        'prev_label', prev, ...
                        'prev_target', prev_target, ...
                        'next_label', next, ...
                        'next_target', next_target, ...
                        'up_label', up, ...
                        'up_target', up_target);
  
  fid = fopen( fullfile( rootdir, doc_path, [function_list{k} '.html']), 'w');
  
  if fid<0
    warning('fkHelp:build_functions:invalidFile', ['Unable to write to ' ...
                        fullfile( rootdir, doc_path, [function_list{k}
                        '.html']) ] );
    continue
  end    
  
  fprintf( fid, '%s', body );
  
  fclose(fid);
  
end