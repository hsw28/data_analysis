function ripples = ripplesFromMUARate(muaRate,varargin)

warning('DEPRICATED.  Use eegRipples?');

p = inputParser();
p.addParamValue('peakStdevBeyondMean',2);
p.addParamValue('edgeStdevBeyondMean',0);
p.addParamValue('minWidthS', 0.03);
p.addParamValue('bridgeWidthS', 0.010);
p.addParamValue('minFracAgreement',0.5);
p.addParamValue('draw',false);
p.addParamValue('eeg',[]);
p.parse(varargin{:});
opt=p.Results;

% Make summary stats
%meanMuaRate = muaRate;
%meanMuaRate.data = mean(meanMuaRate.data,2);

%meanMeanRate = mean(mean(muaRate.data));
%stdRate = std(mean(muaRate.data,2));
%peakThresh = meanMeanRate + opt.peakStdevBeyondMean*stdRate;
%edgeThresh = max(0,meanMeanRate + opt.edgeStdevBeyondMean*stdRate);



chanIsRippling = muaRate;  % Copy a cdat to hold rippling state for each chan

nChan = size(chanIsRippling.data,2);

ts = conttimestamp(muaRate);
for n = 1:nChan

    thisData = muaRate.data(:,n);
    meanRate = mean(thisData);
    stdRate = std(thisData);
    peakThresh = mean(thisData) + opt.peakStdevBeyondMean * stdRate;
    edgeThresh = max(0, meanRate + opt.edgeStdevBeyondMean*stdRate);

    ripple_crit = seg_criterion('name','ripple','peak_min', peakThresh,...
        'cutoff_value', edgeThresh, 'min_width_pre_bridge', opt.minWidthS, ...
        'bridge_max_gap', opt.bridgeWidthS);

    thisSegs = gh_signal_to_segs( contchans(muaRate,'chans',[n]), ripple_crit );
    % isRip = gh_points_are_in_segs( ts, thisSegs );  % This is the spec, but too slop
    [~,isRip] = gh_times_in_timewins( ts, cell2mat(thisSegs) );
    chanIsRippling.data(:,n) = isRip;

end

% Collapse isRippling across chans.  This is the degree of chan agreement over time
chanIsRippling.data = sum(chanIsRippling.data,2);

agreement_crit = seg_criterion('name','crossChannelRippleAgreement',...
    'cutoff_value', opt.minFracAgreement * nChan,'min_width_pre_bridge', opt.minWidthS,...
    'bridge_max_gap', opt.bridgeWidthS);

ripples = gh_signal_to_segs( chanIsRippling, agreement_crit );

if(opt.draw)
    nRow = 2;
    if(~isempty(opt.eeg))
        nRow = 3;
    end

    ax(1) = subplot(2,1,1);
    gh_signal_to_segs( chanIsRippling, agreement_crit, 'draw',true ); % YUCK! copy-pasted from 4 lines up.  How to fix?
    ax(2) = subplot(2,1,2);
    gh_plot_cont( muaRate );
    linkaxes(ax,'x');
end