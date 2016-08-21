function [A,W,ica_settings] = process_eeg_ica( data, ncomp )
%PROCESS_EEG_ICA independent component analysis of eeg signals (for
%  artefact removal)
%
%  Syntax
%
%      process_eeg_ica( eeg )
%
%  Description
%
%



% set ica parameters
ica_settings = {'g', 'tanh', 'samplesize', 1, 'epsilon', 0.0001, 'approach', 'symm', 'stabilization', 'on', 'maxnumiterations', 200};

if nargin>1 && ~isempty(ncomp) 
    if ncomp<1 %ncomp specifies the fraction of eigenvalues to keep
        %calculate eigenvalues
        covarianceMatrix = cov(data, 1);
        [E, D] = eig (covarianceMatrix);
        eigenvalues = flipud(sort(diag(D)));
        %normalize eigenvalues
        eig_norm = cumsum(eigenvalues)/sum(eigenvalues);
        %determine the number of eigenvalues to keep
        lastEig = find(eig_norm>ncomp,1);
        ica_settings(end+1:end+2) = {'lasteig', lastEig};
    elseif ncomp>=1 && ncomp<=size(data,2)
        ica_settings(end+1:end+2) = {'lasteig', fix(ncomp)};
    end
end

% run ica
[A, W] = fastica( data', ica_settings{:} );
ica_settings = struct( ica_settings{:} );

return

% ica is perfomed per file, since we can't garantee perfect synchronization
% across files
for k=1:numel(eeg.files)
    
    % open file
    f = mwlopen( eeg.files(k).filename );
    
    % load all eeg data
    data = load(f, 'all');
    
    % prepare data
    t = data.timestamp;
    data = rmfield( data, 'timestamp');
    data = struct2cell( data );
    data = double( horzcat( data{:} ) );
        
    if isfield( eeg.files(k), 'clip') && ~isempty(eeg.files(k).clip)
        
        fprintf('Removing clipped samples...\n');
        
        invalid_seg = seg_or( eeg.files(k).clip{:} );
        valid_seg = seg_not( invalid_seg, 'Limits', [t(1) t(end)] );
    
        [dummy, valid_idx] = seg_select( valid_seg, t, 'all' );
        valid_idx = valid_idx{1};
    
    else
        
        valid_idx = 1:numel(t);
        
    end
        
    % set ica parameters
    ica_settings = {'g', 'tanh', 'samplesize', 1, 'epsilon', 0.0001, 'approach', 'symm', 'stabilization', 'on', 'maxnumiterations', 100};
    
    % run ica
    [eeg.files(k).ica.A, eeg.files(k).ica.W] = fastica( data(valid_idx,:)', ica_settings{:} );
    
    eeg.files(k).ica.settings = struct( ica_settings{:} );
     
    %components
    C = (eeg.files(k).ica.W*data')';
    
    nC = size(C,2);

    %plot spectrograms
    h = axismatrix( nC, 1, 'YSpacing', 0.01);
    nFFT = 2.^ceil(log2( eeg.files(k).rate));

    for l=1:nC
        axes( h(l) );
        specgram( C(:,l), nFFT, eeg.files(k).rate, hanning(nFFT), 0.5*nFFT );
    end

    clear f


    %ask for component numbers which represent artefacts
    eeg.files(k).ica.artefacts = str2num( input( 'Artefact component numbers: ', 's' ) );
    mask = ones(size(eeg.files(k).ica.A)); mask(:,eeg.files(k).ica.artefacts) = 0;
    weights = ( eeg.files(k).ica.A.*mask )*eeg.files(k).ica.W;
    eval( 'eeg.files(k).ica.deartefact = @(x) ( weights * x'' )'';'); %we have to use eval, otherwise the anonymous function captures everything in the current context!
    
    delete(gcf);   
    
end
