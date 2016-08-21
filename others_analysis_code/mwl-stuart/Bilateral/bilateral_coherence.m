
exp11 = exp_load('/data/spl11/day11', 'epochs', 'run', 'data_types', {'eeg', 'pos'});
exp11 = process_loaded_exp(exp11, 'operations', 8);
%%

velThold = .15;
eeg = exp11.run.eeg;
pos = exp11.run.pos;


lInd = find(strcmp(eeg.loc, 'lCA1'));
rInd = find(strcmp(eeg.loc, 'rCA1'));
%%
isMoving = abs(pos.lv)>velThold;
eegMoving = interp1(pos.ts, isMoving, eeg.ts, 'nearest');
eegMoving(isnan(eegMoving))=0;
eegMoving=logical(eegMoving);

%%
rippleFilter = getFilter(eeg.fs, 'ripple', 'win');
thetaFilter = getFilter(eeg.fs, 'theta', 'win');
gammaFilter = getFilter(eeg.fs, 'gamma', 'win');
eeg.ripple = filtfilt(rippleFilter, 1,eeg.data');
eeg.ripEnv = abs(hilbert(eeg.ripEnv));
%eeg.theta = filtfilt(thetaFilter, 1, eeg.data');
%eeg.gamma = filtfilt(gammaFilter, 1, eeg.data');

%%  Compare the correalation in the ripple band for all time periods

nChan = size(eeg.ripple,2);
c.all = ones(nChan);
c.run = ones(nChan);
c.stop = ones(nChan);


for i=1:size(eeg.ripple,2)
    for j=1:size(eeg.ripple,2)
        disp([i, j]);
        c.all(i,j) = corr(eeg.ripple(:,i), eeg.ripple(:,j));
        c.run(i,j) = corr(eeg.ripple(eegMoving,i), eeg.ripple(eegMoving, j));
        c.stop(i,j) = corr(eeg.ripple(~eegMoving,i), eeg.ripple(~eegMoving,j));
    end
end

figure; 
subplot(311); title('All'); imagesc(c.all); 
subplot(312); title('Run'); imagesc(c.run); 
subplot(313); title('Stop'); imagesc(c.stop);
%%
% nChan = size(eeg.theta,2);
% c.all = ones(nChan);
% c.run = ones(nChan);
% c.stop = ones(nChan);
% 
% 
% for i=1:nChan
%     for j=1:nChan
%         disp([i, j]);
%         c.all(i,j) = corr(eeg.theta(:,i), eeg.theta(:,j));
%         c.run(i,j) = corr(eeg.theta(eegMoving,i), eeg.theta(eegMoving, j));
%         c.stop(i,j) = corr(eeg.theta(~eegMoving,i), eeg.theta(~eegMoving,j));
%     end
% end
% 
% figure; 
% subplot(311); title('All'); imagesc(c.all); 
% subplot(312); title('Run'); imagesc(c.run); 
% subplot(313); title('Stop'); imagesc(c.stop);
%%
% nChan = size(eeg.gamma,2);
% c.all = ones(nChan);
% c.run = ones(nChan);
% c.stop = ones(nChan);
% 
% 
% for i=1:nChan
%     for j=1:nChan
%         disp([i, j]);
%         c.all(i,j) = corr(eeg.gamma(:,i), eeg.gamma(:,j));
%         c.run(i,j) = corr(eeg.gamma(eegMoving,i), eeg.gamma(eegMoving, j));
%         c.stop(i,j) = corr(eeg.gamma(~eegMoving,i), eeg.gamma(~eegMoving,j));
%     end
% end
% 
% figure; 
% subplot(311); title('All'); imagesc(c.all); 
% subplot(312); title('Run'); imagesc(c.run); 
% subplot(313); title('Stop'); imagesc(c.stop);
%% Xcorr the ripples themselves
for i=1:nChan
    rippEnv = abs(hilbert(eeg.ripple(:,i)));
    m = mean(rippEnv);
    s = std(rippEnv);
    eeg.rippTh(:,i) = ((rippEnv-m)/s)>3;
end
%%
lags = 25;
xc = zeros(lags*2+1,nChan);
count = 0;
for i=1:size(eeg.ripple,2)
    for j=1:size(eeg.ripple,2)
        disp(count);
        count=count+1;
        xc(:,count) = xcorr(eeg.rippTh(:,i)', eeg.rippTh(:,j)',lags);        
    end
end
xc = xc';
%% Compute PSTH of other EEG channels using a single channel!
rippleTimes = cell(1,nChan);
rippleStart = cell(1,nChan);
rippleStop  = cell(1,nChan);
for i=1:nChan
    d = diff(eeg.rippTh(:,i));
    rippleTimes{i} = eeg.ts(eeg.rippTh(:,i));
    rippleStart{i} = eeg.ts(find(d==1)+1);
    rippleStop{i} =  eeg.ts(find(d==-1)+1);
end
ps = {};
%%
for i=1:nChan
    idx = logical(1:nChan);
    idx(i) = 0;
    ps{i} = psth(rippleTimes{i}, rippleTimes(idx));
end

%%
rippPsth = [];
for i=1:nChan
    for j=1:nChan
        if j==i
            continue
        end
    disp([i j]);
    rippPsth(:,end+1) = mean(psth(rippleTimes{i}, rippleStart{j}, 1/500, 20));
    end
end
%%
ll = [];
lr = [];
rl = [];
rr = [];
count = 0;
for i=1:nChan
    for j=1:nChan
        if j==i
            continue
        end
        count = count+1;
        [i, j, count]
        if strcmp(eeg.loc{i}, 'lCA1')
            if strcmp(eeg.loc{j}, 'lCA1') % LL
                ll(:,end+1) = rippPsth(:,count);
            else % LR
                lr(:,end+1) = rippPsth(:,count);
            end
        else
            if strcmp(eeg.loc{j}, 'lCA1') %RL
                rl(:,end+1) = rippPsth(:,count);
            else % RR
                rr(:,end+1) = rippPsth(:,count);
            end
        end
    end
end
%%
        counts1 = psth(rippleTimes{2}, rippleStart{2}, 1/250, 20);

counts2 = EventTrigHist(rippleStop{2}, rippleTimes{2}, 1/750, .05, .05);

%%
ll = [];
lr = [];
rl = [];
rr = [];
count = 0;
for i=1:nChan
    for j=1:nChan
        count = count+1;
        [i, j, count]
        if strcmp(eeg.loc{i}, 'lCA1')
            if strcmp(eeg.loc{j}, 'lCA1') % LL
                ll(:,end+1) = xc(:,count);
            else % LR
                lr(:,end+1) = xc(:,count);
            end
        else
            if strcmp(eeg.loc{j}, 'lCA1') %RL
                rl(:,end+1) = xc(:,count);
            else % RR
                rr(:,end+1) = xc(:,count);
            end
        end
    end
end
%%
figure;
subplot(221); imagesc(ll');title('ll');
subplot(222); imagesc(lr');title('lr');
subplot(223); imagesc(rr');title('rr');
subplot(224); imagesc(rl');title('rl');
%%
eeg.env = abs(hilbert(eeg.ripple));

nChan = size(eeg.ripple,2);
c.all = ones(nChan);
c.run = ones(nChan);
c.stop = ones(nChan);

for i=1:size(eeg.ripple,2)
    for j=1:size(eeg.ripple,2)
        disp([i, j]);
        c.all(i,j) = corr(eeg.env(:,i), eeg.env(:,j));
        c.run(i,j) = corr(eeg.env(eegMoving,i), eeg.env(eegMoving, j));
        c.stop(i,j) = corr(eeg.env(~eegMoving,i), eeg.env(~eegMoving,j));
    end
end    

figure; 
subplot(311); title('All'); imagesc(c.all); 
subplot(312); title('Run'); imagesc(c.run); 
subplot(313); title('Stop'); imagesc(c.stop);
%%


%%


theta.filter = getfilter(eeg.fs, 'theta', 'win');

theta.left = filtfilt(theta.filter, 1, eeg.data(lCh,:));
theta.right =filtfilt(theta.filter, 1, eeg.data(rCh,:));

env.left = abs(hilbert(theta.left));
env.right = abs(hilbert(theta.right));





