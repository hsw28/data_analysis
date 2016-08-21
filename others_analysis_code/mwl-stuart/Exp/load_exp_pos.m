function pos = load_exp_pos(edir, ep, varargin)
% LOAD_EXP_POS(edir, ep)
%
% loads position from position.p and linear position from lin_pos.p
% if lin_pos.p doesn't exist the user will be prompted to do the
% necessary actions to create lin_pos.p
%
% depends upon PositionProcessing, MwlIO, and Utilties toolboxs

args.create_new_p_file = 0;
args = parseArgsLite(varargin,args);

if ~exist(fullfile(edir, [ep,'.lin_pos.p']), 'file') || args.create_new_p_file
    disp('No linear position file found, creating it');
     create_linear_position_file(edir, ep); 
end

pos = load_linear_position_file(edir, ep);

end

function create_linear_position_file(edir, ep)

    pos_file_path= fullfile(edir, 'position.p');
    pos_file = mwlopen(pos_file_path);

%     disp(['Loading position file: ',pos_file_path]);

    p = load(pos_file);
    ts = double(p.timestamp)/10000;
    [en et] = load_epochs('', 'epoch_file', fullfile(edir, 'epochs.def'));
    et = et(ismember(en, ep),:)

    ind(1) = find(ts>=et(1),1,'first');
    ind(2) = find(ts<=et(2),1,'last');
    ind = ind(1):ind(2);
   
    hp = calculate_head_pos(p.xfront(ind), p.yfront(ind), p.xback(ind), p.yback(ind));
    
    
    list = {'Linear', 'Circular', 'Spline', 'Complex'}; 
    n = track_selection(figure, hp, 'PromptString', 'Select a track type:', 'SelectionMode', 'Single', 'ListString', list);
    
    if isempty(n)
        error('No track selected');
    end
    
    [lin_pos nodes] = linearize_position(hp(:,1), hp(:,2), list{n}, 1);       
    
    vel = calculate_velocity(lin_pos, .5, 1/30);
    pos.lp = lin_pos;

    %pos.lv = filter_linear_velocity(vel); %<-- what does this do?
    pos.lv = vel;
    
    position.units = 'meters';

    data = prepare_data(ts(ind), pos.lp, pos.lv, hp(:,1), hp(:,2));
    save_linear_position(fullfile(edir, [ep, '.lin_pos.p']), data);      
        %save_linear_nodes(fullfile(edir, 'epochs', ep), nodes);
    cmd = ['touch ', fullfile(edir, ['meta.',ep,'.linearized_position'])];
    system(cmd);
     
end

function headpos = calculate_head_pos(xf, yf, xb, yb)
ind = xf==0 | xb==0 | yf ==0 | yb==0;

headpos(:,1) = mean([xf; xb]);
headpos(:,2) = mean([yf; yb]);

headpos(ind,:) = nan;
end

function pos = load_linear_position_file(edir, ep)  

    lin_pos_path = fullfile(edir, [ep,'.lin_pos.p']);
    f = mwlopen(lin_pos_path);

%     disp([ep, ': loading linear_position file:', lin_pos_path]);
    l = load(f);    
    pos.ts = l.timestamp;
    pos.lp = l.lp;
    pos.lv = l.lv;
    pos.xp = l.xp;
    pos.yp = l.yp;
    
    %position.nodes = load_linear_nodes(fullfile(edir, 'epochs', epochs_name));
%    disp(['Max Lin Pos:, ', num2str(max(l.lin_pos))]);
%    position.info = fullfile(edir, ep);
end
    
function data = prepare_data(ts, l, v, x, y)
    ts = reshape(ts, max(size(ts)), min(size(ts)));
    l = reshape(l, max(size(l)), min(size(l)));
    v = reshape(v, max(size(v)), min(size(v)));
    x = reshape(x, max(size(x)), min(size(x)));
    y = reshape(y, max(size(y)), min(size(y)));
        
    data = {ts, l, v,x,y};
end

function vel = filter_linear_velocity(vel)

    run_seg = logical2seg(vel~=0);
    run_ind = diff(run_seg, 1,2)<10;

    ind = run_seg(run_ind,:);
    for i=1:length(ind)
        vel(ind(i,1):ind(i,2)) = 0;
    end

end
