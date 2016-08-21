%% Load the data
exp = citrus;
name = 'citrus';
epochs = {'saline', 'midazolam'};

%% computer the correlation
clear corr lags dt coors cell_i cell_ind
dt = .005;

for e=1:numel(epochs)
    ep = epochs{e};
    
    cn  =0;
    cell_i= [];
    clear corr;
    for i = 1:numel(exp.(ep).clusters)
        %disp([ep, ' ', num2str(i)]);
        cell = exp.(ep).clusters(i);
        tc = cell.tc1 + cell.tc2;
        si = spatialinfo(tc);
        if numel(cell.time)<10000 && si>.5
            cn  = cn + 1;
            st = histc(cell.time, min(cell.time):dt:(max(cell.time)));
            
            [c lags] = xcorr(st, st, 100);
            corr(cn,:) = c;
            cell_i(cn) = i;
        end
    end
    
    cor.(ep) = corr;
    
    cell_ind.(ep) = cell_i;
    
end

%% Compute the CSI of each spike by epoch
clear clust ind ep path tt cl w2 sh st score
for e=1:numel(epochs)
    ep = epochs{e};
    disp(ep);
    clust = exp.(ep).clusters;
    ind = cell_ind.(ep);
    clear score;
    for i=1:numel(ind)

        path = clust(ind(i)).path;
        tt = fullfile(path, clust(ind(i)).ttfile);
        cl = fullfile(path, clust(ind(i)).clfile);
        [w2 sh] = load_waveforms(tt, cl);
        st = clust(ind(i)).time;
        score(i) = csi(st', sh);
    end
    c.(ep) = score;
        
end
disp('done');
%% Plot the CSI by epoch
sal = c.saline;
mid = c.midazolam;

m_sal = mean(sal);
m_mid = mean(mid);

s_sal = std(sal)/sqrt(numel(sal));
s_mid = std(mid)/sqrt(numel(mid));

figure;
barerrorbar([1 2], [m_sal m_mid], 3*[s_sal s_mid], {'FaceColor', 'r'}, {'Color', 'k', 'LineStyle', 'none'});

set(gca,'XLim', [.5 2.5], 'XTick', [1 2], 'XTickLabel', {'saline', 'midazolam'});
title(name);
ylabel('CSI');




%% integrate the acorr from 80 ms to 180 ms (a single theta cycle)
clear sal mid sal_sum mid_sum m_sal m_mid s_sal s_mid
ind = abs(lags*dt)<=.18 & abs(lags*dt)>.08;

sal = cor.saline;
mid = cor.midazolam;

sal(:,~ind) = 0;
mid(:,~ind) = 0;

sal_sum = sum(sal,2);
mid_sum = sum(mid,2);

m_sal = mean(sal_sum);
m_mid = mean(mid_sum);

s_sal = std(sal_sum)/sqrt(numel(sal_sum));
s_mid = std(mid_sum)/sqrt(numel(mid_sum));
figure; 
barerrorbar([1 2], [m_sal m_mid], 3*[s_sal s_mid], {'FaceColor', 'r'}, {'Color', 'k', 'LineStyle', 'none'});

set(gca,'XLim', [.5 2.5], 'XTick', [1 2], 'XTickLabel', {'saline', 'midazolam'});
title(name);
ylabel('Area of 1st theta acorr peak');
