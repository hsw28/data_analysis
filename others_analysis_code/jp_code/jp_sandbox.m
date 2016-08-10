%% Reset Matlab Environment & Specify data set to load
clear; clc;
animal = 'blue';
day = 032213;
epoch = 'sleep2';

%% Load Data from disk, group by region
[h.mua, c.mua] = jp_load_multiunit(animal, day, epoch, {'HPC', 'RSC'});
[h.eeg, c.eeg] = jp_load_eeg(animal, day, epoch, {'HPC', 'RSC'});


%% Detect Ripples and Ripple-Sets
ripTs = jp_detect_ripples(h.eeg, 7);
[setStart, setLen, setId] = groupEvents(ripTs, [.5 .25]);




%% Compute Ripple Triggered MU Rates
[hSamp, sampTs] = jp_calc_rip_trig_mu_rate(ripTs, h.mua, [-.25 .5]);
[cSamp, ~]      = jp_calc_rip_trig_mu_rate(ripTs, c.mua, [-.25 .5]);


%%

%Compute indices of ripples in sets of various lengths:
aIdx = setStart( setLen >= 1 ); % All ripples
sIdx = setStart( setLen == 1 ); % Singlet
dIdx = setStart( setLen >= 2 ); % Doublet +
tIdx = setStart( setLen >= 3 ); % Triplet +


close all;
figure; 
ax(1) = subplot(211);
ax(2) = subplot(212);

line(sampTs, mean( hSamp( aIdx,:) ), 'color', 'k', 'parent', ax(1));
line(sampTs, mean( hSamp( sIdx,:) ), 'color', 'r', 'parent', ax(1));
line(sampTs, mean( hSamp( dIdx,:) ), 'color', 'b', 'parent', ax(1));
line(sampTs, mean( hSamp( tIdx,:) ), 'color', 'g', 'parent', ax(1));


line(sampTs, mean( cSamp( aIdx,:) ), 'color', 'k', 'parent', ax(2));
line(sampTs, mean( cSamp( sIdx,:) ), 'color', 'r', 'parent', ax(2));
line(sampTs, mean( cSamp( dIdx,:) ), 'color', 'b', 'parent', ax(2));
line(sampTs, mean( cSamp( tIdx,:) ), 'color', 'g', 'parent', ax(2));

