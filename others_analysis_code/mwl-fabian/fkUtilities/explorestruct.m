function hTree = explorestruct( s, varargin )
%EXPLORESTRUCT visually explore struct
%
%  h=EXPLORESTRUCT displays the current directory as a browseable tree in
%  a new figure window and returns the handle of that figure.
%
%  h=EXPLORESTRUCT(dirname) displays a tree view of the specified
%  directory
%
%  h=EXPLORESRUCT(struct) displays a tree view of the specified matlab
%  structure.
%
%  h=EXPLORESTRUCT(...,'RootLabel',label) sets string for the root label.
%


%  Copyright 2005-2008 Fabian Kloosterman


%check input arguments
if nargin<1
  s = '.';
end

%parse options
args = struct( 'RootLabel', 'root' );
args = parseArgs( varargin, args );

%create figure
hParent = figure;

%create tree
if isstruct(s) %for struct
  root = uitreenode( 's', ['<html><font color="blue"><b>' args.RootLabel '</b></font></html>'], [matlabroot,'/toolbox/matlab/icons/foldericon.gif'], false );
  hTree = uitree(hParent, 'Root', root, 'ExpandFcn', @myExpfcn); %#ok
elseif ischar(s) && exist(s, 'dir') %for directory
  s = fullpath(s);
  root = uitreenode( s, s, [], false);
  hTree = uitree(hParent, 'Root', root, 'ExpandFcn', @ExpDirFcn); %#ok
else
  error('explorestruct:invalidArgument', 'Invalid input')
end

%open root leaf
hTree.expand(root);
set(hTree, 'Units', 'normalized', 'Position', [0 0 1 1] );

%set background to white
cr = getCellRenderer( hTree.Tree );
cr.setBackgroundNonSelectionColor( java.awt.Color(1,1,1) ); 
  
  
  function nodes = ExpDirFcn(tree, value) %#ok
  %EXPDIRFCN expandfcn for directory tree
  try
    count = 0;
    ch = dir(value);
    
    for i=1:length(ch)
      if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
        count = count + 1;
        if ch(i).isdir
          iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
        else
          iconpath = [matlabroot, '/toolbox/matlab/icons/pageicon.gif'];
        end
        nodes(count) = uitreenode(fullfile(value, [ch(i).name, filesep]), ...
                                  ch(i).name, iconpath, ~ch(i).isdir); %#ok
      end
    end
  catch
    error('explorestruct:expandError', ['The uitree node type is not recognized. You may need to ', ...
           'define an ExpandFcn for the nodes.']);
  end
  
  if (count == 0)
    nodes = [];
  end
  end

  function nodes = myExpfcn(tree, value) %#ok
  %MYEXPFCN expandfcn for structs
  
  sval = eval( value );
  
  if isstruct( sval )
    fn = fieldnames(sval);
    for k=1:numel(fn)
      if isempty(sval)
        iconpath = [matlabroot,'/toolbox/matlab/icons/pageicon.gif'];
        isleaf = 1;
        label = fn{k};        
      elseif isstruct( sval(1).(fn{k}) )
        iconpath = [matlabroot,'/toolbox/matlab/icons/foldericon.gif'];
        isleaf = 0;
        label = ['<html><b>' fn{k} '</b> ' mat2str(size(sval(1).(fn{k}))) '</html>'];
      else
        iconpath = [matlabroot,'/toolbox/matlab/icons/pageicon.gif'];
        isleaf = 1;
        label = val2label( fn{k}, sval(1).(fn{k}) );
      end
      nodes(k) = uitreenode( [value '.' fn{k}], label, iconpath, isleaf); ...
          %#ok
    end
  end
  
  end

  function label = val2label( label, val )
  %VAL2LABEL convert a value to a label
  
  if isnumeric(val) || islogical(val)
    if ndims(val)<=2 && size(val,1)==1
      label = [label ' = ' mat2str( val )];
    else
      label = [label ' = ' class(val) ' ' mat2str(size(val))];
    end
  elseif iscell(val)
    label = [label ' = ' cell2str(val)];
  elseif ischar(val)
    if ndims(val)<=2 && size(val,1)==1
      label = [label ' = ' val];
    else
      label = [label ' = char ' mat2str(size(val))];
    end
  elseif isa( val, 'function_handle' )
    label = [label ' = function ' func2str( val )];
  elseif isobject(val)
    label = [label ' = object of class ' class(val)];
  end
  if numel(label)>40
    label = [label(1:37) '...'];
  end
  end

end
