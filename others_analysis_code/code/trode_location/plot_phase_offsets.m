function phase_offset = plot_phase_offsets(phase_cdat,varargin)

p = inputParser();
p.addParamValue('ref_ind',1,@(x) (x == floor(x)));
p.addParamValue('timewin',[phase_cdat.tstart, phase_cdat.tend]);
p.addParamValue('local_env_weight',true,@islogical);
p.addParamValue('env_cdat',[]);
p.addParamValue('weight_factor',1,@isreal);
p.addParamValue('conv_table',[]);
p.parse(varargin{:});

ref_ind = p.Results.ref_ind;
timewin = p.Results.timewin;
weigh_by_env = not(isempty(p.Results.env_cdat));
conv_table = p.Results.conv_table;

phase_cdat = contwin(phase_cdat,timewin);
if(not(isempty(p.Results.env_cdat)))
    env_cdat = contwin(p.Results.env_cdat,timewin);
else
    env_cdat = [];
end

phase_offset = phase_cdat;

n_chan = size(phase_cdat.data,2);

if(ref_ind > 0)
    samp_phase = phase_cdat.data(:,ref_ind);
    %mod1 = mod(samp_phase + pi,2*pi);
else
    samp_phase = mean(phase_cdat.data,2);
    %mod1 = mod(samp_phase + pi, 2*pi);
end

if(weigh_by_env)
    weights = env_cdat.data .* repmat(env_cdat.data(:,ref_ind),1,n_chan);
    stdevs = std(env_cdat.data);
    means = mean(env_cdat.data);
    weigths = weights ./ repmat(stdevs,size(weights,1),1);
    %mins = repmat(min(weights),size(weights,1),1);
    %weights = (weigths + mins) .* p.Results.weight_factor;
    weights = and(env_cdat.data >= repmat(stdevs,size(weights,1),1).*-0.5 + repmat(means,size(weights,1),1),...
        repmat(env_cdat.data(:,ref_ind),1,n_chan) >= stdevs(ref_ind).*-0.5 + repmat(means,size(weights,1),1));
    %weights = 1-weights;
else
    weights = ones(size(phase_cdat.data));
end
    
for i = 1:size(phase_offset.data,2)
    phase_offset.data(:,i) = gh_circular_subtract(phase_offset.data(:,i),samp_phase);
end


% figure;
% for i = 1:n_chan
%         subplot(2,6,i);
%         plot(conttimestamp(phase_offset),phase_offset.data(:,i));
%         title(phase_cdat.chanlabels{i});
%         set(gca,'YLim',[-1*pi pi])
%         set(gca,'XLim',timewin);
%         hold on
%         plot([timewin(1),timewin(2)],[0 0],'g');
% end
figure;

if(isempty(conv_table))

    for i = 1:12
        subplot(2,6,i);
        j = i;
        if(j > 6)
            j = 19-j;
        end
        phase_offsets = phase_offset.data(:,j);
        thetas = [-pi:pi/40:pi];
        [n_scaled,ind] = gh_whistc(phase_offsets,weights(:,j),thetas);
        polar(thetas',n_scaled); hold on;
        title(phase_cdat.chanlabels{j});
    end

else
    %the_fig = figure;
    nchan = size(phase_offset.data,2);
    for i = 1:nchan
        this_comp = phase_cdat.chanlabels{i};
        this_comp_ind = find(strcmp(conv_table.data(1,:),this_comp));
        this_pos = [conv_table.data{6,this_comp_ind},...
            conv_table.data{5,this_comp_ind}];
        phase_offsets = phase_offset.data(:,i)';
        thetas = [-pi:pi/40:pi];
        %numel(phase_offsets);
        %[n_scaled,ind] = gh_whistc(phase_offsets,weights(:,i)',thetas);
        %[n_scaled,ind] = gh_whistc(phase_offsets,ones(size(phase_offsets)),thetas);
        [n_scaled,ind] = histc(phase_offsets,thetas);
        gh_add_polar(thetas,n_scaled,'color',[0 1 0],'pos',this_pos,'max_r',1)
    end
end