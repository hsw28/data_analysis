function y = deltafilt(x)
%DELTAFILT Filters input x and returns output y.

% MATLAB Code

% lowpass filters in delta frequency range 0-4. import eeg data from gh_debuffer
% example: 
% data = deltafilt(lfp.data);

persistent Hd;

if isempty(Hd)
    
    % The following code was used to design the filter coefficients:
    % % FIR Window Lowpass filter designed using the FIR1 function.
    %
    % % All frequency values are in Hz.
    % Fs = 2000;  % Sampling Frequency
    %
    % N    = 500;      % Order
    % Fc   = 4;        % Cutoff Frequency
    % flag = 'scale';  % Sampling Flag
    %
    % % Create the window vector for the design algorithm.
    % win = blackman(N+1);
    %
    % % Calculate the coefficients using the FIR1 function.
    % b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
    
    Hd = dsp.FIRFilter( ...
        'Numerator', [0 3.18714260155108e-10 2.56023087856813e-09 ...
        8.67709219765811e-09 2.0655958171351e-08 4.05194794411783e-08 ...
        7.0328201419497e-08 1.1218249527884e-07 1.68224511648673e-07 ...
        2.40640152728384e-07 3.31661058439337e-07 4.43566602158221e-07 ...
        5.78685891499728e-07 7.39399769549201e-07 9.2814281188355e-07 ...
        1.147405314665e-06 1.39973526904294e-06 1.68774031705836e-06 ...
        2.01408968421074e-06 2.38151608381926e-06 2.7928175882903e-06 ...
        3.250859462389e-06 3.75857595360727e-06 4.31897203472075e-06 ...
        4.93512509363615e-06 5.6101865656458e-06 6.34738350322874e-06 ...
        7.15002007856885e-06 8.02147901399697e-06 8.96522293560994e-06 ...
        9.98479564537144e-06 1.10838233070589e-05 1.22660155414876e-05 ...
        1.35351664265183e-05 1.48951553974342e-05 1.63499480433627e-05 ...
        1.79035967955134e-05 1.95602415031043e-05 2.1324109892959e-05 ...
        2.31995179088737e-05 2.51908699269741e-05 2.73026588434137e-05 ...
        2.95394660308985e-05 3.19059611606657e-05 3.44069018866935e-05 ...
        3.70471333890698e-05 3.98315877736101e-05 4.27652833249798e-05 ...
        4.58533236107455e-05 4.91008964339558e-05 5.25132726320367e-05 ...
        5.60958047199671e-05 5.98539253758946e-05 6.37931457675437e-05 ...
        6.79190537179716e-05 7.22373117094237e-05 7.6753654724254e-05 ...
        8.14738879220802e-05 8.64038841525611e-05 9.15495813033961e-05 ...
        9.69169794833695e-05 0.000102512138040479 0.000108341172415419 ...
        0.000114410250830897 0.000120725590817524 0.000127293455577192 ...
        0.00013412015018515 0.000141212017632148 0.000148575434708314 ...
        0.00015621680773061 0.000164142568115969 0.000172359167802447 ...
        0.000180873074520926 0.00018969076692017 0.000198818729548236 ...
        0.000208263447693464 0.000218031402088532 0.000228129063481214 ...
        0.00023856288707578 0.000249339306849118 0.000260464729745917 ...
        0.000271945529757446 0.000283788041888659 0.000295998556018573 ...
        0.000308583310659053 0.000321548486617332 0.000334900200567787 ...
        0.000348644498538664 0.000362787349319637 0.00037733463779624 ...
        0.000392292158217388 0.000407665607402373 0.000423460577893839 ...
        0.000439682551063427 0.000456336890176902 0.000473428833425696 ...
        0.000490963486931959 0.000508945817734287 0.000527380646761446 ...
        0.000546272641801489 0.00056562631047376 0.000585445993211384 ...
        0.000605735856261894 0.00062649988471374 0.000647741875556472 ...
        0.000669465430782442 0.000691673950537931 0.000714370626331613 ...
        0.000737558434308316 0.00076124012859607 0.000785418234734375 ...
        0.000810095043191726 0.000835272602980303 0.000860952715375818 ...
        0.000887136927750408 0.000913826527526461 0.000941022536259203 ...
        0.000968725703855815 0.000996936502938787 0.00102565512336113 ...
        0.001054881466881 0.00108461514200316 0.0011148554589946 ...
        0.00114560142508165 0.00117685173983555 0.00120860479075348 ...
        0.00124085864904202 0.00127361106560949 0.00130685946727389 ...
        0.00134060095319268 0.00137483229152066 0.00140954991630189 ...
        0.0014447499246014 0.00148042807388254 0.00151657977963498 ...
        0.00155320011325898 0.00159028380021049 0.0016278252184121 ...
        0.00166581839693422 0.00170425701495075 0.00174313440097324 ...
        0.00178244353236733 0.00182217703515494 0.00186232718410543 ...
        0.00190288590311866 0.00194384476590269 0.00198519499694846 ...
        0.00202692747280356 0.00206903272364697 0.00211150093516619 ...
        0.00215432195073808 0.00219748527391434 0.00224098007121215 ...
        0.00228479517521042 0.00232891908795157 0.00237333998464859 ...
        0.00241804571769674 0.00246302382098898 0.00250826151453392 ...
        0.00255374570937468 0.00259946301280685 0.00264539973389338 ...
        0.00269154188927385 0.00273787520926534 0.00278438514425191 ...
        0.002831056871359 0.00287787530140934 0.00292482508615608 ...
        0.00297189062578895 0.00301905607670874 0.00306630535956527 ...
        0.00311362216755351 0.00316098997496239 0.00320839204597053 ...
        0.00325581144368283 0.00330323103940151 0.00335063352212505 ...
        0.00339800140826812 0.0034453170515954 0.00349256265336189 ...
        0.00353972027265209 0.00358677183691022 0.00363369915265329 ...
        0.00368048391635888 0.00372710772551895 0.00377355208985102 ...
        0.0038197984426578 0.00386582815232613 0.00391162253395592 ...
        0.00395716286110968 0.00400243037767293 0.00404740630981579 ...
        0.00409207187804575 0.00413640830934161 0.00418039684935839 ...
        0.0042240187746929 0.0042672554051996 0.00431008811634623 ...
        0.00435249835159865 0.00439446763482427 0.00443597758270329 ...
        0.00447700991713706 0.00451754647764274 0.00455756923372347 ...
        0.00459706029720315 0.00463600193451501 0.00467437657893314 ...
        0.0047121668427362 0.00474935552929238 0.00478592564505501 ...
        0.00482186041145799 0.00485714327670049 0.00489175792741026 ...
        0.00492568830017509 0.00495891859293212 0.0049914332762045 ...
        0.00502321710417541 0.00505425512558935 0.00508453269447067 ...
        0.00511403548064976 0.00514274948008716 0.00517066102498616 ...
        0.00519775679368471 0.00522402382031746 0.00524944950423915 ...
        0.00527402161920057 0.00529772832226877 0.00532055816248316 ...
        0.00534250008923953 0.00536354346039437 0.00538367805008174 ...
        0.00540289405623567 0.00542118210781094 0.0054385332716957 ...
        0.00545493905930929 0.00547039143287931 0.00548488281139199 ...
        0.00549840607621032 0.00551095457635475 0.00552252213344146 ...
        0.00553310304627362 0.00554269209508137 0.00555128454540653 ...
        0.00555887615162833 0.00556546316012706 0.00557104231208244 ...
        0.00557561084590425 0.00557916649929286 0.00558170751092782 ...
        0.00558323262178275 0.00558374107606554 0.00558323262178275 ...
        0.00558170751092782 0.00557916649929286 0.00557561084590425 ...
        0.00557104231208244 0.00556546316012706 0.00555887615162833 ...
        0.00555128454540653 0.00554269209508137 0.00553310304627362 ...
        0.00552252213344146 0.00551095457635475 0.00549840607621032 ...
        0.00548488281139199 0.00547039143287931 0.00545493905930929 ...
        0.0054385332716957 0.00542118210781094 0.00540289405623567 ...
        0.00538367805008174 0.00536354346039437 0.00534250008923953 ...
        0.00532055816248316 0.00529772832226877 0.00527402161920057 ...
        0.00524944950423915 0.00522402382031746 0.00519775679368471 ...
        0.00517066102498616 0.00514274948008716 0.00511403548064976 ...
        0.00508453269447067 0.00505425512558935 0.00502321710417541 ...
        0.0049914332762045 0.00495891859293212 0.00492568830017509 ...
        0.00489175792741026 0.00485714327670049 0.00482186041145799 ...
        0.00478592564505501 0.00474935552929238 0.0047121668427362 ...
        0.00467437657893314 0.00463600193451501 0.00459706029720315 ...
        0.00455756923372347 0.00451754647764274 0.00447700991713706 ...
        0.00443597758270329 0.00439446763482427 0.00435249835159865 ...
        0.00431008811634623 0.0042672554051996 0.0042240187746929 ...
        0.00418039684935839 0.00413640830934161 0.00409207187804575 ...
        0.00404740630981579 0.00400243037767293 0.00395716286110968 ...
        0.00391162253395592 0.00386582815232613 0.0038197984426578 ...
        0.00377355208985102 0.00372710772551895 0.00368048391635888 ...
        0.00363369915265329 0.00358677183691022 0.00353972027265209 ...
        0.00349256265336189 0.0034453170515954 0.00339800140826812 ...
        0.00335063352212505 0.00330323103940151 0.00325581144368283 ...
        0.00320839204597053 0.00316098997496239 0.00311362216755351 ...
        0.00306630535956527 0.00301905607670874 0.00297189062578895 ...
        0.00292482508615608 0.00287787530140934 0.002831056871359 ...
        0.00278438514425191 0.00273787520926534 0.00269154188927385 ...
        0.00264539973389338 0.00259946301280685 0.00255374570937468 ...
        0.00250826151453392 0.00246302382098898 0.00241804571769674 ...
        0.00237333998464859 0.00232891908795157 0.00228479517521042 ...
        0.00224098007121215 0.00219748527391434 0.00215432195073808 ...
        0.00211150093516619 0.00206903272364697 0.00202692747280356 ...
        0.00198519499694846 0.00194384476590269 0.00190288590311866 ...
        0.00186232718410543 0.00182217703515494 0.00178244353236733 ...
        0.00174313440097324 0.00170425701495075 0.00166581839693422 ...
        0.0016278252184121 0.00159028380021049 0.00155320011325898 ...
        0.00151657977963498 0.00148042807388254 0.0014447499246014 ...
        0.00140954991630189 0.00137483229152066 0.00134060095319268 ...
        0.00130685946727389 0.00127361106560949 0.00124085864904202 ...
        0.00120860479075348 0.00117685173983555 0.00114560142508165 ...
        0.0011148554589946 0.00108461514200316 0.001054881466881 ...
        0.00102565512336113 0.000996936502938787 0.000968725703855815 ...
        0.000941022536259203 0.000913826527526461 0.000887136927750408 ...
        0.000860952715375818 0.000835272602980303 0.000810095043191726 ...
        0.000785418234734375 0.00076124012859607 0.000737558434308316 ...
        0.000714370626331613 0.000691673950537931 0.000669465430782442 ...
        0.000647741875556472 0.00062649988471374 0.000605735856261894 ...
        0.000585445993211384 0.00056562631047376 0.000546272641801489 ...
        0.000527380646761446 0.000508945817734287 0.000490963486931959 ...
        0.000473428833425696 0.000456336890176902 0.000439682551063427 ...
        0.000423460577893839 0.000407665607402373 0.000392292158217388 ...
        0.00037733463779624 0.000362787349319637 0.000348644498538664 ...
        0.000334900200567787 0.000321548486617332 0.000308583310659053 ...
        0.000295998556018573 0.000283788041888659 0.000271945529757446 ...
        0.000260464729745917 0.000249339306849118 0.00023856288707578 ...
        0.000228129063481214 0.000218031402088532 0.000208263447693464 ...
        0.000198818729548236 0.00018969076692017 0.000180873074520926 ...
        0.000172359167802447 0.000164142568115969 0.00015621680773061 ...
        0.000148575434708314 0.000141212017632148 0.00013412015018515 ...
        0.000127293455577192 0.000120725590817524 0.000114410250830897 ...
        0.000108341172415419 0.000102512138040479 9.69169794833695e-05 ...
        9.15495813033961e-05 8.64038841525611e-05 8.14738879220802e-05 ...
        7.6753654724254e-05 7.22373117094237e-05 6.79190537179716e-05 ...
        6.37931457675437e-05 5.98539253758946e-05 5.60958047199671e-05 ...
        5.25132726320367e-05 4.91008964339558e-05 4.58533236107455e-05 ...
        4.27652833249798e-05 3.98315877736101e-05 3.70471333890698e-05 ...
        3.44069018866935e-05 3.19059611606657e-05 2.95394660308985e-05 ...
        2.73026588434137e-05 2.51908699269741e-05 2.31995179088737e-05 ...
        2.1324109892959e-05 1.95602415031043e-05 1.79035967955134e-05 ...
        1.63499480433627e-05 1.48951553974342e-05 1.35351664265183e-05 ...
        1.22660155414876e-05 1.10838233070589e-05 9.98479564537144e-06 ...
        8.96522293560994e-06 8.02147901399697e-06 7.15002007856885e-06 ...
        6.34738350322874e-06 5.6101865656458e-06 4.93512509363615e-06 ...
        4.31897203472075e-06 3.75857595360727e-06 3.250859462389e-06 ...
        2.7928175882903e-06 2.38151608381926e-06 2.01408968421074e-06 ...
        1.68774031705836e-06 1.39973526904294e-06 1.147405314665e-06 ...
        9.2814281188355e-07 7.39399769549201e-07 5.78685891499728e-07 ...
        4.43566602158221e-07 3.31661058439337e-07 2.40640152728384e-07 ...
        1.68224511648673e-07 1.1218249527884e-07 7.0328201419497e-08 ...
        4.05194794411783e-08 2.0655958171351e-08 8.67709219765811e-09 ...
        2.56023087856813e-09 3.18714260155108e-10 0]);
end

y = step(Hd,x);


% [EOF]
