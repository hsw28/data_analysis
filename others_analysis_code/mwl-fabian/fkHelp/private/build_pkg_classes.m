function  build_pkg_classes( rootdir, doc_path, toolbox_name, pkg_name, cls, hidden_class_methods )
%BUILD_PKG_CLASSES


up_target = [pkg_name '.html'];
up = pkg_name;

for k=1:numel(cls)
  
  if k>1
    prev = cls(k-1).Name;
    prev_target = [pkg_name '.' prev '.html'];
  else
    prev = '';
    prev_target = '';
  end
  if k<numel(cls)
    next = cls(k+1).Name;
    next_target = [pkg_name '.' next '.html'];
  else
    next = '';
    next_target = '';
  end

  
  
  body = {['<h2>Class ' pkg_name '.' cls(k).Name '</h2>']};    
  
  if ~isempty(cls(k).SuperClasses)
    tmp='<h3>super classes: ';
    for j=1:numel(cls(k).SuperClasses)
      tmp = [tmp cls(k).SuperClasses(j).Name ' '];
    end
    tmp=[tmp '</h3>'];
    body{end+1}=tmp;
  end
  
  if ~isempty(cls(k).Events)
    body{end+1}='<h3>events</h3>';
    body{end+1}='<table bgcolor="#e7ebf7" border=0 width="100%" cellpadding=0 cellspacing=0>';
    for j=1:numel(cls(k).Events)
      body{end+1}= ['<tr valign=top><td align=left>' cls(k).Events(j).Name '</td><td ' ...
                    'align=left>' cls(k).Events(j).EventDataDescription '</td></tr>'];
    end
    body{end+1}='</table>';
  end  
  
  mthd = cell( size( cls(k).Methods) );
  for j=1:numel(cls(k).Methods)
    mthd{j} = cls(k).Methods(j).Name;
  end

  mthd = setdiff( mthd, hidden_class_methods );
  
  build_methods( rootdir, doc_path, toolbox_name, pkg_name, cls(k).Name, mthd );
  
  contents = parse_contents( fullfile( rootdir, ['@' pkg_name], ['@' cls(k).Name], 'Contents.m' ) );
  
  %remove sections without any files or with hidden functions
  for j = 1:numel(contents)
    contents(j).files = setdiff( contents(j).files, hidden_class_methods );
  end
  
  contents( cellfun('length', {contents.files})==0 ) = [];  

  body{end+1} = '<h3>class methods</h3>';
  
  if isempty(contents)
    body{end+1}='<ul>';
    for m=1:numel(mthd)
      body{end+1} = ['<li><a href="' pkg_name '.' cls(k).Name '.' mthd{m} ...
                     '.html">' mthd{m} '</a></li>'];
    end
    body{end+1}='</ul>';
  else
    for m = 1:numel(contents)
      body{end+1} = ['<h4>' contents(m).name '</h4><ul>'];
      
      for n=1:numel(contents(m).files)
        body{end+1} = ['<li><a href="' pkg_name '.' cls(k).Name '.' contents(m).files{n} ...
                       '.html">' contents(m).files{n} '</a></li>'];
      end
      
      body{end+1} = '</ul>';
    end    
  end
  
  if ~isempty(cls(k).Properties)
    body{end+1}='<h3>properties</h3>';
    body{end+1}='<table bgcolor="#e7ebf7" border=0 width="100%" cellpadding=0 cellspacing=0>';
    for j=1:numel(cls(k).Properties)
      body{end+1}= ['<tr valign=top>' ...
                    '<td align=left>' cls(k).Properties(j).Name '</td>' ...
                    '<td align=left>' cls(k).Properties(j).Visible '</td>' ...
                    '<td align=left>' cls(k).Properties(j).DataType '</td>' ...
                    '<td align=left>' cls(k).Properties(j).Description '</td>' ...
                    '</tr>'];
    end
    body{end+1}='</table>';
  end
  
  %save html file
  body = help_template( 'body', body, ...
                        'title', [toolbox_name ' - ' pkg_name '.' cls(k).Name], ...
                        'label', [pkg_name '.' cls(k).Name ' class'], ...
                        'prev_label', prev, ...
                        'prev_target', prev_target, ...
                        'next_label', next, ...
                        'next_target', next_target, ...
                        'up_label', up, ...
                        'up_target', up_target);
  
  fid = fopen( fullfile( rootdir, doc_path, [pkg_name '.' cls(k).Name '.html']), 'w');
  
  fprintf(fid, '%s', body );
  
  fclose(fid);  
  
end