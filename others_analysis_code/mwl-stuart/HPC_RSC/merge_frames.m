function F = merge_frames(f, dt)

ifi = f';
ifi = ifi(:);
ifi = diff(ifi);
ifi = ifi(2:2:end);

mergeIdx = find(ifi < dt);

FS = f(:,1);
FE = f(:,2);

FS(mergeIdx+1) = nan;
FE(mergeIdx) = nan;

F = [FS; FE];
F = F(~isnan(F));


F = reshape(F, numel(F)/2, 2);


end