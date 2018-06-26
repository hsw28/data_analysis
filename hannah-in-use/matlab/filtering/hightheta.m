function y = hightheta(x)
%HIGHTHETA Filters input x and returns output y.
%bandpass filters 8-10hz

% MATLAB Code
% Generated by MATLAB(R) 9.1 and the DSP System Toolbox 9.3.
% Generated on: 10-May-2018 14:37:37

%#codegen

% To generate C/C++ code from this function use the codegen command. Type
% 'help codegen' for more information.

persistent Hd;

if isempty(Hd)

    % The following code was used to design the filter coefficients:
    % % FIR Window Bandpass filter designed using the FIR1 function.
    %
    % % All frequency values are in Hz.
    % Fs = 2000;  % Sampling Frequency
    %
    % N    = 500;      % Order
    % Fc1  = 8;        % First Cutoff Frequency
    % Fc2  = 10;       % Second Cutoff Frequency
    % flag = 'scale';  % Sampling Flag
    % % Create the window vector for the design algorithm.
    % win = blackman(N+1);
    %
    % % Calculate the coefficients using the FIR1 function.
    % b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);

    Hd = dsp.FIRFilter( ...
        'Numerator', [0 8.9667620422195e-08 3.68486242882207e-07 ...
        8.5065415701529e-07 1.54964833255063e-06 2.47819831857895e-06 ...
        3.64826006915095e-06 5.07098966769345e-06 6.75671692941534e-06 ...
        8.71491886786725e-06 1.09541930191356e-05 1.34822306247007e-05 ...
        1.63057896817776e-05 1.94306678779487e-05 2.28616754349913e-05 ...
        2.66026078950786e-05 3.06562188908004e-05 3.50241929488089e-05 ...
        3.97071183852165e-05 4.47044603591315e-05 5.00145341589151e-05 ...
        5.56344788037626e-05 6.1560231051101e-05 6.77864999079176e-05 ...
        7.43067417515381e-05 8.11131361724601e-05 8.81965626585829e-05 ...
        9.55465782465721e-05 0.000103151396272031 0.00011099786635568 ...
        0.000119071455767759 0.000127356232317372 0.000135834848917448 ...
        0.000144488529979384 0.00015329705979416 0.000162238773058907 ...
        0.000171290547709326 0.000180427800219183 0.000189624483528184 ...
        0.000198853087758925 0.000208084643882224 0.000217288730488088 ...
        0.000226433483816671 0.000235485611199993 0.00024441040806081 ...
        0.000253171778609871 0.0002617322603769 0.000270053052703976 ...
        0.000278094049322568 0.000285813875127298 0.000293169927250663 ...
        0.000300118420533294 0.000306614437474059 0.000312611982733338 ...
        0.000318064042251193 0.000322922647029873 0.000327138941617301 ...
        0.000330663257314768 0.000333445190118142 0.000335433683387475 ...
        0.000336577115225043 0.000336823390526574 0.000336120037654758 ...
        0.000334414309668219 0.000331653290022836 0.000327784002645899 ...
        0.000322753526266921 0.00031650911287217 0.000308998310133196 ...
        0.000300169087642764 0.000289969966774809 0.00027835015396835 ...
        0.000265259677218741 0.000250649525543305 0.000234471791172338 ...
        0.00021667981420071 0.000197228329419963 0.000176073615035844 ...
        0.000153173642961832 0.000128488230365303 0.000101979192129725 ...
        7.3610493883685e-05 4.3348405235627e-05 1.11616528420484e-05 ...
        -2.29784270733969e-05 -5.90977371419187e-05 -9.72192686133028e-05 ...
        -0.000137362952869509 -0.000179545515102931 -0.000223780330579691 ...
        -0.000270077283912849 -0.000318442631773829 -0.000368878869472602 ...
        -0.000421384601838351 -0.000475954418832204 -0.000532578776322382 ...
        -0.000591243882449619 -0.000651931590006919 -0.000714619295252781 ...
        -0.000779279843570703 -0.000845881442380305 -0.000914387581696593 ...
        -0.000984756962723824 -0.00105694343485918 -0.00113089594146878 ...
        -0.00120655847478497 -0.00128387004025859 -0.00136276463068386 ...
        -0.00144317121039623 -0.00152501370982483 -0.00160821103066171 ...
        -0.00169267706188934 -0.00177832070688615 -0.00186504592180709 ...
        -0.00195275176541276 -0.00204133246049589 -0.00213067746702889 ...
        -0.00222067156712965 -0.00231119496191643 -0.00240212338029466 ...
        -0.00249332819969065 -0.00258467657871855 -0.00267603160173772 ...
        -0.00276725243522818 -0.00285819449588217 -0.0029487096302796 ...
        -0.00303864630598514 -0.00312784981387433 -0.00321616248146596 ...
        -0.00330342389700742 -0.00338947114403015 -0.00347413904606211 ...
        -0.00355726042115488 -0.00363866634585394 -0.00371818642821193 ...
        -0.00379564908941681 -0.00387088185357933 -0.00394371164519763 ...
        -0.00401396509379082 -0.00408146884516853 -0.0041460498787793 ...
        -0.00420753583055762 -0.00426575532066781 -0.00432053828552168 ...
        -0.00437171631342808 -0.00441912298321363 -0.00446259420513763 ...
        -0.00450196856340823 -0.00453708765959359 -0.00456779645620883 ...
        -0.00459394361974921 -0.00461538186243046 -0.00463196828188986 ...
        -0.00464356469809589 -0.00465003798670998 -0.0046512604081419 ...
        -0.00464710993153942 -0.0046374705529547 -0.00462223260693236 ...
        -0.0046012930707698 -0.00457455586070646 -0.00454193211930813 ...
        -0.00450334049332206 -0.00445870740129183 -0.00440796729023424 ...
        -0.00435106288069716 -0.00428794539953441 -0.00421857479975381 ...
        -0.00414291996681499 -0.00406095891077748 -0.00397267894372281 ...
        -0.00387807684190193 -0.00377715899208556 -0.00366994152162541 ...
        -0.00355645041176384 -0.00343672159376242 -0.00331080102745216 ...
        -0.00317874476184356 -0.00304061897746977 -0.00289650001017304 ...
        -0.00274647435608233 -0.00259063865756879 -0.00242909967000514 ...
        -0.00226197420919512 -0.00208938907938043 -0.00191148098177345 ...
        -0.00172839640360648 -0.00154029148773006 -0.00134733188283564 ...
        -0.00114969257442034 -0.000947557696654605 -0.000741120325355666 ...
        -0.000530582252312813 -0.000316153741252264 -9.80532657716073e-05 ...
        0.000123492770384926 0.000348250330298019 0.000575978057639542 ...
        0.000806427606741409 0.00103934398843677 0.00127446593110545 ...
        0.00151152625631893 0.00175025226844503 0.00199036615753784 ...
        0.00223158541480615 0.00247362325992143 0.00271618907939751 ...
        0.00295898887524459 0.00320172572307437 0.00344410023880776 ...
        0.00368581105311331 0.00392655529268324 0.00416602906743475 ...
        0.00440392796270628 0.00463994753550342 0.00487378381383529 ...
        0.00510513379817156 0.00533369596404011 0.00555917076477949 ...
        0.00578126113345433 0.00599967298294024 0.00621411570318366 ...
        0.00642430265464421 0.00662995165693114 0.00683078547165184 ...
        0.00702653227849862 0.00721692614361103 0.00740170747926362 ...
        0.00758062349394443 0.00775342863190622 0.0079198850012924 ...
        0.00807976278996052 0.00823284066814958 0.00837890617716334 ...
        0.00851775610326819 0.00864919683603394 0.00877304471037678 ...
        0.00888912633159564 0.00899727888272825 0.00909735041358859 ...
        0.00918920011088449 0.00927269854885371 0.00934772791989571 ...
        0.00941418224471849 0.00947196756156178 0.00952100209410122 ...
        0.00956121639768267 0.00959255348358087 0.00961496892102224 ...
        0.00962843091675841 0.00963292037202391 0.00962843091675841 ...
        0.00961496892102224 0.00959255348358087 0.00956121639768267 ...
        0.00952100209410122 0.00947196756156178 0.00941418224471849 ...
        0.00934772791989571 0.00927269854885371 0.00918920011088449 ...
        0.00909735041358859 0.00899727888272825 0.00888912633159564 ...
        0.00877304471037678 0.00864919683603394 0.00851775610326819 ...
        0.00837890617716334 0.00823284066814958 0.00807976278996052 ...
        0.0079198850012924 0.00775342863190622 0.00758062349394443 ...
        0.00740170747926362 0.00721692614361103 0.00702653227849862 ...
        0.00683078547165184 0.00662995165693114 0.00642430265464421 ...
        0.00621411570318366 0.00599967298294024 0.00578126113345433 ...
        0.00555917076477949 0.00533369596404011 0.00510513379817156 ...
        0.00487378381383529 0.00463994753550342 0.00440392796270628 ...
        0.00416602906743475 0.00392655529268324 0.00368581105311331 ...
        0.00344410023880776 0.00320172572307437 0.00295898887524459 ...
        0.00271618907939751 0.00247362325992143 0.00223158541480615 ...
        0.00199036615753784 0.00175025226844503 0.00151152625631893 ...
        0.00127446593110545 0.00103934398843677 0.000806427606741409 ...
        0.000575978057639542 0.000348250330298019 0.000123492770384926 ...
        -9.80532657716073e-05 -0.000316153741252264 -0.000530582252312813 ...
        -0.000741120325355666 -0.000947557696654605 -0.00114969257442034 ...
        -0.00134733188283564 -0.00154029148773006 -0.00172839640360648 ...
        -0.00191148098177345 -0.00208938907938043 -0.00226197420919512 ...
        -0.00242909967000514 -0.00259063865756879 -0.00274647435608233 ...
        -0.00289650001017304 -0.00304061897746977 -0.00317874476184356 ...
        -0.00331080102745216 -0.00343672159376242 -0.00355645041176384 ...
        -0.00366994152162541 -0.00377715899208556 -0.00387807684190193 ...
        -0.00397267894372281 -0.00406095891077748 -0.00414291996681499 ...
        -0.00421857479975381 -0.00428794539953441 -0.00435106288069716 ...
        -0.00440796729023424 -0.00445870740129183 -0.00450334049332206 ...
        -0.00454193211930813 -0.00457455586070646 -0.0046012930707698 ...
        -0.00462223260693236 -0.0046374705529547 -0.00464710993153942 ...
        -0.0046512604081419 -0.00465003798670998 -0.00464356469809589 ...
        -0.00463196828188986 -0.00461538186243046 -0.00459394361974921 ...
        -0.00456779645620883 -0.00453708765959359 -0.00450196856340823 ...
        -0.00446259420513763 -0.00441912298321363 -0.00437171631342808 ...
        -0.00432053828552168 -0.00426575532066781 -0.00420753583055762 ...
        -0.0041460498787793 -0.00408146884516853 -0.00401396509379082 ...
        -0.00394371164519763 -0.00387088185357933 -0.00379564908941681 ...
        -0.00371818642821193 -0.00363866634585394 -0.00355726042115488 ...
        -0.00347413904606211 -0.00338947114403015 -0.00330342389700742 ...
        -0.00321616248146596 -0.00312784981387433 -0.00303864630598514 ...
        -0.0029487096302796 -0.00285819449588217 -0.00276725243522818 ...
        -0.00267603160173772 -0.00258467657871855 -0.00249332819969065 ...
        -0.00240212338029466 -0.00231119496191643 -0.00222067156712965 ...
        -0.00213067746702889 -0.00204133246049589 -0.00195275176541276 ...
        -0.00186504592180709 -0.00177832070688615 -0.00169267706188934 ...
        -0.00160821103066171 -0.00152501370982483 -0.00144317121039623 ...
        -0.00136276463068386 -0.00128387004025859 -0.00120655847478497 ...
        -0.00113089594146878 -0.00105694343485918 -0.000984756962723824 ...
        -0.000914387581696593 -0.000845881442380305 -0.000779279843570703 ...
        -0.000714619295252781 -0.000651931590006919 -0.000591243882449619 ...
        -0.000532578776322382 -0.000475954418832204 -0.000421384601838351 ...
        -0.000368878869472602 -0.000318442631773829 -0.000270077283912849 ...
        -0.000223780330579691 -0.000179545515102931 -0.000137362952869509 ...
        -9.72192686133028e-05 -5.90977371419187e-05 -2.29784270733969e-05 ...
        1.11616528420484e-05 4.3348405235627e-05 7.3610493883685e-05 ...
        0.000101979192129725 0.000128488230365303 0.000153173642961832 ...
        0.000176073615035844 0.000197228329419963 0.00021667981420071 ...
        0.000234471791172338 0.000250649525543305 0.000265259677218741 ...
        0.00027835015396835 0.000289969966774809 0.000300169087642764 ...
        0.000308998310133196 0.00031650911287217 0.000322753526266921 ...
        0.000327784002645899 0.000331653290022836 0.000334414309668219 ...
        0.000336120037654758 0.000336823390526574 0.000336577115225043 ...
        0.000335433683387475 0.000333445190118142 0.000330663257314768 ...
        0.000327138941617301 0.000322922647029873 0.000318064042251193 ...
        0.000312611982733338 0.000306614437474059 0.000300118420533294 ...
        0.000293169927250663 0.000285813875127298 0.000278094049322568 ...
        0.000270053052703976 0.0002617322603769 0.000253171778609871 ...
        0.00024441040806081 0.000235485611199993 0.000226433483816671 ...
        0.000217288730488088 0.000208084643882224 0.000198853087758925 ...
        0.000189624483528184 0.000180427800219183 0.000171290547709326 ...
        0.000162238773058907 0.00015329705979416 0.000144488529979384 ...
        0.000135834848917448 0.000127356232317372 0.000119071455767759 ...
        0.00011099786635568 0.000103151396272031 9.55465782465721e-05 ...
        8.81965626585829e-05 8.11131361724601e-05 7.43067417515381e-05 ...
        6.77864999079176e-05 6.1560231051101e-05 5.56344788037626e-05 ...
        5.00145341589151e-05 4.47044603591315e-05 3.97071183852165e-05 ...
        3.50241929488089e-05 3.06562188908004e-05 2.66026078950786e-05 ...
        2.28616754349913e-05 1.94306678779487e-05 1.63057896817776e-05 ...
        1.34822306247007e-05 1.09541930191356e-05 8.71491886786725e-06 ...
        6.75671692941534e-06 5.07098966769345e-06 3.64826006915095e-06 ...
        2.47819831857895e-06 1.54964833255063e-06 8.5065415701529e-07 ...
        3.68486242882207e-07 8.9667620422195e-08 0]);
end

y = step(Hd,double(x));
delay = mean(grpdelay(Hd));
y = step(Hd,(x));
y(1:delay) = [];


% [EOF]