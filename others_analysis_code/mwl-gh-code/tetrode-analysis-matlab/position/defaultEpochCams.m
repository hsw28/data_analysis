function epochCams = defaultEpochCams()
% epochCams = defaultEpochCams map from epochs to cameras

epochCams = containers.Map();

epochCams('sleep1') = 'sleepBox';
epochCams('run')    = 'trackA';
epochCams('sleep2') = 'sleepBox';

epochCams('run1')   = 'trackA';
epochCams('sleep3') = 'sleeppBox';
epochCams('run2')   = 'trackB';