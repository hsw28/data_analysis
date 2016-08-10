function gains = getgains(varargin)
% GETGAINS get amp gains from a directory full of tt files
%
% $Id$
%
% 'datadir' = path to directory containing tetrode directories
%
% 'tetdirregexp' = the regexp to use to find tetrode directories. 
%    E.g. to find 't01', 't02', etc, use: '^t\d{2}$' 
%         to find 'a103', 'e203', use:  '^[a-i][12]\d{2}$'
%    Use '[]', (with the single-quotes), to select no tetrodes.

  defaults = struct( ...
      'datadir', [],...
      'tetdirregexp', '^[a-i][12]\d{2}$');
  
  args = parseArgs(varargin, defaults);
  
  % datadir defaults to current directory
  if isempty(args.datadir),
    datadir = pwd;
    disp(sprintf('\n'));
    disp(['No ''datadir'' provided, using current directory:' pwd]);
    disp(sprintf('\n'));
  else
    datadir = args.datadir;
  end

  % Find all directories in datadir
  dlist = dir(datadir);
  dlist = dlist(find([dlist.isdir]));
  
  %iterate over all directories
  tetidx = 0;
  for tetdname = {dlist.name}
    tetdname = cell2mat(tetdname);
    
    % Only process tetrode directories.
    if regexp(tetdname, args.tetdirregexp),
      
      tetidx = tetidx + 1;
      
      tetdir = [datadir '/' tetdname];
      
      % Look for .tt file or headerfile
      ttfile = dir([tetdir '/*.tt']);
      headerfile = dir([tetdir '/*.header']);
      switch size(ttfile,1)
       case 1
        if isempty(headerfile),
          unix (['header ' tetdir '/' ttfile.name ' > ' tetdir '/' ttfile.name '.header']);
          headerfile = dir([tetdir '/*.header']);
        end
       case 0,
        if isempty(headerfile),
          warning (['No ttfile or header file found in directory ' tetdir]);
        end
       otherwise,
        error (['More than one ttfile found in directory ' tetdir]);
      end
      headerfile = [tetdir '/' headerfile.name];
      
      ad{tetidx}  = import_adinfo(headerfile);
      
      adhdr = ad{tetidx};
      if isempty(adhdr) || (isstruct(adhdr) && isempty(fieldnames(adhdr))),
        error('AD header not found in tt file or header');
      else
        rate(tetidx) = adhdr.rate;
        
        % get electrode gain/check that they are equal across all electrode channels
        fldmatch = regexp(fieldnames(adhdr)', 'chan\d+ampgain','match','once');
        tetgain = [];
        for fld = fldmatch,
          if ~isempty(fld{1}),
            tetgain = [tetgain adhdr.(fld{1})];
          end
        end
        if any(diff(tetgain))
          warnstr = (' <- not equal');
        else
          warnstr = '';
        end
        % use max so that reported value represents an upper bound
        % (reasonable for thresholding)
        gains(tetidx) = max(tetgain(:));
        
        disp(sprintf('gains for %s: %6.0f %6.0f %6.0f %6.0f %s', ...
                     tetdname, tetgain, warnstr));
        
      end
      
    end
    
  end