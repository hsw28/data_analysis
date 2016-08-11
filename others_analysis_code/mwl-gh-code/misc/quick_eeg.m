function [eeg, opt] = quick_eeg(varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('file1',[]);
p.addParamValue('file2',[]);
p.addParamValue('file3',[]);
p.addParamValue('file4',[]);
p.addParamValue('system_list',{'ad','ad'});
p.addParamValue('f1_ind',[]);
p.addParamValue('f2_ind',[]);
p.addParamValue('f3_ind',[]);
p.addParamValue('f4_ind',[]);
p.addParamValue('f1_chanlabels',[]);
p.addParamValue('f2_chanlabels',[]);
p.addParamValue('f3_chanlabels',[]);
p.addParamValue('f4_chanlabels',[]);
p.addParamValue('samplerate',400);
p.addParamValue('arte_gains',5000);
p.addParamValue('arte_correction_factor',[]);
p.addParamValue('sort',false);
p.addParamValue('trode_groups',[]);
p.addParamValue('sort_areas',[]);
p.addParamValue('opt',[]); % for pre-specified opt structs
p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.opt))
    opt = opt.opt;
end

n_files = 0;
if(~isempty(opt.file1))    
    n_files = n_files + 1; end
if(~isempty(opt.file2))
    n_files = n_files + 1; end
if(~isempty(opt.file3))
    n_files = n_files + 1; end
if(~isempty(opt.file4))
    n_files = n_files + 1; end


if(ischar(opt.system_list))
    % Replicate single string into cell array
    opt.system_list = cellfun(@(x) opt.system_list, cell(1,n_files));
end
if(numel(opt.system_list) < n_files)
    error(['quick_eeg:need_system_arg','Must pass at least ', num2str(n_files), 'strings as ''system_list''']);
end

eeg_ad = [];
eeg_arte = [];
for n = 1:n_files
    if(strcmp(opt.system_list{n}, 'ad')) 
        eeg_ad = import_one_eeg(opt, eeg_ad, n);
    elseif(strcmp(opt.system_list{n}, 'arte'))
        eeg_arte = import_one_eeg(opt,eeg_arte,n);
    end
end

eeg = contcombine(eeg_ad, eeg_arte);
eeg.data( isnan(eeg.data) ) = 0;

if(opt.sort)
    all_areas = cmap( @(x) x.name, opt.trode_groups);
    opt.sort_areas = [opt.sort_areas, setdiff(all_areas, opt.sort_areas)];
    group_num = zeros(1,size(eeg.data,2));
    for n = 1:numel(group_num)
        for g = 1:numel(opt.sort_areas)
            tg_ind = find(strcmp( opt.sort_areas{g}, cmap(@(x) x.name, opt.trode_groups) ));
            if(isempty(tg_ind))
                error('quick_eeg:sort_no_such_group',['No such trode_group: ', opt.sort_areas{g}]);
            end
            this_trodes = opt.trode_groups{ tg_ind }.trodes;
            if(any(strcmp(eeg.chanlabels{n}, this_trodes)))
                group_num(n) = g;
            end
        end
    end
    [~,i] = sort(group_num);
    eeg = contchans(eeg,'chans',i);
end


end

function new_eeg = import_one_eeg(opt, old_eeg,ind)

filename = opt.(['file', num2str(ind)]);
inds     = opt.(['f', num2str(ind), '_ind']);
labels   = opt.(['f', num2str(ind), '_chanlabels']);

if(isempty(inds))
    inds = 1:numel(labels);
end

if(strcmp(opt.system_list{ind}, 'arte'))
    extra_args = {'gains', repmat(opt.arte_gains,1, numel(inds))};
else
    extra_args = cell(0);
end

[~,~,new_eeg] = gh_debuffer(filename,'timewin',opt.timewin,...
    'chans', inds,'system',opt.system_list{ind},...
    'arte_correction_factor',opt.arte_correction_factor,extra_args{:});

new_eeg.data = double(new_eeg.data);
new_eeg.chanlabels = labels;


if(~isempty(opt.samplerate))
    if(abs(new_eeg.samplerate-opt.samplerate)/opt.samplerate > 0.1)
        new_eeg = contresamp(new_eeg,'resample',opt.samplerate/new_eeg.samplerate);
    end
end

if(isempty(old_eeg))
    new_eeg = new_eeg;
else
    %if size(new_eeg.data,1) ~= size(old_eeg.data,1)
    %    ts = conttimestamp(old_eeg);
    %    new_eeg.data = interp1( conttimestamp(new_eeg), new_eeg.data, ts, 'spline','extrap' );
    %end
    %new_eeg.data = [old_eeg.data, new_eeg.data];
    %new_eeg.chanlabels = [old_eeg.chanlabels, new_eeg.chanlabels];    
    new_eeg = contcombine(old_eeg,new_eeg);
    new_eeg.data( isnan( new_eeg.data ) ) = 0;
end

new_eeg.datarange = [min(new_eeg.data); max(new_eeg.data)]';

end