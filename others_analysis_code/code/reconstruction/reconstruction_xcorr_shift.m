function [ rs,steps ] = reconstruction_xcorr_shift(d,m,area0,areaTau, varargin )
%RECONSTRUCTION_XCORR_SHIFT Slide one rpos wrt the other, check correlation
% at each shift
p = inputParser();
p.addParamValue('xcorr_range',0.1);
p.addParamValue('xcorr_step', 0.005);
p.addParamValue('r_tau',0.010);
p.addParamValue('only_direction',[]);
p.addParamValue('posSteps',[-5:1:5]);
p.addParamValue('min_vel',0.2);
p.parse(varargin{:});
opt = p.Results;

trodeGroup0   = d.trode_groups( cellfun(@(x) strcmp(x.name,area0),d.trode_groups) );
placeCells0   = placeCellsOfGroup(d.spikes, area0,   d.trode_groups);
trodeGroupTau = d.trode_groups( cellfun(@(x) strcmp(x.name,areaTau),d.trode_groups) );
placeCellsTau = placeCellsOfGroup(d.spikes, areaTau, d.trode_groups);

% Do one pass just to get the trigger times
rTimewin = [min(d.pos_info.timestamp),max(d.pos_info.timestamp)];
throwawayRpos = decode_pos_with_trode_pos(placeCells0,d.pos_info,...
    trodeGroup0,'r_tau',opt.r_tau,'r_timewin',rTimewin,'field_direction','bidirect');
[~,trigTimesOut] = gh_triggered_reconstruction(throwawayRpos,d.pos_info,'lfp',d.thetaRaw,'min_vel',opt.min_vel);
[~,trigTimesIn]  = gh_triggered_reconstruction(throwawayRpos,d.pos_info,'lfp',d.thetaRaw,'min_vel',-opt.min_vel);
trigTimes = [trigTimesOut,trigTimesIn];
rposTrig0 = triggeredBidirect(placeCells0,d.pos_info,trodeGroup0,0,0,opt.min_vel,trigTimes,opt.r_tau,rTimewin,opt.only_direction);

steps = -opt.xcorr_range : opt.xcorr_step : opt.xcorr_range;

rs = zeros(numel(opt.posSteps),numel(steps));

for p = 1:numel(opt.posSteps)
    rs(p,:) = arrayfun(@(s) triggeredBidirectCorr(placeCellsTau,d.pos_info,trodeGroupTau,s,opt.posSteps(p),...
        opt.min_vel,trigTimes,opt.r_tau,rTimewin,opt.only_direction,rposTrig0),steps);
end

end

function rpTrig = triggeredBidirect(placeCells,posInfo,tg,tDelay,posShift,minVel,trigTimes,rTau,rTimewin,onlyDir) 
    disp(['tic',num2str(tDelay)]);
    rpOut = decode_pos_with_trode_pos(placeCells,posInfo,tg,'r_tau',rTau,'r_timewin',...
        rTimewin,'field_direction','outbound');
    rpIn  = decode_pos_with_trode_pos(placeCells,posInfo,tg,'r_tau',rTau,'r_timewin',...
        rTimewin,'field_direction','inbound');

    trigTimesOut = gh_times_in_timewins(trigTimes,posInfo.out_run_bouts);
    trigTimesIn  = gh_times_in_timewins(trigTimes,posInfo.in_run_bouts);
    
    rpTrigOut = gh_triggered_reconstruction(rpOut,posInfo,'min_vel', minVel,...
        'trig_times',trigTimesOut+tDelay);
    rpTrigIn  = gh_triggered_reconstruction(rpIn, posInfo,'min_vel',-minVel,...
        'trig_times',trigTimesIn+tDelay);

    if(all(strcmp(onlyDir,'outbound')) || sum(sum(isnan(rpTrigIn.pdf_by_t))) > 0)
        rpTrig = rpTrigOut;
    elseif(all(strcmp(onlyDir,'inbound')) || sum(sum(isnan(rpTrigOut.pdf_by_t))) > 0)
        rpTrig = rpTrigIn;
    elseif(isempty(onlyDir) || all(strcmp(onlyDir, {'outbound','inbound'})) || all(strcmp(onlyDir, {'inbound','outbound'})))
        rpTrig = rpTrigOut;
        for n = 1:numel(rpTrig)
            tOut = rpTrig(n).pdf_by_t;
            tIn  = rpTrigIn(n).pdf_by_t(end:-1:1,:);
            rpTrig(n).pdf_by_t = tOut ./ max(max(tOut)) + tIn ./ max(max(tIn));
        end
    else
        error('reconstruction_xcorr_shift:unrecognizedOnlyDirection',...
            ['Didn''t recognize only_direction option:',onlyDir]);
    end
    
    rpTop    = repmat(rpTrig.pdf_by_t(1,:),   abs(posShift),1);
    rpBottom = repmat(rpTrig.pdf_by_t(end,:), abs(posShift),1);
   
    if(posShift >= 1)
        rpTrig.pdf_by_t = [rpTrig.pdf_by_t((1+posShift):end,:); rpBottom];
    elseif(posShift <= (-1))
        rpTrig.pdf_by_t = [rpTop; rpTrig.pdf_by_t(1:(end-abs(posShift)),:)];
    end
    
end

function r2 = triggeredBidirectCorr(placeCells,posInfo,tg,tDelay,posShift,minVel,trigTimes,rTau,rTimewin,onlyDir,trigRPos0)

    rpTrig = triggeredBidirect(placeCells,posInfo,tg,tDelay,posShift,minVel,trigTimes,rTau,rTimewin,onlyDir);
    r2 = corr(reshape(trigRPos0.pdf_by_t,[],1), reshape(rpTrig.pdf_by_t,[],1));

    subplot(2,1,1); plot_multi_r_pos(trigRPos0,posInfo,'norm_c',true);
    subplot(2,1,2); plot_multi_r_pos(rpTrig,   posInfo,'norm_c',true);
    title(['t: ', num2str(tDelay),'  p:', num2str(posShift)]);
    
end

function pc = placeCellsOfGroup(pc0, groupName, trodeGroups)
    groupNames = cmap(@(x) x.name,trodeGroups);
    groupInd = find(strcmp(groupNames,groupName),1);
    if(isempty(groupInd))
        error('reconstructoin_xcorr_shift:noGroup',...
            ['Found no trode group named ',groupName]);
    end
    group = trodeGroups{groupInd};
    inds = group.trodes;
    pc = sdatslice(pc0,'trodes',inds);

end