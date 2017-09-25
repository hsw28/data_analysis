function f = randomunits(time, numofunits)
%makes fake unit data, enter time and number of units you want

f = sort(datasample(time, numofunits, 'Replace',false));
