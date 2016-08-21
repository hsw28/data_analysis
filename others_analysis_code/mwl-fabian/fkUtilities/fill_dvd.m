function fill_dvd( rootdir, varargin )
%FILL_DVD create dvd file lists for data backup
%
%  FILL_DVD(rootdir) constructs multiple lists of files searched in all
%  rootdir and all its subdirectories. Each list contains files that
%  together could fill a DVD.
%
%  FILL_DVD(rootdir,parm1,val1,...) specifies optional parameter/value
%  pairs. Valid parameters are:
%   fillsize - maximum dvd fill size in Gb (default=4.3)
%   mask - file selection mask
%   regexp - file selection regular expression
%   prefix - prefix for listing files (default='dvd_list_')
%   postfix - postfix for listing files (default='.txt')
%   exclude - cell array of directories to exclude. If an entry starts
%   with a file separator (i.e. / on Linux), the it's taken as relative
%   to the root directory. If an entry does not start with a file
%   separator, then it is searched for anywhere in the path.
%

%  Copyright 2005-2008 Fabian Kloosterman

GB = 1024.^3;

options = struct( 'fillsize', 4.3, 'mask', '', 'regexp', '', 'prefix', ...
                  'dvd_list_', 'postfix', '.txt', 'exclude', {{}} );

options = parseArgs(varargin,options);

options.fillsize = options.fillsize .* GB;

%start a new dvd, free = 4.4G, dvd list = {}, dvd number = 1
dvd_n = 1;
free_space = options.fillsize;
dvd_list = {};

%find all files and their relative path and filesize
dummy = dirfun( @do_fill, 'Path', rootdir, ...
                'Argin', {options.mask, options.regexp} ); %#ok

if ~isempty( dvd_list )
  save_dvd_list( fullfile(rootdir, [options.prefix num2str(dvd_n) ...
                      options.postfix]), dvd_list );
  disp(['DVD ' num2str(dvd_n) ' - space occupied (GB): ' num2str( ...
      (options.fillsize - free_space) ./ GB )]);
end

  function do_fill(p, mask, rx)

  partp = strrep( p, fullpath(rootdir), '' );
  
  for ex = 1:numel(options.exclude)
    if ~isempty(options.exclude{ex}) && isequal(options.exclude{ex}(1),filesep)
      % exclusion of /A/B... relative to rootdir
      idx = strfind( strrep( partp, filesep, ''), strrep(options.exclude{ex}, ...
                                                        filesep, '') );
      if ~isempty(idx) && idx(1)==1
        return
      end
    else
      % exclusion of .../A/B...
      if ~isempty( strfind( partp, options.exclude{ex} ) )
        return
      end
    end
  end
  
  
  files = findfiles(p, mask, rx);

  if isempty(files)
    return
  end
  
  filesizes = [files{:,2}];
  files = strrep( files(:,1), [fullpath( rootdir ) filesep], '' );
  
  done = false;
  
  while ~done
    
    sum_size = sum( filesizes );
    
    if sum_size <= free_space
      dvd_list = vertcat( dvd_list, files );
      free_space = free_space - sum_size;
      done = true;
    elseif all( filesizes > free_space )
      save_dvd_list( fullfile(rootdir, [options.prefix num2str(dvd_n) ...
                          options.postfix]), dvd_list );
      
      disp(['DVD ' num2str(dvd_n) ' - space occupied (GB): ' num2str( ...
          (options.fillsize - free_space) ./ GB )]);
      dvd_list = {};
      dvd_n = dvd_n + 1;
      free_space = options.fillsize;
      done = true;
    else
      idx = binpack( filesizes, free_space );
      %dvd_list = add_files( dvd_list, folders{k}, files(idx) );
      dvd_list = vertcat( dvd_list, files(idx) );
      free_space = free_space - sum( filesizes(idx) );
      save_dvd_list( fullfile(rootdir, [options.prefix num2str(dvd_n) ...
                          options.postfix]), dvd_list );
      
      disp(['DVD ' num2str(dvd_n) ' - space occupied (GB): ' num2str( ...
          (options.fillsize - free_space) ./ GB )]);    
      dvd_list = {};
      dvd_n = dvd_n + 1;
      free_space = options.fillsize;
      files = files( setdiff( 1:length(files), idx ) );
      filesizes = filesizes( setdiff( 1:length(filesizes), idx ) );
    end
  end
  
  end

end

function save_dvd_list( filename, dvd_list )

fid = fopen( filename, 'w' );

for j=1:length(dvd_list)
  target = [dvd_list{j} '=' dvd_list{j}];
  disp( target );
  fprintf( fid, '%s\n', target ); 
end

fclose(fid);

disp(['Saved to ' filename ])
disp('')

end

function f = findfiles( p, mask, rx )

if ~isempty(mask)
  f = dir( fullfile(p, mask) );
else
  f = dir( p );
end

valid = ~[f.isdir];

if ~isempty( rx )
  r = regexp( {f.name}, rx );
  valid = valid(:) & ~cellfun( 'isempty', r(:) );
end

valid = find(valid);

if numel(valid )>0
  
  f = horzcat( strcat( p, filesep, {f(valid).name}' ), num2cell( ...
      vertcat(f(valid).bytes) ) );
  
else
  
  f = cell(0,2);
  
end

end