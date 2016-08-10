function [eventsCA1,eventsRSC,eventsCTX] = plotTwoMeans(k,trode_groups,areas,thresh)

%rateRSC = contchans_trode_group(d.mua_rate,d.trode_groups,'RSC');
%rateRSC.data = mean(rateRSC.data,2);
%rateCTX = contchans_trode_group(d.mua_rate,d.trode_groups,'CTX');
%rateCTX.data = mean(rateCTX.data,2);

%yl = [0,250];

% r = contchans_trode_group(k,d.trode_groups,'RSC');
% 
% c = contchans_trode_group(k,d.trode_groups,'CTX');
% 
% ax(1) = subplot(2,1,1);
% gh_plot_cont(contmap(@(x) smooth(mean(x,2),80),r));
% 
% ax(2) = subplot(2,1,2);
% gh_plot_cont(contmap(@(x) smooth(mean(x,2),80),c));
% 
% linkaxes(ax,'xy');

eventsCA1 = cell(0);
eventsRSC = cell(0);
eventsCTX = cell(0);

for n = 1:numel(areas)
   area = areas{n};
   ax(n) = subplot(numel(areas),1,n);
   kSub = contchans_trode_group(k,trode_groups,area);
   kSub = contmap(@(x) mean(x,2),kSub);
   if(strcmp(area,'CA1'))
       gh_plot_cont( kSub ); hold on;
       [events,~] = eegRipples( kSub,thresh.CA1, thresh.CA1/2, 0.03, 0.005, thresh.CA1*3/4,0.01);
       gh_draw_segs(events,'names',{'ripples'},'ys',{[0.2,0.25]});
       disp([num2str(numel(events)),' ripples']);
       eventsCA1 = events;
   end
   if(any(strcmp(area,{'CTX','RSC'})))
       devNSmooth  = 80;
       baseNSmooth = 1600;
       deviation = contmap(@(x) smooth(x,devNSmooth) - smooth(x,baseNSmooth),...
           kSub);
       gh_plot_cont( deviation ); hold on;
       [events,~] = find_dips_frames_by_lfp( kSub, thresh.(area));
       ylim([-0.01,0.02]);
       
       if(numel(events)>0)
            gh_draw_segs(events,'names',{'dips'},'ys',{[0.01,0.02]});
       end
       disp([num2str(numel(events)),' dips']);
       if(strcmp(area,'CTX'))
           eventsCTX = events;
       else
           eventsRSC = events;
       end
   end
   hold off;
end

linkaxes(ax,'x');

% ax(1) = subplot(2,1,1);
% find_dips_frames(d.mua_rate,d.eeg,'trode_groups',d.trode_groups,...
%     'area_for_threshold','RSC','draw',true,'mean_rate_threshold',-0.05,...
%     'min_width_pre_bridge',0.04,'k_env_override',k);
% 
% ax(2) = subplot(2,1,2);
% find_dips_frames(d.mua_rate,d.eeg,'trode_groups',d.trode_groups,...
%     'area_for_threshold','CTX','draw',true,'mean_rate_threshold',-0.05,...
%     'min_width_pre_bridge',0.04,'k_env_override',k);
% 
% linkaxes(ax,'xy');



% ts = conttimestamp(rateCTX);
% 
% ax(1) = subplot(2,1,1);
% gh_plot_cont(rateRSC);
% x = rateRSC.data;
% rateRSC.data = smooth(rateRSC.data,1600);
% pts = ts(rateRSC.data - x > (40));
% hold on;
% gh_plot_cont(rateRSC);
% plot(pts,ones(size(pts)),'.');
% ylim(yl);
% 
% ax(2) = subplot(2,1,2);
% gh_plot_cont(rateCTX);
% x = rateCTX.data;
% rateCTX.data = smooth(rateCTX.data,1600);
% pts = ts(rateCTX.data - x > (40));
% hold on;
% gh_plot_cont(rateCTX);
% plot(pts,ones(size(pts)),'.');
% ylim(yl);
% 
% linkaxes(ax,'x');
