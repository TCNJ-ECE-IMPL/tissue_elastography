function [c,lags] = myxcorr(x,y,maxlag,minlag,option)
%MYXCORR cross-correlation function and SAD (sum-absolute-difference) estimates
%   MYXCORR(X,Y) computes the correlation function (CF) between 
%   the vectors X and Y of sizes MX and MY.
%
%   MYCORR(X,Y,MAXLAG) computes for lags -MAXLAG:MAXLAG.
%
%   MYCORR(X,Y,OPTION) or MYCORR(X,Y,MAXLAG,OPTION) computes 
%   for various OPTIONs as follows:
%   'none':      compute unnormalized CF (default, if not passed)
%   'coeff':     computes the correlation coefficient function
%   'fast':      unnormalized CF (use the fast function XCORRALT)
%   'fastcoeff': correlation coefficient function (use XCORRALT for the 
%                numerator and CNormFac.dll for the denominator).
%                WARNING: 'coeff' might sometimes be faster for normal lag ranges.
%   'cov-none':  compute unnormalized covariance (mean subtracted from x and y)
%   'cov-coeff': computes normalized covariance function
%   'cov-fast':  computes unnormalized covariance function (faster implementation)
%   'cov-fastcoeff': computes normalized covariance function (use XCORRALT
%                for the numerator and CNormFac.dll for the denominator).
%                WARNING: 'coeff' might sometimes be faster for normal lag ranges.
%   'matlab':    calls MATLAB's xcorr
%   'mcoeff':    calls MATLAB's xcorr with 'coeff' option
%   'sad':       computes SAD (sum-absolute-difference) instead of correlation
%                function. Needs to be minimized for displacement estimation.
%   'ssd':       calls SSD (sum-squared-difference). Needs to be minimized.
%
%   [C,LAGS] = MYXCORR  returns a vector of lag indices (LAGS).
%
%   if option is 'coeff', and X and Y have the same size M,
%   the correlation returned will be of size 2*fix(M/2)+1.
%
%   Warning: if one vector is a subset of the other, the 
%   corrcoeff maximum is not unity, due to their unequal 
%   sizes. The maximum also may be slightly shifted. A fix 
%   may be available in the future.
%
%   Known bugs: Cannot handle lags (due to MINLAG and MAXLAG values) for 
%             which there is no intersection between X and Y. Suggested
%             workaround until fixed: zeropad or use appropriate limits. 
%
%   See also MYXCOV, COMPCORR, COMPSAD, CONV, CORRCOEF, XCORR, XCOV and XCORR2.

% Author:	S. K. Alam
% Email: kalam@rrinyc.org
% Date: 09-04-98
% Revised: 07-28-09
% Version: 4.1
%
% New in this version: Can now handle complex numbers. 
%
% Copyright © 1998 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

error(nargchk(1,5,nargin))
if nargin == 1 % IF ONLY X IS PASSED, COMPUTE AUTOCORRELATION
   y = x;
elseif nargin==2 % IF ONLY X IS PASSED, COMPUTE AUTOCORRELATION
   if isstr(y)
      option=y;
      y=x;
   end
elseif nargin==3
   if isstr(maxlag)
      option=maxlag;
      clear maxlag
   end
elseif nargin==4
   if isstr(minlag)
      option=minlag;
      clear minlag
   end
end

if ~exist('option','var')
   option='none';
end

if strncmp(option,'cov-',4) % COVARIANCE: MEAN TO BE SUBTRACTED FROM X and Y
   if length(option) > 5
      option = option(5:end);
   else % OPTION = 'COV-'
      option='none';
   end
   x = removemean(x); y = removemean(y); % MEAN REMOVED FROM X and Y
end

[m,n] = size(x);
if nargin > 1
   [my,ny] = size(y);
   if min(m,n) ~= 1
      error('X and Y must be vectors.');
   end
elseif min(size(x)) == 1
   y = x;
end


% x=x-ones(m,1)*mean(x);	% subtract the mean from x
% y=y-ones(my,1)*mean(y);	% subtract the mean from y

