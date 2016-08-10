function b = ratsToDirs(ratDays)
% RATS takes a containers.Map of 
%  ({'rat1','rat2'},{ 'rat1day1','rat1day2'},{'rat2day1','rat2day2'}})
% And returns a list of full data directories

dataDir = '/home/greghale/Data';


rs = ratDays.keys;
b.days = cell(0);
for rInd = 1:numel(ratDays.keys)
    thisDays = ratDays(rs{rInd});
    b.days = [b.days, cmap(@(x) [dataDir,'/',rs{rInd},'/',x,'/'], thisDays)];
%    for d = 1:numel(b.days)
%        dir0 = pwd;
%        cd(b.days{d});
%        b.metadata = [b.metadata, metadata()];
%        cd(dir0);
%    end
end

