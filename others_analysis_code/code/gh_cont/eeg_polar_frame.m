function h = eeg_polar_frame(fg, phase_cdat, env_cdat, trode_st_dp, k, ktime, bout)
%

phase_data = phase_cdat.data;
env_data = env_cdat.data;
n_frames = size(phase_data);
ktime;
% env_data = env_cdat.data

if(or(max(max(phase_data)) > pi, min(min(phase_data)) < -pi))
%    error('Input data is out of range [0, 2*pi].  Is it phase data?');
end

%k
frame_phase_data = phase_data(k,:);
frame_env_data = env_data(k,:);

polar(0,20); hold on;

st_norm = (trode_st_dp(:,1) - min(trode_st_dp(:,1))) ./ (max(trode_st_dp(:,1)) - min(trode_st_dp(:,1)));

for n = 1:numel(frame_phase_data)
    %pp(frame_phase_data(n),frame_env_data(n),'-mo','CentreValue',0,'MaxValue',0.1);
    %if(n <= 6)
    % h = polar(frame_phase_data(n),-1*trode_st_dp(n,1),'-mo');
    %else
    % h = polar(frame_phase_data(n),-1*trode_st_dp(n,1),'-go');
    %end
% %     h = polar(frame_phase_data(n),20- trode_st_dp(n,1),'-mo'); %MOST POP
%      h = plot(cos(frame_phase_data(n))*(20-trode_st_dp(n,1)),...
%          sin(frame_phase_data(n))*(20-trode_st_dp(n,1)),'O',...
%          'MarkerFaceColor',[(-trode_st_dp(n,1)+max(trode_st_dp(:,1)))/max(trode_st_dp(:,1)), 0, 0]);
     
     h = plot(cos(frame_phase_data(n))*(trode_st_dp(n,2) + 4)*3,...
         sin(frame_phase_data(n))*(trode_st_dp(n,2) + 4)*3,'O',...
         'MarkerFaceColor',[st_norm(n), 0, 0],...
         'MarkerEdgeColor',[0 0 0],...
         'MarkerSize', frame_env_data(n)/0.01 + 1 );
     
     title(num2str(ktime));
     

        %  h = plot(cos(frame_phase_data(n))*3,...
        % sin(frame_phase_data(n))*3,'O',...
        % 'MarkerFaceColor',[st_norm(n), 0, 0],...
        % 'MarkerEdgeColor',[0 0 0],...
        % 'MarkerSize', frame_env_data(n)/max(frame_env_data)*20 + 1 );
     
%    polar(frame_phase_data(n),frame_env_data(n)*100,'-mo');
    if(n == 1)
 %       frame_phase_data(n)
    end
    hold on
end

hold off