function [b, s] = getfilter(Fs, band, method, varargin)
%GETFILTER return coefficients for eeg filter
%
%  Syntax
%
%      [b, s] = getfilter( Fs, band, method )
%
%  Description
%
%    This function returns the coefficients for a FIR filter. Band
%    specifies the frequency band of interest and can be one of: 'theta',
%    'ripple', 'slow', 'spindle', 'gamma'. The filter is created using one
%    of three methods: 'win', 'ls' or 'pm'. Optionally, a string containing
%    the filter definition is returned.
%


args.band = [0 0];
args = parseArgsLite(varargin,args);

switch band
    
    case 'theta'
        
        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[6 12]./Fs );'];
            case 'ls'
                s = [s 'b = firls( N, 2.*[0 5 6 12 14 0.5*Fs]./Fs, [0 0 1 1 0 0], [100 1 10] );'];
            case 'pm'
                s = [s 'b = firpm( N, 2.*[0 5 6 12 14 0.5*Fs]./Fs, [0 0 1 1 0 0], [10 1 10] );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);
        
    case 'ripple'

        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[140 240]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);        
        
    case 'slow-ripple'

        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[80 240]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s); 
   case 'wide-ripple'

        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[80 360]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);      
        
    case 'slow'
        
        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs.*1.5); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[4]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);   
        
    case 'spindle'
         %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[9 16]./Fs );'];
            
            otherwise
                error('Invalid method')
        end
        
        eval(s);
    
    case 'spindle2'
         %Filter order is the the first even integer > Fs
         s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[10 20]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);
    case 'gamma'
        
        if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[30 100]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);
        
    case 'beta'
        
         if nargin<3 || isempty(method)
            method = 'win';
        end
        
        %Filter order is the the first even integer > Fs
        s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
        
        switch method
            case 'win'
                s = [s 'b = fir1( N, 2.*[15 40]./Fs );'];
            otherwise
                error('Invalid method')
        end
        
        eval(s);       
        
    case 'sharpwave'

%          if nargin<3 || isempty(method)
%             method = 'win';
%         end
% 
%         %Filter order is the the first even integer > Fs
%         s = 'N = ceil(Fs./4); N = N + mod(N,2); ';
% 
%         switch method
%             case 'win'
%                 s = [s 'b = fir1( N, 2.*[.00001 20]./Fs );'];
%             otherwise
%                 error('Invalid method')
%         end
% 
%         eval(s);       
        b = get_sw_filter();
        
    case 'custom'
        if sum(args.band)==0 || ~ismonotonic(args.band) || any(sign(args.band) == -1)
            error('Invalid band specified');
        end
        if nargin<3 || isempty(method)
                method = 'win';
            end

            %Filter order is the the first even integer > Fs
            s = 'N = ceil(Fs./4); N = N + mod(N,2); ';

            switch method
                case 'win'
                    s = [s 'b = fir1( N, 2.*[', num2str(args.band(1)), ' ', num2str(args.band(2)),']./Fs );'];
                otherwise
                    error('Invalid method')
            end

            eval(s);      
    otherwise
        error('Invalid Band specified');

end

end

function filt = get_sw_filter()

    filt = [  0.0181
   -0.0033
   -0.0032
   -0.0033
   -0.0034
   -0.0036
   -0.0039
   -0.0042
   -0.0045
   -0.0049
   -0.0053
   -0.0056
   -0.0059
   -0.0061
   -0.0062
   -0.0063
   -0.0063
   -0.0062
   -0.0059
   -0.0055
   -0.0050
   -0.0043
   -0.0035
   -0.0025
   -0.0014
   -0.0001
    0.0013
    0.0029
    0.0045
    0.0064
    0.0083
    0.0103
    0.0124
    0.0145
    0.0167
    0.0189
    0.0211
    0.0233
    0.0255
    0.0275
    0.0295
    0.0313
    0.0331
    0.0346
    0.0360
    0.0373
    0.0383
    0.0391
    0.0396
    0.0400
    0.0401
    0.0400
    0.0396
    0.0391
    0.0383
    0.0373
    0.0360
    0.0346
    0.0331
    0.0313
    0.0295
    0.0275
    0.0255
    0.0233
    0.0211
    0.0189
    0.0167
    0.0145
    0.0124
    0.0103
    0.0083
    0.0064
    0.0045
    0.0029
    0.0013
   -0.0001
   -0.0014
   -0.0025
   -0.0035
   -0.0043
   -0.0050
   -0.0055
   -0.0059
   -0.0062
   -0.0063
   -0.0063
   -0.0062
   -0.0061
   -0.0059
   -0.0056
   -0.0053
   -0.0049
   -0.0045
   -0.0042
   -0.0039
   -0.0036
   -0.0034
   -0.0033
   -0.0032
   -0.0033
    0.0181];


end