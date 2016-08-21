function postprocess_eeg( rootdir, epoch, varargin )
%POSTPROCESS_EEG clip detection and ICA artefact removal
%
%  POSTPROCESS_EEG(rootdir,epoch) for each eeg data file found for the
%  specified epoch, clipped regions are found, ica is performed and the
%  user can inspect the components and indicate those that are artefacts.
%
%  POSTPROCESS_EEG(rootdir,epoch,parm1,val1,...) additonal options:
%   Ica - 0/1, perform ica
%   Clip - 0/1, search for clipped regions
%   Artefacts - 0/1, ask user to specify artefacts
%   Inspect - 0/1, let user inspect ica results
%   Interactive - 0/1, for each steps ask user for permission
%

VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end

if nargin<1
    help(mfilename)
    return
end

args = struct('Ica', 1, 'Clip', 1, 'Artefacts', 1, 'Inspect', 1, 'Interactive', 0);
args = parseArgs( varargin, args );


modification_date = '$Date: 2007-11-27 12:09:35 -0500 (Tue, 27 Nov 2007) $'; %#ok
revision = '$Revision: 1765 $'; %#ok
mfile_props = regexp( [modification_date revision], ['\$Date: (?<modification_date>.*) \$\$Revision: (?<revision>[0-9]+) \$'], 'names'); %#ok

%---LOG---
LOG = configobj();
LOG.status = 'incomplete';
LOG.step = 0;
LOG.description = 'postprocess eeg';
LOG.mfile.modification_date = mfile_props.modification_date;
LOG.mfile.revision = mfile_props.revision;
LOG.mfile = setcomment( LOG.mfile, ['version information for m-file: ' ...
                    mfilename] );
LOG.arguments = configobj( struct( 'rootdir', rootdir, 'epoch', epoch, ...
                                   'ica', args.Ica, 'clip', args.Clip, ...
                                   'artefacts', args.Artefacts, 'inspect',  ...
                                   args.Inspect, 'interactive', args.Interactive) );
%---------


%for each eeg file found
verbosemsg('Importing eeg...')
eeg_signals = import_eeg( rootdir, epoch );

eeg_files = unique( {eeg_signals.file} );

%filelist = dir( fullfile( rootdir, 'eeg', '*.eeg') );

n = numel(eeg_files);

%---LOG---
LF = diagnostics( fullfile(rootdir, 'epochs', epoch, [mfilename '.log']) );
%---------

try

