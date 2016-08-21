function build_doc( rootdir, toolbox_name, T )
%BUILD_DOC

up_target = [toolbox_name '_product_page.html'];
up = 'Toolbox page';

for k = 1:numel(T)
  
  if ~exist( fullfile(rootdir, T(k).target), 'file' )
    warning('fkHelp:build_doc:invalidFile', ['Unable to find ' ...
                        T(k).target])
    continue
  end
  
  body = textread( fullfile(rootdir, T(k).target), '%s', 'delimiter', '\n', ...
                   'whitespace', '');
  
  if k>1
    prev_label = T(k-1).label;
    prev_target = T(k-1).target;
  else
    prev_label = '';
    prev_target = '';
  end
  if k<numel(T)
    next_label = T(k+1).label;
    next_target = T(k+1).target;
  else
    next_label = '';
    next_target = '';
  end  
  
  body = help_template( 'body', body, ...
                        'title', [toolbox_name ' - ' T(k).label], ...
                        'label', T(k).label, ...
                        'prev_label', prev_label, ...
                        'prev_target', prev_target, ...
                        'next_label', next_label, ...
                        'next_target', next_target, ...
                        'up_label', up, ...
                        'up_target', up_target);
  
  fid = fopen( fullfile(rootdir, T(k).target), 'w' );
  
  if fid<0
    warning('fkHelp:build_doc:invalidFile', ['Unable to write to ' ...
                        T(k).target]);
    continue
  end
  
  fprintf( fid, '%s', body );
  
  fclose( fid );
  
end