function [betahat, r, J, COVB, mse] = plane_wave_regress_frame(sdat,rat_conv_table,varargin)

p = inputParser();
p.addParamValue('draw',false,@islogical);
p.addParamValue('report_ci',false,@islogical);
p.parse(varargin{:});


nchans = size(sdat.data,2);
nobs = size(sdat.data,1);

sdat.data = sdat.data + pi;

dp_ind = find(strcmp(rat_conv_table.label,'brain_dp'));
st_ind = find(strcmp(rat_conv_table.label,'brain_st'));
chan_name_ind = find(strcmp(rat_conv_table.label,'comp'));

pos_x = zeros(1,nchans);
pos_y = zeros(1,nchans);
for m = 1:nchans
    ind_into_conv_table = find(strcmp(sdat.chanlabels{m},rat_conv_table.data(chan_name_ind,:)));
    pos_x(m) = rat_conv_table.data{dp_ind,ind_into_conv_table};
    pos_y(m) = rat_conv_table.data{st_ind,ind_into_conv_table};
end

pos_x = repmat(pos_x,nobs,1);
pos_y = repmat(pos_y,nobs,1);

ts = conttimestamp(sdat);
ts_big = repmat(ts',1,nchans);

ts_big = reshape(ts_big,[],1);
pos_x = reshape(pos_x,[],1);
pos_y = reshape(pos_y,[],1);
data = reshape(sdat.data,[],1);

opt = {'Robust','on'};
X = [ts_big,pos_x,pos_y];
y = data;
b0 = plane_wave_guess_beta(sdat,rat_conv_table);
[betahat, r, J, COVB, mse] = gh_circ_nlinfit(X,y,@plane_wave_model,b0);
%ci = nlparci(betahat,r,'jacobian',J);

if(p.Results.draw)
    figure;
    x = linspace(min(pos_x)-1,max(pos_x)+1,50);
    y = linspace(min(pos_y)-1,max(pos_y)+1,50);
    [X,Y] = meshgrid(x,y);
    X = reshape(X,[],1);
    Y = reshape(Y,[],1);
    a=plot3(1,1,1,'r.');
    set(a,'MarkerSize',1);
    hold on
    b=plot3(1,1,1,'bO');
    for m = 1:nobs
        this_time = ts(m);
        z_model = plane_wave_model(betahat,[this_time*ones(size(X)),X,Y]);
        z_data = data(ts_big == this_time);
        x_data = pos_x(ts_big == this_time);
        y_data = pos_y(ts_big == this_time);
        set(a,'XData',X);
        set(a,'YData',Y);
        set(a,'ZData',z_model);
        %h=plot3(X,Y,z_model,'r.')
        set(a,'MarkerSize',1);
        %hold on
        set(b,'XData',x_data);
        set(b,'YData',y_data);
        set(b,'ZData',z_data);
        %plot3(x_data,y_data,z_data,'bO');
        %hold off
        xlabel('x');
        ylabel('y');
        zlim([0 2*pi]);
        title(num2str(ts(m)));
        pause(10/numel(ts));
    end
end

%ci

if(p.Results.report_ci)
    disp(['Freq: ', betahat(1),' +/- '])
end