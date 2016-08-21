function mu = dset_exp_load_mu(edir, epoch)
% load a exp as a dset
% DSET
%   - mu
%       - rate
%       - rateL
%       - rateR
%       - timestamps
%       - fs
%       - bursts Nx2

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        CONVERT  MULTI-UNIT ACTIVITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
standardArgs = dset_get_standard_args;
standardArgs = standardArgs.multiunit;

e = exp_load(edir, 'epochs', epoch);

[tt, loc] = load_exp_tt_anatomy(edir);

anat = unique(loc);
muDt = standardArgs.dt;

tbins = e.(epoch).et(1) : muDt : (e.(epoch).et(2)-muDt);

% fprintf('Loading Multiunit...');
anatomy_to_load = {'lCA1', 'rCA1'};

for a = 1:numel(anat)
    
    if all(cellfun( @isempty, strfind(anatomy_to_load, anat{a})))
%         fprintf(' skipping %s', anat{a});
        continue;
    end
    
    ind = ismember(loc,anat(a));
    
    %disp(['loading multi-unit rate from: ', anat{a}]);
    wave = load_exp_mu(edir, epoch, 'ignore_tetrode', tt(~ind));

    wave = histc(wave,tbins);
    mu.timestamps = tbins;

    if ~isempty(wave)
        %wave( wave>(mean(wave)+10*std(wave)))=mean(wave);
        mu.(anat{a}) = wave;
    else
        mu.(anat{a}) = nan;
    end
    
    mu.fs = muDt^-1;
end
fprintf('\t DONE!\n');

if isfield(mu, 'lCA1')
    mu.rateL = mu.lCA1;
    mu = rmfield(mu, 'lCA1');
else
    mu.rateL = 0 .* tbins;
end

if isfield(mu, 'rCA1')
    mu.rateR = mu.rCA1;
    mu = rmfield(mu, 'rCA1');
else
    mu.rateL = 0 .* tbins;
end

if isfield(mu, 'rCA3')
    mu = rmfield(mu, 'rCA3');   
end
if isfield(mu, 'lCA3')
    mu = rmfield(mu, 'lCA3');
end

muFs = 1/standardArgs.dt;


mu.rate = smoothn(mu.rateL + mu.rateR, standardArgs.smooth_dt, standardArgs.dt) .* muFs;
if nnz(mu.rateL) == 0
    mu.rateL = [];
else
   mu.rateL = smoothn(mu.rateL, standardArgs.smooth_dt, standardArgs.dt) .* muFs;
end

if nnz(mu.rateR) == 0
    mu.rateR = [];
else
    mu.rateR = smoothn(mu.rateR, standardArgs.smooth_dt, standardArgs.dt) .* muFs;
end



    
    
    
    
    