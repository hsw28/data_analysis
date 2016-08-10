function test_get_fields()

% Two peaks that don't split in half ...
aRate = ...
 [0 0 0 0.5 0.5 1 5 11 12 7 20 15 12 4 1.1 0 0 0 0 0];
aFields = get_fields(toSimpleCdat(aRate));
assert (size(aFields,2) == 2);

% Three peaks that split, last two rejoin
bRate = [0 0 0 0 1 9 1 12 2 12 12 1 0 0 0 0 0 0 0 0 ];
bFields = get_fields(toSimpleCdat(bRate));
assert(size(bFields,2) == 4);

disp('passed');
end

function c = toSimpleCdat(fRate)

theFieldBins = linspace(0,3.6,100);
theFieldRates = zeros(size(theFieldBins));
theFieldRates(20:(20+numel(fRate) - 1)) = fRate;

theCell.name = 'test-cell-cl2';
theCell.field.bin_centers = theFieldBins;
theCell.field.out_rate    = theFieldRates;
theCell.field.in_rate     = theFieldRates;

c.name = 'spikes';
c.userdata = [];
c.clust{1} = theCell;

end