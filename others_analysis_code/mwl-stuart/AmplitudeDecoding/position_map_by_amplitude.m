%%
exp = exp15;
ep = 'run';
    
if isfield('position', exp.(ep))
    pos = exp.(ep).position.lin_pos;
    vel = exp.(ep).position.lin_vel;
    pts = exp.(ep).position.timestamp;
else
    pos = exp.(ep).pos.lp;
    vel = exp.(ep).pos.lv;
    pts = exp.(ep).pos.ts;
end

i = 1;
while isnan(pos(1))
    pos(1) = pos(i);
    i = i+1;
end
    
while any(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end
%%
% plot Amp PDF by channel

cols = [...
    1 1 1 1; ...
    1 1 1 0; ...
    1 1 0 1; ...
    1 0 1 1; ...
    0 1 1 1; ...
    1 1 0 0; ...
    1 0 1 0; ...
    1 0 0 1; ...
    0 1 1 0; ...
    0 1 0 1; ...
    0 0 1 1; ...
    1 0 0 0; ...
    0 1 0 0; ...
    0 0 1 0; ...
    0 0 0 1; ...
    ];
%%
cols = [1 0 0 0 ];

a = amps15;
for i=1:numel(a)
    a{i}(:,1:4) = bsxfun(@times, a{i}(:,1:4), cols);
end
%%

%%

et = exp15.run.et;
est = {};
range = 30:1:300;
%%
dp = .05;
clear bla est p;
for i=1:numel(a)
    [bla,bla,bla, p] = decode_amplitudes(a(i), pos', et, [], 'do_decoding', 0, 'pos_bw', dp);
    for j = 1:numel(range)
        tr = cols *  range(j);
        warning off;
        est{i}(j,:) = p.decode(tr,.01);
        warning on;
    end
end


%%
pbins = 0:dp:3.1;

clear pdf;
est2 = est([1:9,11:17]);
figure; 
clear ax;
for i = 1:numel(est2)
    dx = .25;
    dy = .25;
    ax(i) = axes('Position', [floor((i-1)/4)*dx+.06 mod(i,4)*dy+.04 dx-.08 dy-.04]);
    e = est2{i}';
    pdf(:,:,1) = e;
    %pdf(:,:,2) = e;
    %pdf(:,:,3) = e;
    pdf(isnan(pdf)) = 0;
    %pdf = 1-pdf;
    imagesc(pbins, range, pdf, 'Parent', ax(i));
    set(gca,'YDir', 'normal', 'XTick', [], 'YTick', []);
%     ylabel('Position');
%     xlabel('Spike Amplitude');
%     title(num2str(i));

end

set(ax(4), 'XTick', 0:.5:3, 'YTick', [0:100:300])

%%
pbins = 0:dp:3.1;

clear pdf;
est2 = est([1:9,11:17]);
figure; 
clear ax;
count = 0;
im = [];
for i = 1:numel(est2)
    count = count +1;
    e = est2{i};
    if count == 1
            row = e;
    else
        row = [row, e];
    end
    if count ==4
            if isempty(im)
                im = row;
            else
                im = [im; row];
            end
            count =0;
    end
end








