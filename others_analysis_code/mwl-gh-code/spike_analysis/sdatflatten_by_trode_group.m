function new_sdat = sdatflatten_by_trode_group(...
    sdat, trode_groups, varargin)
% sdatflatten_by_trode_group  lump together all spikes from the same trodegroup
% this is useful for comparing the multiunit phase offset to grouped replay
% despite the sdat label, you can pass a cdat_r that has been created by
%  assign_rate_by_time(), and sdatflatten_by_trode_group will use
% sdat.raw to infer the original spike rates and add them up by group,
% then produce a matching sdat_r output
% optional params:
%  timewin - only analyze subset of time
% tmewin_buffer_offset - grow timewin by this much to 
%   help fight against strange edge phase calculations

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('timewin_buffer_offset',2);
p.parse(varargin{:});
opt = p.Results;

n_trodegroups = numel(trode_groups);

if( isfield(sdat, 'env') )
    % we are actually dealing with smth like an cdat_r, not sdat
    % throw away everything except cdat.raw
    sdat = sdat.raw;
    
    input_timerange = [sdat.tstart, sdat.tend];
    if(~isempty(opt.timewin))
        % request a timewin bigger than that passed by user, by
        % buffer_offset seconds
        timewin = opt.timewin + [-1, 1] .* opt.timewin_buffer_offset;
        
        % pull the requested timewin back in if it goes past the edges
        % of the input
        timewin = [ max([input_timerange(1), timewin]), ...
            min([input_timerange(2), timewin])];
        
        sdat = contwin(sdat, timewin);
    end
    
    n_ts = size(sdat.data,1);
    n_chans = size(sdat.data,2);
    
    new_data = zeros(n_ts, n_trodegroups);
    new_sdat = sdat;
    new_sdat.chanlabels = [];
    
     for n = 1:n_trodegroups
        for m = 1:n_chans
            if(any(strcmp(sdat.chanlabels{m}, trode_groups{n}.trodes)))
                new_data(:,n) = new_data(:,n) + sdat.data(:,m);
            end
        end
        new_sdat.chanlabels{n} = ['trode_group', num2str(n)];
     end
     
     new_sdat.data = new_data;
     new_sdat = prep_eeg_for_regress(new_sdat, ...
         'timewin_buffer', opt.timewin_buffer_offset);
elseif( isfield( sdat.clust ))

else
    error('sdatflatten_by_trode_group:unknown_input',...
           'unknown input for sdat');
end