function new_sdat = spikechans(sdat,varargin)

p = inputParser;
p.addOptional('chans',cell(0),@(x)and(all(x>0),all(x<= numel(sdat.data))));
p.addOptional('chanlabels',cell(0),@iscell);
p.parse(varargin{:});
opt = p.Results;

if not(xor(isempty(opt.chans),isempty(opt.chanlabels)))
    error('Exactly one chans or chanlabels required.');
    new_sdat = struct;
    return;
end

if (not(isempty(opt.chans)))
    n_chans = numel(opt.chans);
    for i = 1:n_chans
        new_sdat.data{i} = sdat.data{opt.chans(i)};
        new_sdat.chanlabels{i} = sdat.chanlabels{opt.chans(i)};
    end
end

if (not(isempty(opt.chanlabels)))
    n_chans = numel(opt.chanlabels);
    for i = 1:n_chans
        this_index = find(strcmp(opt.chanlabels{i},sdat.chanlabels));
        new_sdat.data{i} = sdat.data{this_index};
        new_sdat.chanlabels{i} = sdat.chanlabels{this_index};
    end
end