for f=1:n
    
    %[dummy, filename, extension, dummy] = fileparts( filelist(f).name );
    
    %if a raw eeg file exist, use that
    if exist( fullfile( rootdir, 'epochs', epoch, 'eeg', [eeg_files{f} '.raw'] ), 'file' )
      filename = [eeg_files{f} '.raw'];
      raw_exist = true;
    else
      filename = eeg_files{f};
      raw_exist = false;
    end
    
    if args.Interactive
        if strcmp( questdlg(['Would you like to postprocess file ' filename '?'], 'Process file?', 'Yes', 'No', 'Yes'), 'No')
          LOG.(eeg_files{f}(1:end-4)).process = false;
          continue;
        end
    end
    
    LOG.(eeg_files{f}(1:end-4)).process = true;
    
    verbosemsg(['Loading data from ' eeg_files{f} '...']);
    
    %load eeg data
    fid = mwlopen( fullfile( rootdir, 'epochs', epoch, 'eeg', filename) );
    data = load(fid, 'all');
    
    time = data.timestamp;
    data = struct2cell( rmfield(data, 'timestamp') );
    data = double( vertcat( data{:} ) )';

    
    %clip
    if args.Interactive
        if strcmp( questdlg(['Would you like to search for clipped values in ' filename '?'], 'Clipping?', 'Yes', 'No', 'Yes'), 'No')
            args.Clip = 0;
        else
            args.Clip = 1;
        end
    end    

    if args.Clip %find regions where data is out of range (clipped)
        clipsegments = process_eeg_clip( time, data, 3 );
        LOG.(eeg_files{f}(1:end-4)).clip.nsegments = cellfun('prodofsize', clipsegments);
        tmp = apply2cell( @(q) sum(diff(q,2)), [], clipsegments );
        LOG.(eeg_files{f}(1:end-4)).clip.cliptime = [tmp{:}];
        LOG.(eeg_files{f}(1:end-4)).clip.clipfraction = [tmp{:}] ./ diff(time([1 end]));
    else %load previous clipped regions if present
        if has_props( fullfile(rootdir, 'eeg'), eeg_files{f}, 'clip' )
            clip = load_props( fullfile(rootdir, 'epochs', epoch, 'eeg'), eeg_files{f}, 'clip' );
            clipsegments = clip.segments;
        else
            clipsegments = {};
        end
    end
    
    %exclude channels which source==0
    chanexcl = [eeg_signals(find( strcmp( {eeg_signals.file}, eeg_files{f}) & [eeg_signals.source]==0 )).channel];
    if args.Interactive
        if strcmp( questdlg(['Would you like to perform ica for ' filename '?'], 'ICA?', 'Yes', 'No', 'Yes'), 'No')
            args.Ica = 0;
        else
            args.Ica = 1;
            chanexcl = inputdlg(['Please specify a list of channels to be ' ...
                                'excluded from ICA'], 'Exclude Channels', ...
                                1, mat2str( chanexcl ) );
            if ~isempty(chanexcl)
              chanexcl = str2num( chanexcl{1} ); %#ok
            end   
        end
    end    
    
    
    ica.validchan = setdiff( 1:size(data,2), chanexcl );
    
    if args.Ica        
        [ica.A,ica.W,ica.settings] = process_eeg_ica( eeg_clip( time, data(:,ica.validchan), seg_or(clipsegments{ica.validchan}), [] ));
        ica.artefacts = [];
        ica.created = datestr(now);
        LOG.(eeg_files{f}(1:end-4)).ica.validchan = ica.validchan;
        LOG.(eeg_files{f}(1:end-4)).ica.settings = configobj( ica.settings);
    else
        if has_props( fullfile(rootdir, 'epochs', epoch, 'eeg'), eeg_files{f}, 'ica' )
            ica = load_props( fullfile(rootdir, 'epochs', epoch, 'eeg'), eeg_files{f}, 'ica' );
            ica = ica.ica;
        else
            ica =struct('A', [], 'W', [], 'settings', [], 'artefacts', ...
                        [], 'created', [], 'validchan', []);
        end
    end   
    
    
    if ~isempty(ica.A) && ~isempty(ica.W)
      
      if args.Interactive
        if strcmp( questdlg(['Would you like to inspect ' filename '?'], 'Inspect?', 'Yes', 'No', 'Yes'), 'No')
          args.Inspect = 0;
        else
          args.Inspect = 1;
        end
      end   
      
      if args.Inspect
        hf = inspect_ica( time, data(:,ica.validchan), ica.A, ica.W);
        waitfor(hf);
      end
      
      
      if args.Interactive
        if strcmp( questdlg(['Would you like to define artefact components for ' filename '?'], 'Artefacts?', 'Yes', 'No', 'Yes'), 'No')
          args.Artefacts = 0;
        else
          args.Artefacts = 1;
        end
      end 
      
      if args.Artefacts
        artefacts = inputdlg('Please specify a list of artefact components', 'Artefacts');
        if ~isempty(artefacts)
          ica.artefacts = str2num( artefacts{1} ); %#ok
          LOG.(eeg_files{f}(1:end-4)).ica.artefacts = ica.artefacts;
        end
        
      end
      
    end
    
    %save eeg file properties
    props = struct('clip', struct('created', datestr(now), 'segments', { clipsegments }), 'ica', ica);
    save_props( fullfile( rootdir, 'epochs', epoch, 'eeg'), eeg_files{f}, props);
  
    
    %clip and deartefact eeg and save it
    %ica deartefact
    ica_deartefact = false;
    if ~isempty(props.ica.artefacts)
      data(:,ica.validchan) = eeg_deartefact( data(:,ica.validchan), props.ica.A, props.ica.W, props.ica.artefacts);
      ica_deartefact = true;
    end

    %clip to zero
    clipped = false;
    if ~isempty(props.clip.segments)
      if ica_deartefact
        for chan=1:numel(ica.validchan)
          data(:,ica.validchan(chan)) = eeg_clip( time, data(:,ica.validchan(chan)), seg_or(props.clip.segments{ica.validchan}), 0 );
        end
        for chan=setdiff(1:size(data,2), ica.validchan)
          data(:,chan) = eeg_clip( time, data(:,chan), props.clip.segments{chan}, 0 );
        end        
      else
        for chan=1:size(data,2)
          data(:,chan) = eeg_clip( time, data(:,chan), props.clip.segments{chan}, 0 );
        end
      end
      clipped = true;
    end  

  if clipped || ica_deartefact
    %move original file to .raw
    if ~raw_exist
      status = movefile( fullfile(rootdir, 'epochs', epoch, 'eeg',eeg_files{f}), ...
                         fullfile(rootdir, 'epochs', epoch, 'eeg', [eeg_files{f} ...
                          '.raw']) );
      if ~status
        error('Cannot move original eeg data to raw eeg file')
      end
      LOG.(eeg_files{f}(1:end-4)).save.backup = status;
    end
    
    %save new data
    flds = get( fid, 'fields' );
    hdr = get(fid, 'header');
    hdr(1) = setParam(hdr(1), 'ICA deartefact', int16(ica_deartefact));
    hdr(1) = setParam(hdr(1), 'Clipped', 1);
    hdr(1) = setParam(hdr(1), 'Clip value', 0);
    mwlcreate( fullfile(rootdir, 'epochs', epoch, 'eeg', eeg_files{f}), ...
               'feature', 'Fields', flds, 'Header', hdr, ...
               'Mode', 'overwrite', 'Data', horzcat({time}, num2cell(data, 1)) ...
               );
    LOG.(eeg_files{f}(1:end-4)).save.success = 1;
  end    
  
  
end

LOG.status = 'complete';
LF = addlog( LF, LOG );

catch
  
  e = lasterror;
  
  %---LOG---
  LOG.status = 'fail';
  LOG.ERROR = configobj( e );
  %LF = diagnostics( fullfile(rootdir, [mfilename '.log']) );
  LF = addlog( LF, setcomment(LOG, 'ABORTED', 'inline') );
  write(LF);
  %---------

  rethrow(e);  
  
end

%---LOG---
%LF = diagnostics( fullfile(rootdir, [mfilename '.log']) );
%LF = addlog( LF, LOG );
write(LF);
%---------  