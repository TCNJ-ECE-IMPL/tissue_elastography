function [pval,plocR,plocC]=parbintp2(cccf,lagsR,lagsC,option)
%PARBINTP2 parabolic peak interpolation (2-D)
%   PARBINTP2(CCCF) estimates the peak of a sampled 2-D 
%   correlation function or any other function CCCF using 
%   2-D parabolic interpolation. 
%   PARBINTP2(CCCF,LAGSR,LAGSC) uses the row lag values 
%   LAGSR and column lag values LAGSC. LAGSR and LAGSC 
%   have to be monotonic, and difference between successive 
%   lags should be a constant. When not passed, defaults are: 
%   (1:SIZE(CCCF,1))-FIX(SIZE(CCCF,1)/2+.5) and 
%   (1:SIZE(CCCF,2))-FIX(SIZE(CCCF,2)/2+.5).
%   PARBINTP2(CCCF,LAGSR,LAGSC,OPTION) interpolates the peak 
%   by minimizing the mean-square error between a parabolic 
%   (independent x and y) surface and the actual data, if 
%   OPTION is 'mse'. If OPTION is '1D' maximum in X and Y
%   directions are computed separately by using points only 
%   in that direction, i.e., for the maximum in row direction, 
%   it uses CCCF(PLR-1,PLC), CCCF(PLR,PLC), and CCCF(PLR+1,PLC). 
%   Otherwise, all 5 points are used. (DEFAULT)
%   [PV,PLR,PLC] = PARBINTP2 returns the interpolated maximum 
%   value PV and locations [PLR,PLC].
%
%   See also: COSINTP2,COSINTP,PARBINTP

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 07-19-98
% Revised: 10-05-05 (SKA)
% Version: 4.0
%
% New in this version: now uses all 5 points simultaneously. 
%                      (will add MSE minimization soon)
%
% Copyright © 1998 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

[m,n] = size(cccf);

if nargin > 1
   if ischar(lagsR), option = LagsR; clear LagsR; end
end

if ~exist('option','var'), option = 'none'; end

if n == 1 % ROW VECTOR
   if exist('lagsR','var')
      [peakval,pkR] = parbintp(cccf,lagsR); pkC = 0;
   else
      [peakval,pkR] = parbintp(cccf); pkC = 0;
   end
elseif m == 1 % COLUMN VECTOR
   if exist('lagsC','var')
      [peakval,pkC] = parbintp(cccf,lagsC); pkR = 0;
   else
      [peakval,pkC] = parbintp(cccf); pkR = 0;
   end
else % 2D CORRELATION
   [mv,mlr,mlc]=max2d(cccf); % mlr is row # and mlc is column #

   if strcmpi(option,'mse')
      error('MSE minimization algorithm not implemented yet');
   elseif strcmpi(option,'1D')
      % DISCRETE PEAK ASSUMED AT (0,0)
      if (mlr == 1 | mlr == m) & (mlc == 1 | mlc == n)
         pkR = 0; pkC = 0; peakval = mv;
      elseif mlr == 1 | mlr == m
         pkR = 0; [peakval,pkC] = parbintp(cccf(mlr,mlc-1:mlc+1));
      elseif mlc == 1 | mlc == n
         pkC = 0; [peakval,pkR] = parbintp(cccf(mlr-1:mlr+1,mlc));
      else
         [peakvalC,pkC] = parbintp(cccf(mlr,mlc-1:mlc+1));
         [peakvalR,pkR] = parbintp(cccf(mlr-1:mlr+1,mlc));
         peakval = max([peakvalC peakvalR]);
      end
      % LAG IN ACTUAL UNITS
      if exist('lagsC','var')
         pkC = lagsC(mlc) + pkC*(lagsC(2)-lagsC(1));
      else
         pkC = mlc + pkC-fix(m/2.0+0.5);
      end
      if exist('lagsR','var')
         pkR = lagsR(mlr) + pkR*(lagsR(2)-lagsR(1));
      else
         pkR = mlr + pkR-fix(n/2.0+0.5);
      end
   else % DEFAULT
      % DISCRETE PEAK ASSUMED AT (0,0)
      if (mlr == 1 | mlr == m) & (mlc == 1 | mlc == n)
         pkR = 0; pkC = 0; peakval = mv;
      elseif mlr == 1 | mlr == m
         pkR = 0; [peakval,pkC] = parbintp(cccf(mlr,mlc-1:mlc+1));
      elseif mlc == 1 | mlc == n
         pkC = 0; [peakval,pkR] = parbintp(cccf(mlr-1:mlr+1,mlc));
      else
         a = cccf(mlr,mlc);
         b = (cccf(mlr,mlc+1) - cccf(mlr,mlc-1))/2;
         c = (cccf(mlr+1,mlc) - cccf(mlr-1,mlc))/2;
         d = -cccf(mlr,mlc) + (cccf(mlr,mlc+1) + cccf(mlr,mlc-1))/2;
         e = -cccf(mlr,mlc) + (cccf(mlr+1,mlc) + cccf(mlr-1,mlc))/2;
         %pkC = b/(2*d);
         %pkR = c/(2*e);
         %peakval = a + b*pkC + c*pkR + d*pkC^2 + e*pkR^2;
         pkC = -b/(2*d);
         pkR = -c/(2*e);
         peakval = a + b*pkC + c*pkR + d*pkC^2 + e*pkR^2;

      end
      % LAG IN ACTUAL UNITS
      if exist('lagsC','var')
         pkC = lagsC(mlc) + pkC*(lagsC(2)-lagsC(1));
      else
         pkC = mlc + pkC-fix(m/2.0+0.5);
      end
      if exist('lagsR','var')
         pkR = lagsR(mlr) + pkR*(lagsR(2)-lagsR(1));
      else
         pkR = mlr + pkR-fix(n/2.0+0.5);
      end
   end
end

if nargout < 2
   pval = peakval;
elseif nargout == 2
   pval = peakval; plocR = pkR;
else
   pval = peakval; plocR = pkR; plocC = pkC;
end