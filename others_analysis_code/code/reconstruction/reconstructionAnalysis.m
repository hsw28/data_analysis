function res = reconstructionAnalysis(baseData,metadata,varargin)

p = inputParser();
p.addParamValue('r_tau',0.01);
p.addParamValue('shift_through_n',10);
p.parse(varargin{:});
opt = p.Results;

d = baseData;

eeg_r = prep_eeg_for_regress(contchans(d.eeg,...
    'chanlabels',{metadata.singleThetaChan}));

r_pos_out = decode_pos_with_trode_pos(d.spikes,d.pos_info,d.trode_groups,...
    'field_direction', 'outbound','r_tau',opt.r_tau);

r_pos_in = decode_pos_with_trode_pos(d.spikes,d.pos_info,d.trode_groups,...
    'field_direction', 'inbound', 'r_tau', opt.r_tau);

shift_vals = [-opt.shift_through_n : opt.shift_through_n ];
for s = 1:numel(shift_vals)

    r_pos_trig_out = gh_triggered_reconstruction(r_pos_out,d.pos_info,...
        'phase_cdat',eeg_r.phase,'env_cdat',eeg_r.env,...
        'lfp_chan',metadata.singleThetaChan,'min_vel',0.2,'draw',false);
    r_pos_trig_in = gh_triggered_reconstruction(r_pos_in, d.pos_info, ...
        'phase_cdat',eeg_r.phase,'env_cdat',eeg_r.env,...
        'lfp_chan',metadata.singleThetaChan,'min_vel',-0.2,'draw',false);

    r_pos_trig = r_pos_trig_out;
    for n = 1:numel(r_pos_trig)
        r_pos_trig(n).pdf_by_t = ...
            (r_pos_trig_out(n).pdf_by_t + ...
            r_pos_trig_in(n).pdf_by_t((end:-1:1),:))./2;
    end


end

dt = opt.r_tau;

xc = xcorr2(r_pos_trig(1).pdf_by_t,r_pos_trig(2).pdf_by_t);

tReach = dt * (size(xc,2)- 1)/2;

cMax = max(max(xc));
ts = linspace(-tReach,tReach,size(xc,2));
tMax = ts(find(max(xc) == cMax,1,'first'));

res.r_pos_trig = r_pos_trig;
res.xc         = xc;
res.tMax       = tMax;

function b = baseDataIsOk(d,m)

goodCellCount =  (isfield(m,'keep_list')) && ...
    (length(m.keep_list) == length(d.spikes.clust));

b = goodCellCount;