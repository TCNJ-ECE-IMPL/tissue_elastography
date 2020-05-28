function [pval,ploc]=parbintp(cccf,lags)
%PARBINTP parabolic peak interpolation
%   PARBINTP(CCCF) estimates the peak of a correlation 
%   function CCCF using parabolic interpolation. 
%   PARBINTP(CCCF,LAGS) uses the lag values LAGS. LAGS 
%   have to be monotonic, and difference between successive 
%   lags should be a constant. If LAGS is not passed, LAGS 
%   is assumed to be: (1:LEN)-FIX(LEN/2+.5).
%   [PVAL,PLOC] = PARBINTP returns both the interpolated 
%   maximum value PVAL and location PLOC.
%
%   See also: COSINTP, PARBINTP2

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 10-22-98
% Revised: 08-22-00 (SKA)
% Version: 2.0
%
% New in this version: uses lag values, when passed.
%
% Copyright © 1999 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

len=length(cccf);
[mval,mloc]=max(cccf);

if mloc == len | mloc == 1  % Max is the 1st/last element - no interpolation
   if exist('lags','var')
      peak = lags(mloc);
   else
      peak = mloc-fix(len/2.0+0.5);  % midpoint is t=0
   end
   peakval = mval;
else
   y=cccf(mloc-1:mloc+1);
   x=-1:1;
   
   % FRACTIONAL SHIFT FROM DISCRETE MAXIMUM (x(2) = 0)
   peak = x(2) + 0.5*(y(1) - y(3))/(y(1) - 2*y(2) + y(3));
   % PEAK VALUE
   peakval = y(3)*(peak-x(1))*(peak-x(2))/((x(3)-x(1))*(x(3)-x(2))) + ...
      y(2)*(peak-x(1))*(peak-x(3))/((x(2)-x(1))*(x(2)-x(3))) + ...
      y(1)*(peak-x(2))*(peak-x(3))/((x(1)-x(2))*(x(1)-x(3)));
   % ABSOLUTE LOCATION OF TRUE MAXIMUM
   if exist('lags','var')
      peak = lags(mloc) + peak*(lags(2)-lags(1));
   else
      peak = mloc + peak-fix(len/2.0+0.5);
   end
end

if nargout < 2
   pval = peakval;
else
   pval = peakval; ploc = peak;
end