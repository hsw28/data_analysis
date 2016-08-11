function d = swwDataSpec()

i = 0;

% A *normal* day
m = caillou_112812_metadata();

i = i + 1;
d{i}.mdata    = m;
d{i}.twin     = [4383,5829];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'run','normalPause'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [7900, 11800];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'sleep'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [2600,3000];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'sleep'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [3600,4000];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'sleep'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [6240,6800];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'drowsy'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;

% Another normal day (not a lot of place cells). HPC + RSC
m = caillou_121712_metadata();

i = i + 1;
d{i}.mdata    = m;
d{i}.twin     = [4640,5072];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'run','normalPause'};
d{i}.thresh.CA1 = 0.04;
d{i}.thresh.RSC = -0.005;

i = i + 1;
d{i}.mdata    = m;
d{i}.twin     = [5000,5900];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'drowsy'};
d{i}.thresh.CA1 = 0.04;
d{i}.thresh.RSC = -0.005;

i = i + 1;
d{i}.mdata    = m;
d{i}.twin     = [1900,2500];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'sleep'};
d{i}.thresh.CA1 = 0.04;
d{i}.thresh.RSC = -0.005;

i = i + 1;
d{i}.mdata    = m;
d{i}.twin     = [6642,7174];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'sleep'};
d{i}.thresh.CA1 = 0.04;
d{i}.thresh.RSC = -0.005;

% A night-track day. HPC and RSC
m = caillou_120912_metadata();

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [2354, 3264];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'run','nightPause'};
d{i}.thresh.CA1 = 0.05;
d{i}.thresh.RSC = -0.006;

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [6100, 6900];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'sleep'};
d{i}.thresh.CA1 = 0.05;
d{i}.thresh.RSC = -0.006;

% A night-track day. HPC and RSC
m = caillou_120712_metadata();

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [658, 1628];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'run','nightPause'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;

% Another night-track day. HPC and RSC
m = caillou_120812_metadata();

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [1247.0,2220.0];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'run','nightPause'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;

% Drowsy open field: HPC, RSC, CTX
m = blue_040513_metadata();

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [2000,4500];
d{i}.areas    = {'CA1','RSC','CTX'};
d{i}.sessions = {'drowsy'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;
d{i}.thresh.CTX = -0.003;

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [9542,9728];
d{i}.areas    = {'CA1','RSC','CTX'};
d{i}.sessions = {'sleep'};  % Short sleep bout
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;
d{i}.thresh.CTX = -0.004;

% Drowsy open field: HPC, RSC
m = blue_030313_metadata();

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [646.9410, 1813.4807];
d{i}.areas    = {'CA1','RSC'};
d{i}.sessions = {'run','nightPause'}; % 'night' here is 9pm. Didn't sleep post
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.005;

% Drowsy open field: HPC, RSC, CTX
m = blue_032813_metadata();

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [4512.0  5460.0];
d{i}.areas    = {'CA1','RSC','CTX'};
d{i}.sessions = {'run','normalPause'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.004;
d{i}.thresh.CTX = -0.004;

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [8120.0, 9260.0];
d{i}.areas    = {'CA1','RSC','CTX'};
d{i}.sessions = {'sleep'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;
d{i}.thresh.CTX = -0.004;

% Short sleep-only recording
m = blue_040213_metadata();

i = i+1;
d{i}.mdata    = m;
d{i}.twin     = [200,1833];
d{i}.areas    = {'CA1','RSC','CTX'};
d{i}.sessions = {'sleep'};
d{i}.thresh.CA1 = 0.075;
d{i}.thresh.RSC = -0.006;
d{i}.thresh.CTX = -0.004;


end