function rate = swwBarOne(md,areaInd,sessionInd,draw,doClean)

    area=md.areas{areaInd};
    session=md.sessions{sessionInd};

    dPath = [md.mdata.basePath,'/d',num2str(md.twin(1)),'_',...
        num2str(md.twin(2)),'.mat'];
    
    rPath = [md.mdata.basePath,'/d',num2str(md.twin(1)),'_',...
        num2str(md.twin(2)),area,session,'.mat']
    if(exist(rPath) && doClean < 1)
        load(rPath);
    else
        if(exist(dPath) && doClean < 2)
            load(dPath);
        else
            disp(rPath);
            m = md.mdata;
            m.loadTimewin = md.twin;
            doPos = strContains(session,'run') || ...
                strContains(session,'pause');
            d = loadData(m,'segment_style','areas','loadPos',doPos,...
                'loadSpikes',doPos,'samplerate',800,'loadMUA',false);
            [~,~,r] = gh_ripple_filt(d.eeg,'F',[100,150,200,300]);
            save(dPath,'d','r');
        end 
        d.trode_groups = md.mdata.trode_groups_fn('date',md.mdata.today,'segment_style','areas');
        

        % Get the timewins
        if(any(strcmp(session,{'sleep','drowsy'}))) % These need no windowing
            timewins = {md.twin};
        elseif any(strcmp(session,{'run','normalPause','nightPause'}))
            runTimewins = ...
                gh_union_segs( timeArrayToSegments(d.pos_info.out_run_bouts),...
                                timeArrayToSegments(d.pos_info.in_run_bouts));
                pauseTimewins = gh_subtract_segs({md.twin},runTimewins);
            if(strcmp(session,'run'))
                timewins = runTimewins;
            else
                timewins = pauseTimewins;
            end
        else
            error('swwBarChart:unknown_ession',...
                ['Unknown session type: ',session]);
        end
            
        % Get the events
        if strcmp(area,'CA1')
            % eegRipples(rippleEnv, minPeak, baseCutoff, minLength, bridgeWidth, adequate_local_min, min_peak_dist)
            hpcEnv = contchans_trode_group(r,d.trode_groups,'CA1');
            hpcEnv = contmap(@(x) mean(x,2),hpcEnv);
            %envMean = mean(hpcEnv.data);
            %envStd  = std(hpcEnv.data);
            evThresh  = md.thresh.CA1;
            [events,~] = eegRipples( contchans_trode_group(r,d.trode_groups,'CA1'),evThresh, evThresh/2, 0.03, 0.005, evThresh*3/4,0.01);
        elseif any(strcmp(area,{'RSC','CTX'}))
            if(strcmp(area,'RSC'))
                thresh = md.thresh.RSC;
            else
                thresh = md.thresh.CTX;
            end
            [events,~] = find_dips_frames_by_lfp( contchans_trode_group(r,d.trode_groups,area), thresh);
        else
            error('swwBarChart:unknown_area',['Unknown area: ',area]);
        end
        
        % Merge them
        eventCenters = cellfun(@(x) (x(2)+x(1))/2,events);
        goodEvents   = gh_points_in_segs(eventCenters, timewins);
        rate         = numel(goodEvents) / sum(cellfun(@diff, timewins));
        save(rPath,'eventCenters','goodEvents','rate');
    end
        
end

function c = timeArrayToSegments(a)

assert(size(a,2) == 2);

c = mat2cell(a, ones( size(a,1), 1 ), 2);

end
