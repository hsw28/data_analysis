function [pf edge_bins] = dset_calc_tc(st, pos, delta_t, varargin) 
%CALCULATE_TUNING_CURVE
%
%   curve = CALCULATE_TUNING_CURVE(spike_times, animal_pos, dir, fs, )
%
%   curve1 is the place field of movement in the positive direction
%   curve2 is the place field of movement in the negative direction
%   delta_t is 1/Fs or length of one position sample
%
%   bin_width is the width in meters of a single bin of the place field
%size(spike_times)

args.bin_width = 5;
args.pos_smoothKW = 2* args.bin_width;
args.time_win = [-Inf Inf];
args.velocityThreshold = 10;
args = parseArgs(varargin,args);
args.smooth_segments = 1;

tc = [];
tc_total = [];


positionIdx = pos.ts >= args.time_win(1) & pos.ts <= args.time_win(2);
    
ts = pos.ts(positionIdx);
lp = pos.linpos;
lv = pos.smooth_vel;

spikeIdx = st>=args.time_win(1) & st <= args.time_win(2);
st = st(spikeIdx);

warning off;

spike_pos = interp1(ts, lp, st, 'nearest');
spike_vel = interp1(ts, lv, st, 'nearest');
warning on;


spikesMovingIdx = spike_vel >= args.velocityThreshold;
posMovingIdx = lv >= args.velocityThreshold;

    %posBins = min(pos.linear_sections{i}) : args.bin_width :
    %max(pos.linear_sections{i});
    segment_edges = [];
    edge_bins = [];
    sectionPosBins = [];
for i = 1:numel(pos.linear_sections)
    segment_edges(i,:) = [min(pos.linear_sections{i}) max(pos.linear_sections{i})];
    tempBins =  segment_edges(i,1) : args.bin_width : segment_edges(i,2);
    sectionPosBins{i} = tempBins;
    
    if (1==i)
        edge_bins(1,:) = [1 numel(tempBins)];
    else
        edge_bins(i,:) = [edge_bins(i-1,2) + 1  , edge_bins(i-1,2) + numel(tempBins)];
    end
end
edge_bins;
posBins = [sectionPosBins{1}, sectionPosBins{2}, sectionPosBins{3}];
%posBins = min(pos.linpos) : args.bin_width : max(pos.linpos);

posOcc = histc( lp(posMovingIdx), posBins);


spikeOcc = histc(spike_pos(spikesMovingIdx), posBins);

warning off;
if isempty(spikeOcc)
    spikeOcc = zeros(size(posBins))';
end
if isempty(posOcc)
    posOcc = zeros(size(posBins))';
end

spikeOcc = spikeOcc(:);
posOcc = posOcc(:);

pf = spikeOcc ./ (posOcc * delta_t);
pf(isnan(pf)) = 0;
pf(isinf(pf)) = 0;

% smooth the calculated fields
args.smooth_segments = 1;
if (args.smooth_segments)
    for i = 1:size(segment_edges,1)
        mass = pf(edge_bins(i,1): edge_bins(i,2));
        mass = smoothn(mass, args.pos_smoothKW, args.bin_width, 'correct' ,1);
        pf(edge_bins(i,1): edge_bins(i,2)) = mass;
        
    end
else 
    pf = smoothn(pf, args.pos_smoothKW, args.bin_width, 'correct', 1);
end
pf = pf + .01;

warning on;
segment_edges = nan;

%disp([length(spikesMovingIdx), sum(spikesMovingIdx)]);

% 
% 
% posInd = pos.ts>=args.time_win(1) & pos.ts<=args.time_win(2);
% 
% pos.ts = pos.ts(posInd);
% pos.lp = pos.lp(posInd);
% pos.lv = pos.lv(posInd);
% 
% spikeInd = spike_times>=args.time_win(1) & spike_times<=args.time_win(2);
% spike_times = spike_times(spikeInd);
% 
% warning off;
% spike_pos = interp1(pos.ts, pos.lp, spike_times, 'nearest');
% spike_vel = interp1(pos.ts, pos.lv, spike_times, 'nearest');
% warning on;
% %plot(spike_vel)
% 
% %pause;
% %[size(spike_pos) size(spike_vel)]
% spike_pos_dir1 = spike_pos(logical(spike_vel>.10));
% spike_pos_dir2 = spike_pos(logical(spike_vel<-.10));
% 
% 
% pos_dir1 = pos.lp(pos.lv>.10);
% pos_dir2 = pos.lp(pos.lv<-.10);
% %[sum(pos_dir1) sum(pos_dir2)]
% 
% n = length(range);
% 
% po1 = histc(pos_dir1, range);
% po1 = smoothn(po1, s_width, args.bin_width);
% po2 = histc(pos_dir2, range);
% po2 = smoothn(po2, s_width, args.bin_width);
% 
% so1 = histc(spike_pos_dir1, range);
% so2 = histc(spike_pos_dir2, range);
% 
% if isempty(so1)
%     so1 = zeros(1,32);
% end
% if isempty(so2)
%     so2 = zeros(1,32);
% end
% 
% warning off;
% cv1 = so1 ./(po1 * delta_t);
% cv1(isnan(cv1))=0;
% cv1(isinf(cv1))=0;
% cv1 = cv1+.05;
% 
% cv2 = so2 ./(po2 * delta_t);
% cv2(isnan(cv2))=0;
% cv2(isinf(cv2))=0;
% cv2 = cv2+.05;
% warning on;
% %pause;