% NOTE: IN FUTURE, UPDATE FOR COLUMNWISE OPERATION

Lx = length(x);
Ly = length(y);
if ~exist('minlag','var')   % If no minlag was passed
   if ~exist('maxlag','var')   % If no maxlag also was passed
      if Lx > Ly, minlag = -fix(Lx - Ly/2);
      else, minlag = -fix(Lx/2);
      end
%       if Lx > Ly, minlag = -fix(Ly/2);
%       else, minlag = -fix(Ly - Lx/2);
%       end
   else % maxlag was passed. Range -maxlag:maxlag
      minlag = -maxlag;
   end
end
if ~exist('maxlag','var')   % If no maxlag was passed
   if Lx > Ly, maxlag = fix(Ly/2);
   else, maxlag = fix(Ly - Lx/2);
   end
%    if Lx > Ly, maxlag = fix(Lx - Ly/2);
%    else, maxlag = fix(Lx/2);
%    end
end

if strcmpi(option,'none') | strcmpi(option,'coeff')
   c = compcorr(x,y,maxlag,minlag,option);
elseif strcmpi(option,'fast')
   c = xcorralt(x,y);
   mx = length(x); my = length(y);
   zerolag = my;
   range = (zerolag + minlag):(zerolag + maxlag);
   c = c(range);
elseif strcmpi(option,'fastcoeff')
   %warning('%s\n\t%s\n\t%s','Use of ''coeff'' option SUGGESTED...',...
   %    'In 1D, for normal lag ranges, ''fastcoeff'' is SLOWER!!!...',...
   %    'Exiting...')
   %c = []; lags = [];
   %return
   %%if (maxlag - minlag) > (Lx + Ly)
   %%    mm = (maxlag >= abs(minlag))*maxlag + (maxlag < abs(minlag))*abs(minlag);
   %%end
   %%if Lx < mm, x[Lx+1:mm] = 0; end
   %%if Ly < mm, y[Ly+1:mm] = 0; end
   %%mx = length(x); my = length(y);
   %% IF MINLAG OR MAXLAG REQUIRES C VALUES WHERE X AND Y DO NOT INTERCEPT
   c = xcorralt(x,y);
   zerolag = my;
   range = (zerolag + minlag):(zerolag + maxlag);
   norm = CNormFac(x,y,maxlag,minlag);
   norm(find(norm == 0)) = Inf;
   c = c(range)./norm;
elseif strcmpi(option,'matlab')
   c = xcorr(x,y);
   zerolag = my;
   range = (zerolag + minlag):(zerolag + maxlag);
   c = c(range);
elseif strcmpi(option,'mcoeff')
   c = xcorr(x,y,'coeff');
   zerolag = my;
   range = (zerolag + minlag):(zerolag + maxlag);
   c = c(range);
elseif strcmpi(option,'sad')
   c = compsad(x,y,maxlag,minlag);
elseif strcmpi(option,'ssd')
   c = compssd(x,y,maxlag,minlag);
else
   error('Unknown OPTION')
end

lags=minlag:maxlag;

function c = xcorralt(x,y)
mx = length(x); my = length(y);
mm = (mx >= my)*mx + (mx < my)*my;
mc = 2.^nextpow2(2*mm - 1);
c = real(ifft(fft(x,mc).*fft(rot90(y,2),mc)));

% for 'coeff' option, call function normalize, if denominator zero, don't divide

%########################### REVISION HISTORY ###########################
% 2.3) default values of minlag and maxlag are now smaller to avoid 
%      noise spikes at both ends.
% 2.0) zero padding to make the vectors equal (when they are not equal) 
%	    was removed for the 'coeff' because zeroes modify the correlation 
%	    coefficient values. MATLAB routine 'intersect' was used to select 
%	    the elements for use in correlation computation; it significantly 
%	    simplified computation.
% 1.1) normalizing for the 'coeff' option was modified; when the normalizer 
%	    is zero, no division is performed and the CCF is set to zero.