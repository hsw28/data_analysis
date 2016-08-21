function seg_demo()
%SEG_DEMO demonstration of segment operations
%
%  SEG_DEMO demonstrates logical operations on and plotting of segments.
%

%  Copyright 2005-2008 Fabian Kloosterman

s1 = [0 1; 4 7; 9 12; 15 20; 25 27];
s2 = [2 3; 6 10; 11 13; 22 30];

sand = seg_and(s1,s2);
sor = seg_or(s1,s2);
sxor = seg_xor(s1,s2);
snot = seg_not(s1,s2);
sexcl1 = seg_excl(s1,s2);
sexcl2 = seg_excl(s2,s1);

figure;
seg_plot( {s1 s2 sand sor sxor snot sexcl1 sexcl2}, 'Height', 0.6, 'YOffset', [0 1 2 3 4 5 6 7]+0.2 , 'FaceColor', [1 0 0; 0 1 0; 1 1 0; 0 0 1; 0 1 1; 1 0 1; 0.5 0.5 0.5; 0.5 0.5 0.5]);

text(16,0.5,'segment list 1');
text(16,1.5,'segment list 2');
text(16,2.5,'SEG\_AND (s1,s2)');
text(16,3.5,'SEG\_OR (s1,s2)');
text(16,4.5,'SEG\_XOR (s1,s2)');
text(16,5.5,'SEG\_NOT (s1,s2)');
text(16,6.5,'SEG\_EXCL (s1,s2)');
text(16,7.5,'SEG\_EXCL (s2,s1)');

set(gca, 'YTickLabel', []);
xlabel('time (s)');
title('Demonstration of logical operations on segments')
