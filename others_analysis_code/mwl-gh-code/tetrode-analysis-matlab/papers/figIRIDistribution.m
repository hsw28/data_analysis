function r = figIRIDistribution(rats)

r0.sleep1 = [];
r0.run    = [];
r0.sleep2 = [];

r = mapReduce(r0,@getDayISI,@reduceISI,rats.days);

%hist(r,100);

function r1 = getDayISI(dayDir)
dir0 = pwd();
cd(dayDir);
m = metadata();
d = loadDataGeneric(m,'loadMUA',false,'loadSpikes',false);
d.eeg = eegByArea(d.eeg,m.trode_groups,'CA1');
for e = {'sleep1','run','sleep2'}
    [~,~,eeg_ripple_env] = ...
        gh_ripple_filt(d.eeg,'timewin',d.epochs(e{1}));
    env = eeg_ripple_env;
    env.data = mean(env.data,2);
    [~,ripplePeaks] = ...
        eegRipples(env, 0.075, 0.025, 0.01, 0.005, 0.05, 0.005);
    r1.(e{1}) = diff(reshape(ripplePeaks,1,[]));
end
cd(dir0);


function r = reduceISI(r0,r1)
for e = {'sleep1','run','sleep2'}
    r.(e{1}) = [r0.(e{1}), r1.(e{1})];
end