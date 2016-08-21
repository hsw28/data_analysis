function position = dset_load_position(animal, day, epoch, varargin)
% DSET_LOAD_POSITION - loads the positions records (raw and linaear) from disk, if a linear position record doesn't exist the user is prompted to create it
stdArgs = dset_get_standard_args;
args = stdArgs.position;

linpos_filepath = dset_get_linpos_file_path(animal, day, epoch);
linpos_sl_filepath = dset_get_SL_linpos_file_path(animal, day, epoch);
pos_filepath = dset_get_pos_file_path(animal, day);

time_smoothKW = 120;

pos = load(pos_filepath);
pos = pos.pos{day}{epoch};

position.ts = pos.data(:,1); 
position.rawx = pos.data(:,2);
position.rawy = pos.data(:,3);
position.smooth_vel = pos.data(:,8);

%position.trajectory = linpos.traj{6};


%% Load my simple (SL) linearized position records
recomputeFlag = 0;
% does the file exist?
if ~exist(linpos_sl_filepath,'file')
    recomputeFlag = 1;

% is it older than this file? if so recompute
else
    fileInfo = dir(linpos_filepath);
    thisFileInfo = dir( [ mfilename('fullpath'), '.m'] );
    
    if (args.compare_dates ~= 0) && thisFileInfo.datenum > fileInfo.datenum
        recomputeFlag = 2;
        disp([mfilename, '.m is newer than ', linpos_filepath, '  recomputing!']);
    end 
end

if recomputeFlag ~= 0
    disp(linpos_filepath)
    linearize_and_save_position(linpos_sl_filepath, position.rawx, position.rawy, pos.cmperpixel, time_smoothKW);
end

%disp(['Loading data from:', linpos_filepath]);
linpos = load(linpos_sl_filepath);

position.linpos = linpos.linpos;
position.smooth_lp = linpos.smooth_lp;
position.linear_sections = linpos.sections;
position.linear_sections_idx = linpos.sectionsIdx;

%% Load the franklab standard linearized positions
linpos = load(linpos_filepath);
linpos = linpos.linpos{day}{epoch};
position.lindist = linpos.statematrix.lindist;
position.trajectory = linpos.statematrix.traj{end};
position.traj_linVel = linpos.statematrix.linearVelocity;

end

function linearize_and_save_position(file, x, y, cmperpixel, smoothKW)

    disp(file)
    [linpos, sections, sectionsIdx] = dset_linearize_position(x,y, 'cmperpixel', cmperpixel);
    %[linpos, sections, sectionsIdx] = dset_correct_linear_position(linpos, sections, sectionsIdx);
    
    %smooth the recently loaded position record
    tempLinPos = [];
    posFs = 30;
    
    for i=1:3
        idx = sectionsIdx == i;
        tempPos = linpos;
        tempPos(~idx) = nan;
    
        tempLinPos(:,i) = smoothn(tempPos, smoothKW, posFs);
    end
    smooth_lp = nanmax(tempLinPos');
    

    
    save(file, 'linpos', 'linpos', 'sections', 'sectionsIdx', 'smooth_lp');
    disp([file, ' saved!']);
    
    

end