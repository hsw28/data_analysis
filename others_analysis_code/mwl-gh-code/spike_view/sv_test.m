% init stuff
%cd JK/092708
%sdat = imspike('spikes');
%eeg1 = imcont('eegfile','j27.eeg','chans',[1:6]);
%eeg2 = imcont('eegfile','k27.eeg','chans',[1:6]);
%eeg1.data = double(eeg1.data);
%eeg1 = contresamp(eeg1,'resample',0.1);
%eeg2.data = double(eeg2.data);
%eeg2 = contresamp(eeg2,'resample',0.1);
%eeg = contcombine(eeg1,eeg2);
%eeg.data = double(eeg.data)
%eeg = contresample(eeg,'resample',1000/eeg.samplerate);
%clear eeg1;
%clear eeg2;

%pos = linearize_track('l27.p','timewin_guide',true);

%fopt = filtoptdefs();
%theta_fo = fopt.theta;
%theta_fo.Fs = eeg.samplerate;
%theta_filt = mkfilt('filtopt',theta_fo);
%eeg_theta = contfilt(eeg,'filt',theta_filt);
%eeg_phale = multicontphase(eeg);


%f = spike_view(sdat,eeg_theta_phase,pos);
f = spike_view(sdat2,theta_phase,pos);
sv_add_pos(f);
sv_add_clust(f,6,[1 0 0]);
%sv_add_clust(f,27,[0 1 0]);

sv_add_cdat(f,1,[0.5 0.5 0]);