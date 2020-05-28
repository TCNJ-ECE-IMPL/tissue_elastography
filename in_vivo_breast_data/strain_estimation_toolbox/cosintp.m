function [pval,ploc]=cosintp(cccf,lags)
%COSINTP cosine peak interpolation
%   COSINTP(CCCF) estimates the peak of a correlation 
%   function CCCF using cosine interpolation.
%   COSINTP(CCCF,LAGS) uses the lag values LAGS. LAGS 
%   have to be monotonic, and difference between successive 
%   lags should be a constant. If LAGS is not passed, LAGS 
%   is assumed to be: (1:LEN)-FIX(LEN/2+.5).
%   [PVAL,PLOC] = COSINTP returns both the interpolated 
%   maximum value PVAL and location PLOC.
%
%   See also: PARBINTP, PARBINTP2

% S. Kaisar Alam October 29, 1998
% Copyright © 1999 S. Kaisar Alam. All rights reserved.
% Version 2.0 (rev note: no longer needs fs; uses lag values, when passed)
% Last revised August 22, 2000 (SKA)
% Questions & suggestions to <kalam@rrinyc.org>
%___________________________________________________________

len=length(cccf);
[mval,mloc]=max(cccf);

if mloc==1 | mloc==len  % Max is the 1st/last element - no interpolation
   if exist('lags','var')
      peak = lags(mloc);
   else
      peak = mloc - fix(len/2.0+0.5);  % midpoint is t=0
   end
   peakval = mval;
else
   y=cccf(mloc-1:mloc+1);
   x=-1:1;
   if abs((y(1)+y(3))/(2*y(2)))>1
      if exist('lags','var')
         [peakval,peak]=parbintp(y,lags);
      else
         [peakval,peak]=parbintp(y);
      end
   else
      arg=acos((y(1)+y(3))/(2*y(2)));
      theta=atan2(y(1)-y(3),2*y(2)*sin(arg));
      
      % PEAK VALUE
      peakval = y(2)/cos(theta);
      % FRACTIONAL SHIFT FROM DISCRETE MAXIMUM (x(2) = 0)
      peak = -theta/(arg);
      % ABSOLUTE LOCATION OF TRUE MAXIMUM
      if exist('lags','var')
         peak = lags(mloc) + peak*(lags(2)-lags(1));
      else
         peak = mloc - fix(len/2.0+0.5) + peak;
      end
   end
end

if nargout < 2
    pval = peakval;
else
    pval = peakval; ploc = peak;
end