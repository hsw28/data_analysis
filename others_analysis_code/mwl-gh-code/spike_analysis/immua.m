function [sdat] = immua(mua_list,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('threshold',[]);
p.addParamValue('get_all_data',false);
p.addParamValue('t_width', []); % range [min, max]
p.addParamValue('t_width_guide', false);
p.addParamValue('samplerate',400);
p.addParamValue('gauss_sd_secs', 2/400);
p.addParamValue('arte_correction_factor',[]);
p.parse(varargin{:});
opt = p.Results;

nfile = numel(mua_list.file_list);

sdat.name = ('mua');
sdat.nclust = nfile;
sdat.userdata = struct();

for i = 1:nfile
    filename = mua_list.file_list{i};
    compname = mua_list.comp_list{i};
    this_clust = newemptyclust();
    this_clust.name = compname;
    dot_ind = find(filename=='.');
    dot_ind = dot_ind(numel(dot_ind));
    basename = filename(1:dot_ind-1);
    this_clust.from_tt_file = [basename,'.tt'];
    this_clust.comp = compname;
    this_clust.trode = compname;
    this_file = mwlopen(filename);
    this_clust.stimes = double(this_file.time);
    this_clust.t_maxwd = double(this_file.t_maxwd);
    if(p.Results.get_all_data)
    this_clust.data = [double(this_file.id'),double(this_file.t_px'),double(this_file.t_py'),double(this_file.t_pa'),double(this_file.t_pb'),...
        double(this_file.t_maxwd'),double(this_file.t_maxht'),double(this_file.pos_x'),double(this_file.pos_y'),...
        double(this_file.velocity')];
    else
        this_clust.data = [double(this_file.time'), double(this_file.t_maxwd')];
    end
    good_logical = ones(size(this_clust.stimes));

    if(opt.t_width_guide)
        bin_edges = bin_centers_to_edges(-32:32);
        counts = histc(this_clust.data(:,2), bin_edges);
        bar( (-32:32), counts(1:(end-1)) );
        opt.t_width = input('Please enter [min width, max width]:');
    end
    if(~isempty(opt.t_width))
            good_logical = and(this_clust.data(:,2) >= min(opt.t_width),...
                this_clust.data(:,2) <= max(opt.t_width) );
%            this_clust.stimes = this_clust.stimes(good_logical);
%            this_clust.data = this_clust.data(good_logical, :);
    end

    if(p.Results.get_all_data)
    this_clust.featurenames = {'id','t_px','t_py','t_pa','t_pb','t_maxwd','t_maxht','pos_x','pos_y','velocity'};
    else
        this_clust.featurenames = {'time','t_maxwd'};
    end

    if(~isempty(opt.arte_correction_factor))
        warning('immua:arte_correcting',['Correcting trode ', compname, ' by ', num2str(opt.arte_correction_factor)]);
        this_clust.stimes = this_clust.stimes + opt.arte_correction_factor;
        t_ind = strcmp('time', this_clust.featurenames);
        this_clust.data(:,t_ind) = this_clust.stimes';
    else
        error('immua:no_arte_correction','Must pass arte_correction_factor.  Zero for ad comps.');
    end
    
    if(~isempty(opt.threshold))
        ps = [this_file.t_px; this_file.t_py; this_file.t_pa; this_file.t_pb];
        thresh_ok = max(ps,[],1) >= opt.threshold;
        good_logical = good_logical & thresh_ok';
 %       this_clust.stimes = this_clust.stimes(thresh_ok);
 %       this_clust.t_maxwd = this_clust.t_maxwd(thresh_ok);
 %       this_clust.data = this_clust.data(thresh_ok,:);
    end
    
    if(~isempty(opt.timewin))
        good_times = and( this_clust.stimes >= p.Results.timewin(1), this_clust.stimes <= p.Results.timewin(2));
        good_logical = good_logical & good_times';
 %       this_clust.stimes = this_clust.stimes(good_logical);
 %       this_clust.t_maxwd = this_clust.t_maxwd(good_logical);
 %       this_clust.data = this_clust.data(good_logical,:);
    end
    
    this_clust.stimes  = this_clust.stimes(good_logical);
    this_clust.data    = this_clust.data(good_logical,:);
    this_clust.t_maxwd = this_clust.t_maxwd(good_logical');

    sdat.clust{i} = this_clust;

    %[~,tmp_cdat] = assign_rate_by_time(sdatslice(sdat,'index',i),...
    %    'timewin',opt.timewin,'samplerate',opt.samplerate,...
    %    'gauss_sd_secs', opt.gauss_sd_secs);
    %if(i == 1)
    %    cdat = tmp_cdat;
    %else
    %    cdat.chanlabels = [cdat.chanlabels, {tmp_cdat.chanlabels}];
    %    cdat.data = [cdat.data, tmp_cdat.data];
    %end
    
end

%cdat = imcont('timestamp', conttimestamp(cdat), 'data', cdat.data );
%cdat.chanlabels = cellfun(@(x) x.comp, sdat.clust,'UniformOutput',false);