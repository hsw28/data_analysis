function [xc,steps] = collect_reconstruction_xcorr(varargin)

p = inputParser();
p.addParamValue('cleanSlate',false);
p.addParamValue('draw',true);
p.parse(varargin{:});
opt = p.Results;

metadatas = { yolanda_112511_metadata()  ...
            , yolanda_120711_metadata()  ...
            , morpheus_052310_metadata() ...
            , caillou_112812_metadata() };

nSessions = numel(metadatas);
xc = cell(1,nSessions);
        
for i = 1:nSessions
    m = metadatas{i};
    baseData = [m.basePath,'/scatterData.mat'];
    xcData   = [m.basePath,'/rposData.mat'];
    pData    = [m.basePath,'/pData.mat'];
    ratDefault = defaultData(m);
    
    if(~exist(xcData) || ~exist(pData) || opt.cleanSlate )
        if(~exist(baseData) || ~exist(pData) || opt.cleanSlate )
            d = loadData(m,'segment_style','ml');
            pos_info = d.pos_info;
            save(baseData,d);
            save(pData,'pos_info');
        else
            load(baseData);
            load(pData);
        end

        d.trode_groups = m.trode_groups_fn('date',m.today,'segment_style','ml');
            [rs,steps] = reconstruction_xcorr_shift(d,m,'medial','lateral', ...
                'only_direction',ratDefault.okDirections,'xcorr_step', 0.0025,'posSteps',[-6:1:6]);
            pos_info = d.pos_info; % save it off for later use, too cumbersome to load all of 'd'
            save(pData,'pos_info')
            save(xcData, 'rs','steps');
    else
        load(xcData);
        load(pData);
    end
    
    xc{i} = rs;
    if(opt.draw)
        xLims = [min(steps),max(steps)];
        dx = mean(diff(pos_info.occupancy.bin_centers));
        nPosShifts = size(rs,1);
        shiftsLim = floor((nPosShifts+1)/2);
        posShifts = [-shiftsLim:shiftsLim] .* dx;
        xLims = [min(steps),max(steps)];
        yLims = [min(posShifts),max(posShifts)];
        subplot(2,2,i);
        [c,ic] = heatRegress(xLims,yLims,rs,'draw',true);
        plot([0,0],    yLims/10,'k');
        plot(xLims/10, [0,0],   'k');
        xIntercept = -ic/c;
        text(0,0,num2str(xIntercept*1000));
    end
    
end % end for loop
end

function dat = defaultData(m)
% Rat-specific config goes here.
    if(strContains(m.basePath,'yolanda') && strContains(m.basePath,'120711'))
         dat.okDirections = {'outbound','inbound'};
    elseif(strContains(m.basePath,'yolanda') && strContains(m.basePath,'112511'))
        dat.okDirections = {'outbound','inbound'};
    elseif(strContains(m.basePath,'caillou'))
        dat.okDirections = {'outbound'};
    elseif(strContains(m.basePath,'morpheus'))
        dat.okDirections = {'outbound','inbound'};
    else
        error('collect_reconstruction_xcorr:unknown_rat',...
            ['couldn''t get data for recording session at ',m.basePath]);
    end
end

