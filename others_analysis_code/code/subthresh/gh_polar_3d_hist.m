function [counts, bin_centers_rs, bin_centers_ang] = gh_polar_3d_hist(rs,angs,varargin)

p = inputParser();
p.addParamValue('n_ang_bins',20);
p.addParamValue('ang_limits',[-1,1]);
p.addParamValue('n_rs_bins', 50);
p.addParamValue('rs_limits',[0, 3000]);
p.addParamValue('rs_smooth', 100);
p.parse(varargin{:});
opt = p.Results;

ang_bin_edges = linspace(opt.ang_limits(1), opt.ang_limits(2), opt.n_ang_bins);
rs_bins =  linspace(opt.rs_limits(1),  opt.rs_limits(2),  opt.n_rs_bins);
[ ANG1,ANG2,ANG3] = ndgrid( ang_bin_edges, ang_bin_edges, ang_bin_edges );

ANG1 = reshape(ANG1, 1, []);
ANG2 = reshape(ANG2, 1, []);
ANG3 = reshape(ANG3, 1, []);
n_ang_bins = numel(ang_bin_edges);
n_ang_bins_multidim = numel(ANG1);

%hist_counts = zeros(n_rs_bins, n_ang_bins_multidim);

%scatter3(ANG1,ANG2,ANG3,(30-15*sqrt(abs(ANG1).^2+abs(ANG2).^2+abs(ANG3).^2)), (30-8*(abs(ANG1)+abs(ANG2)+abs(ANG3))),'filled');

keep_log = rs > 650;
scatter3(angs(keep_log,1),angs(keep_log,2),angs(keep_log,3), abs(rs(keep_log)./100-3), abs(rs(keep_log)./100-100).^0.5,'filled');

a1_r = [0.20 0.36]; a2_r = [0.1 0.16]; a3_r = [0.32 0.44];
keep_log = (angs(:,1) >= a1_r(1) & angs(:,1) <= a1_r(2)) & (angs(:,2) >= a2_r(1) & angs(:,2) <= a2_r(2)) & (angs(:,3) >= a3_r(1) & angs(:,3) <= a3_r(2));

val = rs;
[counts1,inds1] = histc(angs(:,1),ang_bin_edges);
[counts2,inds2] = histc(angs(:,2),ang_bin_edges);
[counts3,inds3] = histc(angs(:,3),ang_bin_edges);
subs = [inds1, inds2, inds3];

A = accumarray(subs, val,[n_ang_bins, n_ang_bins, n_ang_bins],@(x)lfun_bimodalness(x));
B = A;
cutoff = 20000;
A(A > cutoff) = 0.1;
keep_log = reshape(A,1,[]) > 1;
A = reshape(A,1,[]);
figure;scatter3(ANG1(keep_log),ANG2(keep_log),ANG3(keep_log),10*(A(keep_log)),(A(keep_log)),'filled');

figure;
B = smooth3(B,'gaussian',[11 11 11], 0.75);
p1 = patch(isosurface(B,0.3),'FaceColor','blue','EdgeColor','none');
p2 = patch(isocaps(B,0.3),'FaceColor','blue','EdgeColor','none');
isonormals(B,p1);
view(3); axis vis3d tight
camlight; lighting phong

%bimodal_score = lfun_bimodalness(rs(keep_log));

counts = 1; bin_centers_rs = 1; bin_centers_ang = 1;



function bimodal_score = lfun_bimodalness(rs)

if(isempty(rs))
    bimodal_score = 0;
    return;
end

kern_sd_rs = 200;
kern_n_sd = 2;

hist_bin_edges = linspace(0,4000,200);
hist_bin_centers = mean([hist_bin_edges(2:end) ; hist_bin_edges(1:(end-1))]);
hist_bin_width = hist_bin_edges(2)-hist_bin_edges(1);

kern_n_samps = kern_n_sd * kern_sd_rs / hist_bin_width;
kern_x = linspace((-4*kern_sd_rs),(4*kern_sd_rs),ceil(kern_n_samps));
kern_y = exp(-1.*(((kern_x)).^2)./(2*(kern_sd_rs^2)));
kern_y = kern_y ./ sum(kern_y);  % normalize to 1

counts1 = histc(rs,hist_bin_edges);
counts1 = counts1(1:(end-1));
counts2 = conv(counts1,kern_y,'same');
counts3 = conv(counts2,kern_y,'same'); % double-smooth, make sure got all the lumps out
%figure; plot(hist_bin_centers, counts1); hold on;
%plot(hist_bin_centers, counts2,'g');
%plot(hist_bin_centers, counts3,'r');

if(~(all(size(counts3) == [1 199])))
%    disp ('stop_point.');
    counts3 = counts3';
end

local_min_inds = [false, (diff(diff(counts3) <= 0) < 0)];
local_max_inds = [false, (diff(diff(counts3) <= 0) > 0)];

if((sum(local_max_inds)==0) || (sum(local_min_inds) == 0))
    bimodal_score = 0;
    return;
end
local_mins = counts3(local_min_inds);
local_maxs = counts3(local_max_inds);
%plot(hist_bin_centers(local_min_inds),local_mins,'b.');
%plot(hist_bin_centers(local_max_inds),local_maxs,'r.');

local_min_min_rs = 200;

local_min_inds( hist_bin_centers < local_min_min_rs ) = 0;
local_min_ind = find(local_min_inds,1,'first');
if(isempty(local_min_ind))
    bimodal_score = 0;
    return;
end
local_max_inds( hist_bin_centers < hist_bin_centers(local_min_ind) ) = 0;
local_max_ind = find(local_max_inds,1,'first');
if(isempty(local_max_ind))
    bimodal_score = 0;
    return;
end
    
bimodal_score = counts3(local_max_ind) - counts3(local_min_ind);



