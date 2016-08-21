function diode2p_lite(rootdir)
%PROCESS_POSITION script to process position data
%
%      process position data for each epoch (i.e. fill in missing values,
%      calculate behavioral parameters and save position for each
%      epoch).
%      
%      Based upon a similar file written by Fabian Kloosterman
%      Stuart Layton 2009

f = mwlopen(fullfile(rootdir, 'extracted_data', 'diodes.p'));
posdata = load(f);
timestamps = posdata.timestamp';
posdata = [posdata.diode1' posdata.diode2'];

if ~exist(fullfile(rootdir, 'epochs', 'epochs.def'), 'file')
    define_epochs(rootdir);
end

[epoch_names epochs] = load_epochs(rootdir);
nepochs = size(epochs,1);
    
%for each epoch do the following
epoch_corrected = 0;

disp('Correcting diode information for each epoch');
for e = 1:nepochs
    disp(['Running on epoch: ', epoch_names{e}]);
    %find position indices for epoch
    start_idx = find(timestamps>=epochs(e,1), 1);
    end_idx = find(timestamps<=epochs(e,2),1, 'last');
    data = posdata(start_idx:end_idx, :);
    ts = timestamps(start_idx:end_idx, :);

    %look for gaps in timestamps, assuming rate=30Hz
    sf=30;
    gapthreshold = 3; %in samples
    dt = diff( ts ) * sf;
    dt_idx = find( dt>gapthreshold );

    if numel(dt_idx)>0
      %insert a NaN for every gap
      data = interlace( data, NaN(1,4), dt_idx );
      ts = interlace( ts, num2cell( (ts(dt_idx) + ts(dt_idx+1))./2 ), dt_idx );

      %resample/interpolate data at 30 Hz
      warning('off','MATLAB:interp1:NaNinY')
      data = interp1( ts, data, ts(1):(1./sf):ts(end) , 'linear');
      warning('on','MATLAB:interp1:NaNinY')      
      ts = ts(1):(1./sf):ts(end);     
    end    

    disp('Filtering jumps');
    [data, stats] = filtpos_jumps(data);
    disp('Interpolating Gaps');
%    [data, stats] = filtpos_gapinterp(data, 3);
    [data(2:end-1,:), stats] = filtpos_checkdiodedist(data(2:end-1,:)); %exclude first and last sample
    disp('Interpolating HD');
%    [data, stats] = filtpos_hdinterp(data);
    %data = filtpos_checkspeed(data, 4); %doesn't work really
%    [data, stats] = filtpos_gapinterp(data, 10);    

    %if pos data starts or ends with NaNs in either diode, remove these
    first_valid = find( ~isnan( sum( data, 2) ), 1 );
    last_valid = find( ~isnan( sum( data, 2) ), 1, 'last');
    if first_valid~=1 | last_valid~=size(data,1)
      data = data(first_valid:last_valid, :);
      ts = ts(first_valid:last_valid);

      %end_idx = start_idx + last_valid-1;
      %start_idx = start_idx+first_valid-1;

      %correct epochs
      %epochs(e,:) = timestamps([start_idx end_idx])';
      epochs(e,:) = ts([1 end])';
      verbosemsg(sprintf('Corrected epoch %d: %s  %f - %f ...\n', e, epoch_names{e}, epochs(e,1), epochs(e,2)));
      epoch_corrected = 1;


    end

    ratpos = ( data(:, [1 2]) + data(:, [3 4]) ) / 2;
    %diode direction (from diode 1 -> diode 2)
    hd = atan2( -diff( data(:, [4 2]), 1, 2), diff( data(:, [3 1]), 1, 2) );

    %determine diode orientation
    dx = gradient(ratpos(:,1) );
    dy = gradient(ratpos(:,2) );
    mvdir = atan2( -dy, dx );
    speed = sqrt(dx.^2 + dy.^2);

    %{
    delta = circ_diff( mvdir, hd, 1 );

    [md, th] = diode_orient_gui( delta, speed );

    answer = input(['Specify diode orientation (default=' num2str(md) '): ']);

    if isempty(answer)
      diode_orientation = md;
    else
      diode_orientation = double(answer);
    end

    hd = hd - diode_orientation; 
    %}  
   
    flds = mwlfield({'timestamp', 'diode1', 'diode2', 'headpos', 'headdir'}, {'double', 'double', 'double', 'double', 'double'}, {1 2 2 2 1});
   
    data
    f = mwlcreate(fullfile(rootdir, 'epochs', epoch_names{e}, 'position.p'), 'feature', ...
                  'Fields', flds, ...
                  'Data', {ts(:), data(:,[1 2])', data(:,[3 4])', ratpos', hd'}, ...
                  'Mode', 'overwrite');
              %    'Header', header('Diode Orientation', diode_orientation)); %#ok
    disp([fullfile(rootdir, 'epochs', epoch_names{e}, 'position.p'), ' saved!']);
end



    if epoch_corrected
    save_epochs( rootdir, epoch_names, epochs);
    end
end
  

