function fg = mkmov(movopt)

% % figure out how many samples to put in a frame
 nbouts = numel(movopt.boutsindex);
% samplerate = cdat.samplerate;
% samps_per_frame_pre = samplerate / movopt.framerate;
% samps_per_frame = samps_per_frame_pre * movopt.timecompression;
% 
% % figure out the up/downsampling ratio to make each data sample line up
% % with each frame (ie - sample at framerate / compression factor)
% upsample_ratio = (movopt.framerate / (samplerate * movopt.timecompression));
% 
% if(upsample_ratio > 1)
%     disp('Warning: data sample rate lower than display rate.  Upsampling...');
% end
% 
% cdat.data = unwrap(cdat.data,1);
% cdat_frames = contresamp(cdat,'resample',upsample_ratio);
fg = figure; %temp fix

if(movopt.makeavi)
    if(movopt.concatavi)
        avifilename = ['~/tmp/ripp_movie_', movopt.cdat.name, '_all_bouts'];
        avi_all = avifile(avifilename,'FPS',movopt.framerate);
        fg = figure;
    else
        %avimov = cell(nbouts);
    end
end

for i = 1:nbouts
    
    this_bout = movopt.bouts(movopt.boutsindex(i),:); % get the ith desired bout
    this_bout = this_bout + [-movopt.padding, movopt.padding];
    bout_length = diff(this_bout);
    
    bout_in_samps = subf_get_samps_from_bout_time(movopt.cdat_frames,this_bout,movopt)
    new_bout_length = (diff(bout_in_samps))/movopt.cdat.samplerate;
    % because of the floor/ceil calls in subf_get_samps...
    % the length of the bout has changed
    mov_length = new_bout_length / movopt.timecompression;
    % 0.5 speed playback means twice the movie length
    mov_framecount = ceil(mov_length/movopt.framerate);
    
    if(movopt.makeavi)
        if(not(movopt.concatavi))
            avifilename = 'movie.avi';
            aviobj = avifile(avifilename,'FPS',movopt.framerate);
            fg = figure;
            set(fg,'DoubleBuffer','on');
            set(gca,'nextplot','replace','Visible','off');
        end
    end

    % set up contopt, contdrawopt, cache (?)
    contopt = mkcontopt();
    contdrawopt = mkcontdrawopt('drawlegend',0);
    chache = [];
    
    %plot(conttimestamp(movopt.theta_frames),movopt.theta_frames.data(:,1))
    
    %for k = bout_in_samps(1):bout_in_samps(2)
    for k = 1 : size(movopt.cdat_frames.data,1)
        %disp('inside k loop');
        % generate figure to add to movie
        ktime = movopt.cdat_frames.tstart + k/movopt.cdat_frames.samplerate;
        
        if((strcmp(movopt.movtype,'theta_3d')))
            figure(fg);
            z_data = movopt.theta_frames.data(k,:);
            trode_xy = movopt.userdata.trode_xy;
            h = eeg_3d_frame(fg,z_data,trode_xy,ktime,max(max(movopt.cdat_frames.data)));
            frame = getframe(gca);
        end % end for movtype eeg_3d
        
        if((strcmp(movopt.movtype,'theta_polar')))
            %disp('Inside eeg_polar');
            figure(fg);
            trode_xy = movopt.userdata.trode_xy;
            trode_st_dp = movopt.userdata.trode_st_dp;
            h = eeg_polar_frame(fg,movopt.phase_frames, movopt.env_frames,trode_st_dp,k,ktime,this_bout);
            frame = getframe(gca);
        end
        
        if(strcmp(movopt.movtype,'theta_env'))
            figure(fg);
            trode_st_dp = movopt.userdata.trode_st_dp;
            z_data = movopt.env_frames.data(k,:);
            h = eeg_3d_frame(fg,z_data,trode_st_dp,ktime,max(max(movopt.env_frames.data)));
            frame = getframe(gca);
        end
        
        if(strcmp(movopt.movtype,'ripp_3d'))
            figure(fg);
            trode_st_dp = movopt.userdata.trode_st_dp;
            z_data = movopt.ripp_frames.data(k,:);
            h = ripp_3d_frame(fg, z_data, 1, 1, trode_st_dp, ktime, [-0.1 0.1]);
            frame = getframe(gca);
        end
            
        if(movopt.makeavi)
            if(movopt.concatavi)
%                avi_all = addframe(avi_all,fg);
            else
                aviobj = addframe(aviobj,frame);
            end
        end
        %pause(1/movopt.framerate);
    end
    
    if(movopt.makeavi)
        if(movopt.concatavi)
        else
            aviobj = close(aviobj);
        end
    end
    
end


function bout_in_samps = subf_get_samps_from_bout_time(cdat,bout,movopt)
% grabs indices from the cdat based on bout start/end times
tdif = bout(1)-movopt.cdat.tstart;
samprate = cdat.samplerate;
start_index = ceil((bout(1)-cdat.tstart)*cdat.samplerate+1);
% added 1 due to sample 1 being at t_0
end_index = floor((bout(2)-cdat.tstart)*cdat.samplerate+1);
bout_in_samps = [start_index, end_index];