function [rs,angs] = gh_amps_to_angs(amps)
amps = amps';
rs = sqrt(amps(1,:).^2 + amps(2,:).^2 + amps(3,:).^2 + amps(4,:).^2);
ang1 = atan( sqrt( amps(4,:).^2 + amps(3,:).^2 + amps(2,:).^2) ./ amps(1,:) );
ang2 = atan( sqrt( amps(4,:).^2 + amps(3,:).^2) ./ amps(2,:) ) - 3*pi/8;
ang3 = atan(amps(4,:) ./ amps(3,:)) - pi/4;
angs = [ang1;ang2;ang3];
angs = angs - repmat( mean(angs,2), 1, numel(rs));

keep_log1 = angs(1,:) >= -1 & angs(1,:) <= 1;
keep_log2 = angs(2,:) >= -1 & angs(2,:) <= 1;
keep_log3 = angs(3,:) >= -1 & angs(3,:) <= 1;

keep_log = min([keep_log1; keep_log2; keep_log3],[],1);
rs = rs(keep_log);
angs = angs(:,keep_log);

angs = angs';