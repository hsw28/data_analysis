function phase_cell = spiketime_to_phase(spiketimes_cell,theta_cdat,bouts)

%p = inputParser;
%p.addOptional('bouts',[],@(x)not(isempty(x)));
%p.addOptional('chan',1,@(x)(numel(x)==1));
%p.parse(varargin{:});
%bouts = p.Results.bouts;

nneuron = numel(spiketimes_cell.data)
%phase_cell = spiketimes_cell;
nbouts = size(bouts,1);

timephase = theta_cdat.tstart:1/theta_cdat.samplerate:theta_cdat.tend;
ntime = numel(timephase)
theta = theta_cdat.data(:,1);

for i = 1:nneuron
    spiketimes = spiketimes_cell.data{i};
    nspike = numel(spiketimes)
    ok_array = zeros(numel(spiketimes),nbouts);
    for k = 1:nbouts
        ok_array(:,k) = min([spiketimes >= bouts(k,1), spiketimes <= bouts(k,2)],[],2);
    end
    ok_list = max(ok_array,[],2);
    spiketimes = spiketimes(find(ok_list));
    nspike = numel(spiketimes)
    this_neuron_phases = ones(size(spiketimes));
 
    for k = 1:nspike
        spike = spiketimes(k);
        gt_list = spike <= timephase;
        gt_index = find(gt_list);
        gt_index = gt_index(1);
        rear_phase = theta(gt_index);
        front_phase = theta(gt_index + 1);
        rear_time = timephase(gt_index);
        front_time = timephase(gt_index + 1);
        this_phase = rear_phase + (front_phase-rear_phase)*(spike-rear_time)/(front_time-rear_time);
        this_neuron_phases(k)=this_phase;
        this_neuron_phases(k)=front_phase;
    end
    phase_cell.data{i} = this_neuron_phases;
end
