function [c,lag_r,lag_c]=myxcorr2(x,y,maxlagR,maxlagC,minlagR,minlagC,option)
%MYXCORR2 2-dimensional cross-correlation (SKA implementation).
%   MYXCORR2(X,Y) computes the 2-D cross-correlation 
%   between X and Y.
%   X and Y can be equal/unequal sized matrices.
%
%   MYCORR2(X,Y,MAXLAG_R,MAXLAG_C) computes for row lags 
%   -MAXLAG_R:MAXLAG_R and column lags -MAXLAG_C:MAXLAG_C. 
%
%   MYCORR2(X,Y,MAXLAG_R,MAXLAG_C,MINLAG_R,MINLAG_C) computes for 
%   row lags -MINLAG_R:MAXLAG_R and column lags -MINLAG_C:MAXLAG_C
%
%   MYCORR2(X,Y,OPTION), MYCORR2(X,Y,MAXLAG_R,MAXLAG_C,OPTION) 
%   or MYCORR2(X,Y,MAXLAG_R,MAXLAG_C,MINLAG_R,MINLAG_C,OPTION)
%   computes for various OPTIONs as follows:
%   'none' or not passed: compute unnormalized CF (use compcorr2.dll)
%   'coeff': correlation coefficient function (use compcorr2.dll)
%   'fast': unnormalized CF (use MATLAB's fast function XCORR2)
%   'fastcoeff': correlation coefficient function (use XCORR2 for the
%                numerator and Corr2NormFac.dll to compute the denominator)
%   'matlab': calls MATLAB's XCORR2
%
%   [C,LAG_R,LAG_C] = MYXCORR2  returns a vector of row (LAG_R) and 
%   column (LAG_C) lag indices.
%
%   MYXCORR2(X) or MYXCORR2(X,OPTION) computes autocorrelation. 
%
%   MYXCORR2 assumes the arrays to be real.
%
%   See also MYXCORR, MYXCOV2, CONV2 and XCORR2.

% Author:  S. Kaisar Alam
% Email:   kalam@rrinyc.org
% Written: 09-04-98
% Revised: 07-28-09
% Version: 2.9
% New in this version: Can now handle complex numbers. 
%
% Copyright © 1998 S. Kaisar Alam. All rights reserved.
% Questions & suggestions to S. Kaisar Alam.
%___________________________________________________________

error(nargchk(1,7,nargin))
if nargin == 1 % IF ONLY X IS PASSED, COMPUTE AUTOCORRELATION
   y = x;
elseif nargin==2 % IF ONLY X IS PASSED, COMPUTE AUTOCORRELATION
   if isstr(y)
      option=y;
      y=x;
   end
elseif nargin==3
   if isstr(maxlagR)
      option=maxlagR;
      clear maxlagR
   end
elseif nargin==4
   if isstr(maxlagC)
      option=maxlagC;
      clear maxlagC
   end
elseif nargin==5
   if isstr(minlagR)
      option=minlagR;
      clear minlagR
   end
elseif nargin==6
   if isstr(minlagC)
      option=minlagC;
      clear minlagC
   end
end

[rowX,colX]=size(x);
[rowY,colY]=size(y);

if ~exist('option','var')
   option='none';
end

Rx = size(x,1);
Ry = size(y,1);
if ~exist('minlagR','var')   % If no minlagR was passed
   if ~exist('maxlagR','var')   % If no maxlagR was passed AS WELL
      if Rx > Ry, minlagR = -fix(Ry/2);
      else, minlagR = -fix(Ry - Rx/2);
      end
   else
      minlagR = -maxlagR;
   end
end
if ~exist('maxlagR','var')   % If no maxlagR was passed
   if Rx > Ry, maxlagR = fix(Rx - Ry/2);
   else, maxlagR = fix(Rx/2);
   end
end

Cx = size(x,2);
Cy = size(y,2);
if ~exist('minlagC','var')   % If no minlagC was passed
   if ~exist('maxlagC','var')   % If no maxlagC also was passed
      if Cx > Cy, minlagC = -fix(Cy/2);
      else, minlagC = -fix(Cy - Cx/2);
      end
   else
      minlagC = - maxlagC;
   end
end
if ~exist('maxlagC','var')   % If no maxlagC was passed
   if Cx > Cy, maxlagC = fix(Cx - Cy/2);
   else, maxlagC = fix(Cx/2);
   end
end

if strcmpi(option,'none') | strcmpi(option,'coeff')
   c = compcorr2(x,y,maxlagR,maxlagC,minlagR,minlagC,option);
elseif strcmpi(option,'sad')
    c = compsad2(x,y,maxlagR,maxlagC,minlagR,minlagC);
elseif strcmpi(option,'ssd')
    c = compssd2(x,y,maxlagR,maxlagC,minlagR,minlagC);
elseif strcmpi(option,'fast')
   c = xcorr2(x,y);
   zerolag = size(y);
   rangeR = (zerolag(1)+ minlagR):(zerolag(1)+ maxlagR);
   rangeC = (zerolag(2)+ minlagC):(zerolag(2)+ maxlagC);
   c = c(rangeR,rangeC);
elseif strcmpi(option,'fastcoeff')
   c = xcorr2(x,y);
   zerolag = size(y);
   rangeR = (zerolag(1)+ minlagR):(zerolag(1)+ maxlagR);
   rangeC = (zerolag(2)+ minlagC):(zerolag(2)+ maxlagC);
   norm = CNormFac2(x,y,maxlagR,maxlagC,minlagR,minlagC);
   c = c(rangeR,rangeC)./norm;
elseif strcmpi(option,'matlab')
   c = xcorr2(x,y);
   zerolag = size(y);
   rangeR = (zerolag(1)+ minlagR):(zerolag(1)+ maxlagR);
   rangeC = (zerolag(2)+ minlagC):(zerolag(2)+ maxlagC);
   c = c(rangeR,rangeC);
else
   error('Unknown OPTION')
end

lag_r=minlagR:maxlagR;
lag_c=minlagC:maxlagC;

%########################### REVISION HISTORY ###########################
% 2.6) Bug fixed in compcorr2.cpp and compcorr2.m that flipped 
%      the resulting correlation because X was shifted instead of 
%      Y (correct). Also fixed default values of minlagR, maxlagR,
%      minlagC, and maxlagC. 
% 2.5) For compcorr2, the result is flipped up-down AND left-right 
%      to make it consistent with xcorr2. At a later time the bug 
%      in compcorr2.cpp will be fixed. 
% 2.4) Now computes autocorrelation when only X is passed.
% 2.1) It is now possible to define a minimum lag in both dimention, 
%      in addition to the maxlag. Earlier, minimum lag was defaulted 
%      to -maxlag.
% 2.0) zero padding to make the vectors equal (when they are not 
%      equal) was removed for the 'coeff' because zeroes modify the 
%      correlation coefficient values. MATLAB routine 'intersect' 
%      was used to select the elements for use in correlation 
%      computation; it significantly simplified computation. 
% 1.2) for the 'coeff' option, all the normalizers are computed 
%      before the normalization. When the normalizer is zero, it is 
%      set to 'Inf'. 
% 1.1) This version improves the normalization operation for the 
%      'coeff' option when the normalizer is zero; the CCF is computed 
%      to be zero in such cases.