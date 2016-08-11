%% Plot lin position and theta signal from a tetrode
figure;
plot(conttimestamp(pos.lin_filt),pos.lin_filt.data);
pos_axis = gca;
figure;
plot(conttimestamp(mua_theta),mua_theta.data(:,1));
theta_axis = gca;

%% Plot a subset of the raw data

%this_bout = [3900 4000];
this_bout = [7000 7050];
this_dat = contwin(eeg,this_bout);
for i = [1,2,3,4,5,6]
    plot(conttimestamp(this_dat),this_dat.data(:,i)-0.4*i);
    hold on
end
for i = [7,8,9,10,11,12]
    plot(conttimestamp(this_dat),this_dat.data(:,13-(i-6))-0.4*i,'r');
    hold on
end

%% zoom into interesting 1-2 second window
interesting_bouts = [2728 2729;...   %first one I looked at.  Pretty nice ap wave Outbound
    3872 3873;... % pre good-run, big lateral phase offset Inbound
    3873 3874; ...  % interesting spike in power about mid-way. Crappy waves Inbound
    3874 3876; ...  % high-power theta.  some ok ap wave, some nice lat wave, maybe a little p-a wave? Indound
    3879.5 3881.5; ... % very confusing - ap on one row, pa on the other? Inbound
    3923 3925; ... % soso
    3929 3931; ... % no apparent regular phase offsets?
    3992 3993; ...  % pretty!  Reverse directions on the two rows?
    3993 3995]; 


%this_bout = interesting_bouts(8,:);
this_bout = [876 877];
%set(pos_axis,'XLim',this_bout); 
%set(theta_axis,'XLim',this_bout);
trodexy = mk_trodexy(eeg_theta,exactamundo_rat_conv_table);
userdata.trodexy = trodexy;
mvopt = mkmovopt('cdat',eeg_theta,'movtype','eeg_3d','bouts',this_bout,...
    'framerate',20,'timecompression',0.1,'userdata',userdata,...
    'makeavi',true,'concatavi',false);
mvopt.bouts = this_bout;
mkmov(eeg_theta,mvopt);