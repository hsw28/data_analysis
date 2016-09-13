function f = towardreward(eventpos)

% cener stem is about y coordinates 340 to 370
% subtract surrounding x points and see if animal is going away or towards reward
% actually could divide this into quadrants and do it over whole area... hmm



% upper left
%Y > 370
%x < 525

%upper right
%Y > 370
%X > 775

%lower left
%Y < 348
%X < 525

%lower right
%Y < 348
%X > 775

%stem
%y > 348 and y < 370

%assign quads
if x < 525 && y > 370
%UL

if x < 525 && y < 348
%LL

if x > 775 && y > 370
%UR

if x > 775 && y < 348
%LR

if y >= 348 || y <= 370
%stem

% permute through position points for an event, assign quad
% search through entire position file for event time and position, determine previous and next quads (or just look at point 50 in future? unsure)
% depending on quad, determine where animal is going
% could you do this super easily with the gradient function?? will have to look
